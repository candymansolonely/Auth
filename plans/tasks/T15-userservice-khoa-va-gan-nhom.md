# T15 — `UserService`: khóa/mở khóa và gán nhóm

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T14, T13 · Layer: Application

## Mục tiêu
Cài đặt khóa/mở khóa tài khoản và gán nhóm quyền, kèm các luật bảo vệ để hệ thống không bao giờ mất quản trị viên.

## Bối cảnh
Hai luật bảo vệ (đề xuất trong thiết kế):
- Không được tự khóa chính mình (`CANNOT_DEACTIVATE_SELF`).
- Không được khóa hoặc gỡ nhóm Administrator khỏi **quản trị viên cuối cùng còn hoạt động** (`LAST_ADMIN_PROTECTED`).

## Kiến thức cần có
- Như T14; thêm `ICurrentUser`.
- Tư duy "edge case": điều gì xảy ra nếu chỉ còn 1 admin?

## Việc cần làm
1. `DeactivateAsync(Guid id, ct)`:
   - `id == currentUser.UserId` → `ConflictException(CANNOT_DEACTIVATE_SELF)`.
   - User là admin đang hoạt động và `CountActiveUsersInGroupAsync(Administrator) <= 1` → `LAST_ADMIN_PROTECTED`.
   - `user.Deactivate(now)`; revoke mọi refresh token active (`IRefreshTokenRepository`); lưu.
2. `ActivateAsync(Guid id, ct)`: `user.Activate(now)`; lưu.
3. `AssignGroupsAsync(Guid id, AssignGroupsRequest r, ct)`:
   - Kiểm tra mọi group tồn tại (`GROUP_NOT_FOUND`).
   - Nếu user đang ở nhóm Administrator, danh sách mới không có Administrator, và user là admin hoạt động cuối cùng → `LAST_ADMIN_PROTECTED`.
   - So sánh danh sách cũ/mới, gọi `AssignToGroup` / `RemoveFromGroup`; lưu; trả `UserDto`.
4. Unit test:
   - Tự khóa mình → lỗi.
   - Khóa admin cuối cùng → lỗi; khóa admin khi còn 2 admin → thành công.
   - Khóa user thường → `IsActive=false`, refresh token bị revoke.
   - Mở khóa → lockout bị xóa.
   - Gán nhóm: thêm/bớt đúng; gỡ Administrator khỏi admin cuối → lỗi.

## Tiêu chí hoàn thành
- [ ] Tất cả test xanh.

## Tham khảo
- Tài liệu thiết kế: mục II.6.5, II.6.6.
