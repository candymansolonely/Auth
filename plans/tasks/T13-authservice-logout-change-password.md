# T13 — `AuthService.LogoutAsync` và `ChangePasswordAsync`

> Giai đoạn 2 – Application · Ước lượng: 0.5–1 ngày · Phụ thuộc: T12 · Layer: Application

## Mục tiêu
Cài đặt đăng xuất (thu hồi refresh token) và đổi mật khẩu cho user đang đăng nhập.

## Bối cảnh
Cả hai thao tác đều dùng `ICurrentUser` để biết ai đang gọi — người dùng chỉ thao tác trên chính tài khoản của mình. `ICurrentUser` sẽ được implement ở WebAPI (T24), ở đây chỉ mock.

## Kiến thức cần có
- Khái niệm idempotent (gọi nhiều lần cho cùng kết quả).
- Vì sao access token không "thu hồi" được phía server (stateless) và vì sao chấp nhận được với token ngắn hạn.

## Việc cần làm
1. `Task LogoutAsync(LogoutRequest request, CancellationToken ct)`:
   - Tìm token theo hash. Không thấy / đã revoke / `UserId != currentUser.UserId` → return (không lỗi).
   - Ngược lại `Revoke(now)` và lưu.
2. `Task ChangePasswordAsync(ChangePasswordRequest request, CancellationToken ct)`:
   - Validate (chính sách mật khẩu, mật khẩu mới khác mật khẩu cũ).
   - `currentUser.UserId` null → `UnauthorizedException`.
   - Tải user; sai `CurrentPassword` → `ValidationException`/`AppException` với code `INVALID_CURRENT_PASSWORD` (HTTP 400).
   - `user.SetPasswordHash(hasher.Hash(newPassword), now)`.
   - Thu hồi mọi refresh token active của user (đề xuất trong thiết kế), lưu một lần.
3. Unit test:
   - Logout token của người khác → không bị revoke.
   - Logout token hợp lệ → revoke.
   - Logout 2 lần → không lỗi.
   - Đổi mật khẩu sai mật khẩu hiện tại → `INVALID_CURRENT_PASSWORD`, hash không đổi.
   - Đổi mật khẩu đúng → hash mới, mọi refresh token bị revoke.

## Tiêu chí hoàn thành
- [ ] 5 test xanh.

## Tham khảo
- Tài liệu thiết kế: mục II.4, II.5.
