# T11 — `AuthService.LoginAsync`

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T10 · Layer: Application

## Mục tiêu
Cài đặt use case đăng nhập: kiểm tra tài khoản, mật khẩu, lockout; cấp access token + refresh token. Có unit test đầy đủ bằng mock.

## Bối cảnh
Đây là cửa vào của cả hệ thống, nhiều nhánh lỗi. Luồng chi tiết nằm ở tài liệu thiết kế mục II.2 — làm đúng thứ tự các bước vì thứ tự ảnh hưởng tới bảo mật (ví dụ không được tiết lộ email có tồn tại hay không).

## Kiến thức cần có
- Mock interface với NSubstitute/Moq: `Returns`, `Received()`.
- Hiểu JWT ở mức khái niệm (header.payload.signature, claim, thời hạn).
- Vì sao trả cùng một lỗi `INVALID_CREDENTIALS` cho "sai email" và "sai mật khẩu".

## Việc cần làm
1. `Application/Auth/AuthService.cs`, constructor inject: `IUserRepository`, `IRefreshTokenRepository`, `IPasswordHasher`, `ITokenService`, `IUnitOfWork`, `IClock`, `IOptions<LockoutOptions>`, `IValidator<LoginRequest>`, `ILogger<AuthService>`.
2. `Task<TokenResponse> LoginAsync(LoginRequest request, CancellationToken ct)`:
   1. Validate.
   2. Chuẩn hóa email (`Trim().ToLowerInvariant()`), tìm user. Không thấy → `UnauthorizedException(INVALID_CREDENTIALS)`.
   3. `!user.IsActive` → `ACCOUNT_DISABLED`.
   4. `user.IsLockedOut(now)` → `ACCOUNT_LOCKED`.
   5. Sai mật khẩu → `user.RegisterFailedLogin(now, max, duration)`, `SaveChangesAsync`, rồi ném `INVALID_CREDENTIALS`.
   6. Đúng → `user.ResetFailedLogin()`.
   7. `permissions = user.GetPermissionCodes()`; tạo access token + refresh token qua `ITokenService`.
   8. `refreshTokenRepository.Add(new RefreshToken(user.Id, refresh.TokenHash, now, refresh.ExpiresAt))`, `SaveChangesAsync`.
   9. Trả `TokenResponse`.
3. Viết một private method `IssueTokensAsync(User user, ...)` dùng chung cho T12 (refresh).
4. Đăng ký `services.AddScoped<AuthService>()` trong `AddApplication`.
5. Unit test (`AuthServiceLoginTests.cs`):
   - Email không tồn tại → `INVALID_CREDENTIALS`, **không** gọi `Verify`.
   - User bị khóa (`IsActive=false`) → `ACCOUNT_DISABLED`.
   - Đang lockout → `ACCOUNT_LOCKED`, không kiểm tra mật khẩu.
   - Sai mật khẩu → `INVALID_CREDENTIALS`, `FailedAccessCount` tăng, `SaveChangesAsync` được gọi.
   - Sai lần thứ 5 → user bị lockout.
   - Đúng → trả token, refresh token được `Add` với hash (không phải token gốc), đếm sai được reset.

## Gợi ý
- Dùng một `FakeClock : IClock` có thể chỉnh giờ trong test thay vì mock.
- Log cảnh báo khi tài khoản bị lockout (`_logger.LogWarning("User {UserId} locked out", ...)`) — **không log mật khẩu hay token**.

## Tiêu chí hoàn thành
- [ ] 6 test trên xanh.
- [ ] Không có chuỗi mã lỗi viết tay — dùng `ErrorCodes`.

## Tham khảo
- Tài liệu thiết kế: mục II.2 + sơ đồ mục I.6.
- OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
