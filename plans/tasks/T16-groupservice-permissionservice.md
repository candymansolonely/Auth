# T16 — `GroupService` và `PermissionService`

> Giai đoạn 2 – Application · Ước lượng: 1–1.5 ngày · Phụ thuộc: T10 · Layer: Application

## Mục tiêu
Cài đặt CRUD nhóm quyền, gán quyền cho nhóm, và đọc danh mục quyền.

## Bối cảnh
Nhóm `Administrator` là nhóm hệ thống (`IsSystem = true`): không sửa, không xóa, không đổi quyền qua API (câu hỏi mở số 4, đang theo phương án đề xuất). Không xóa nhóm còn thành viên để tránh vô tình thu hồi quyền hàng loạt.

## Kiến thức cần có
- Như T14.
- Thao tác tập hợp với LINQ: `Except`, `Intersect`.

## Việc cần làm
1. `GroupService`:
   - `GetPagedAsync(GroupQuery, ct)`, `GetByIdAsync(Guid, ct)` (`GROUP_NOT_FOUND`); `GroupDto.UserCount` lấy từ `CountMembersAsync`.
   - `CreateAsync(CreateGroupRequest, ct)`: tên trùng → `GROUP_NAME_EXISTS`; mã quyền lạ → `PERMISSION_NOT_FOUND` (so số lượng trả về từ `GetByCodesAsync` với số mã yêu cầu sau khi `Distinct`); tạo group, grant quyền, lưu → 201.
   - `UpdateAsync(Guid, UpdateGroupRequest, ct)`: nhóm hệ thống → `SYSTEM_GROUP_PROTECTED` (bắt `DomainException` từ entity hoặc kiểm tra trước); tên trùng nhóm khác → `GROUP_NAME_EXISTS`.
   - `DeleteAsync(Guid, ct)`: hệ thống → `SYSTEM_GROUP_PROTECTED`; `HasMembersAsync` → `GROUP_IN_USE`; `Remove`, lưu.
   - `AssignPermissionsAsync(Guid, AssignPermissionsRequest, ct)`: mã lạ → `PERMISSION_NOT_FOUND`; `group.ReplacePermissions(...)`; lưu; trả `GroupDto`.
2. `PermissionService.GetAllAsync(ct)` → `IReadOnlyList<PermissionDto>` sắp xếp theo `Code`.
3. Đăng ký DI cả hai service.
4. Unit test: mỗi method thành công + từng nhánh lỗi ở trên.

## Tiêu chí hoàn thành
- [ ] Tất cả test xanh.
- [ ] Mã lỗi `SYSTEM_GROUP_PROTECTED` trả HTTP 409 (ném `ConflictException`, không để `DomainException` lọt ra thành 400).

## Tham khảo
- Tài liệu thiết kế: mục II.7, II.8.
