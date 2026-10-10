# T05 — Entity `Permission` và `Group`

> Giai đoạn 1 – Domain · Ước lượng: 1 ngày · Phụ thuộc: T04 · Layer: Domain

## Mục tiêu
Tạo 2 entity `Permission` và `Group` có hành vi `GrantPermission` / `RevokePermission`, kèm unit test.

## Bối cảnh
RBAC của hệ thống: user thuộc nhiều group, mỗi group có nhiều permission. Group là nơi "gom" quyền để gán cho user. Logic gán quyền phải nằm **trên entity** (không nằm trong service) để không ai thêm trùng quyền hay sửa nhóm hệ thống được.

## Kiến thức cần có
- Encapsulation trong C#: `private set`, backing field `private readonly List<T> _items`, expose `IReadOnlyCollection<T>`.
- Constructor `private` không tham số cho EF Core (EF cần để tạo object khi đọc DB).
- Khái niệm entity vs value object, quan hệ nhiều-nhiều.

## Việc cần làm
1. `Domain/Entities/Permission.cs`: `Code` (string, khóa), `Description`. Constructor kiểm tra `Code` không rỗng (vi phạm → `DomainException("PERMISSION_CODE_REQUIRED", ...)`). Có method `UpdateDescription(string)` (seeder dùng).
2. `Domain/Entities/Group.cs`:
   - Thuộc tính: `Id` (Guid), `Name`, `Description`, `IsSystem`, `CreatedAt`, `UpdatedAt`, `Permissions` (read-only, backing field `_permissions`).
   - Constructor: `Group(string name, string? description, DateTimeOffset now, bool isSystem = false)`; tên không rỗng, tối đa 100 ký tự.
   - `Rename(string name, string? description, DateTimeOffset now)` — nếu `IsSystem` → `DomainException("SYSTEM_GROUP_PROTECTED", ...)`.
   - `GrantPermission(Permission p, DateTimeOffset now)` — đã có thì bỏ qua (idempotent).
   - `RevokePermission(string code, DateTimeOffset now)` — không có thì bỏ qua.
   - `ReplacePermissions(IEnumerable<Permission> permissions, DateTimeOffset now)` — dùng cho API "gán quyền cho nhóm" (thay toàn bộ danh sách); chặn nếu `IsSystem`.
3. Unit test (`Domain.Tests/Entities/GroupTests.cs`), tối thiểu:
   - Tạo group tên rỗng → ném `DomainException`.
   - Grant cùng 1 quyền 2 lần → chỉ có 1.
   - Revoke quyền không tồn tại → không lỗi.
   - `ReplacePermissions` thay đúng danh sách.
   - Nhóm hệ thống: `Rename` và `ReplacePermissions` ném `DomainException` với code `SYSTEM_GROUP_PROTECTED`.

## Gợi ý
- Thời gian luôn truyền vào (`DateTimeOffset now`) thay vì gọi `DateTime.Now` trong entity — để test chủ động được thời gian. `IClock` (T09) sẽ cung cấp giá trị này.
- Seeder cần cấp toàn bộ quyền cho nhóm Administrator dù là nhóm hệ thống → `GrantPermission` **không** chặn `IsSystem`; chỉ `Rename`/`ReplacePermissions` (thao tác từ API) bị chặn.

## Tiêu chí hoàn thành
- [ ] Entity không có setter `public`.
- [ ] Tất cả test xanh.

## Tham khảo
- Tài liệu thiết kế: mục I.4 "Đối tượng dữ liệu".
- EF Core và backing field: https://learn.microsoft.com/ef/core/modeling/backing-field
