# T12 — `AuthService.RefreshAsync` (xoay vòng + phát hiện dùng lại)

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T11 · Layer: Application

## Mục tiêu
Cài đặt làm mới token: mỗi refresh token chỉ dùng một lần; nếu token đã thu hồi bị dùng lại thì thu hồi toàn bộ token của user.

## Bối cảnh
Nếu kẻ xấu lấy được refresh token, xoay vòng giúp phát hiện: token cũ (đã đổi) bị gửi lại nghĩa là có 2 bên cùng giữ token → coi như bị lộ, đăng xuất mọi phiên của user đó. Xem sơ đồ phần 2 và 3 ở mục I.6 của tài liệu thiết kế.

## Kiến thức cần có
- Refresh token rotation và reuse detection (đọc link tham khảo).
- Transaction: vì sao "thu hồi token cũ" và "lưu token mới" phải commit cùng nhau (một lần `SaveChangesAsync`).

## Việc cần làm
1. `Task<TokenResponse> RefreshAsync(RefreshRequest request, CancellationToken ct)`:
   1. Validate.
   2. `hash = tokenService.HashRefreshToken(request.RefreshToken)`; `stored = GetByHashAsync(hash)`. Không có → `UnauthorizedException(INVALID_REFRESH_TOKEN)`.
   3. `stored.IsRevoked` → lấy `GetActiveByUserIdAsync(stored.UserId, now)`, `Revoke(now)` tất cả, `SaveChangesAsync`, ném `REFRESH_TOKEN_REUSED`. Ghi log cảnh báo.
   4. `stored.IsExpired(now)` → `INVALID_REFRESH_TOKEN`.
   5. Tải user. User không tồn tại / `!IsActive` / `IsLockedOut(now)` → `stored.Revoke(now)`, lưu, ném `ACCOUNT_DISABLED` hoặc `ACCOUNT_LOCKED`.
   6. Tạo cặp token mới (dùng lại `IssueTokens` của T11, permission tính lại tại thời điểm này).
   7. `stored.Revoke(now, newRefresh.TokenHash)`; thêm token mới; **một** lần `SaveChangesAsync`.
2. Unit test (`AuthServiceRefreshTests.cs`):
   - Token không tồn tại → `INVALID_REFRESH_TOKEN`.
   - Token hết hạn → `INVALID_REFRESH_TOKEN`.
   - Token hợp lệ → trả token mới; token cũ có `RevokedAt` và `ReplacedByHash` = hash mới; `SaveChangesAsync` gọi đúng 1 lần.
   - Token đã revoke → `REFRESH_TOKEN_REUSED` và mọi token active khác của user bị revoke.
   - User bị khóa → `ACCOUNT_DISABLED`, token hiện tại bị revoke.

## Tiêu chí hoàn thành
- [ ] 5 test xanh.
- [ ] Không log giá trị token.

## Tham khảo
- Tài liệu thiết kế: mục II.3.
- Auth0 – Refresh Token Rotation: https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation
