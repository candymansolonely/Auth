# T06 — Entity `User` (tạo, khóa/mở, gán nhóm)

> Giai đoạn 1 – Domain · Ước lượng: 1 ngày · Phụ thuộc: T05 · Layer: Domain

## Mục tiêu
Tạo entity `User` với các hành vi cơ bản: tạo mới, đổi email, đổi mật khẩu (hash), khóa/mở khóa, gán/gỡ nhóm, lấy danh sách quyền gộp.

## Bối cảnh
User là trung tâm của module. Phần lockout (đăng nhập sai nhiều lần) tách ra T07 để task này đủ nhỏ.

## Kiến thức cần có
- Như T05 (encapsulation, constructor cho EF).
- LINQ: `SelectMany`, `Distinct`.
- Chuẩn hóa chuỗi: `Trim()`, `ToLowerInvariant()`.

## Việc cần làm
1. `Domain/Entities/User.cs`, thuộc tính:
   `Id` (Guid), `Email`, `PasswordHash`, `IsActive`, `FailedAccessCount`, `LockoutEnd` (`DateTimeOffset?`), `CreatedAt`, `UpdatedAt`, `Groups` (read-only, backing field `_groups`).
2. Constructor `User(string email, string passwordHash, DateTimeOffset now)`:
   - Email được chuẩn hóa: `Trim().ToLowerInvariant()`; rỗng → `DomainException("EMAIL_REQUIRED", ...)`.
   - `passwordHash` rỗng → `DomainException`. (Entity **không** tự băm — chỉ nhận hash đã băm từ `IPasswordHasher`.)
   - `IsActive = true`.
3. Method:
   - `ChangeEmail(string email, DateTimeOffset now)`.
   - `SetPasswordHash(string hash, DateTimeOffset now)`.
   - `Deactivate(DateTimeOffset now)` / `Activate(DateTimeOffset now)` — `Activate` đồng thời đặt `FailedAccessCount = 0`, `LockoutEnd = null` (mở cả khóa tạm thời).
   - `AssignToGroup(Group g, DateTimeOffset now)` (idempotent), `RemoveFromGroup(Guid groupId, DateTimeOffset now)`.
   - `IReadOnlyCollection<string> GetPermissionCodes()` — hợp các mã quyền từ mọi group, không trùng.
   - `bool IsInGroup(string groupName)`.
4. Unit test (`UserTests.cs`):
   - Email `"  Admin@Example.COM "` được lưu thành `"admin@example.com"`.
   - Gán cùng group 2 lần → 1 group.
   - User thuộc 2 group có quyền giao nhau → `GetPermissionCodes()` không trùng.
   - `Deactivate` rồi `Activate` → `IsActive` đúng, lockout bị xóa.

## Tiêu chí hoàn thành
- [ ] Không setter `public`, không gọi `DateTime.Now` trong entity.
- [ ] Test xanh.

## Lỗi hay gặp
- Trả về trực tiếp `List<Group>` → code bên ngoài `Add` thẳng vào list, bỏ qua kiểm tra. Luôn expose `IReadOnlyCollection`.

## Tham khảo
- Tài liệu thiết kế: mục I.4, mục II.6.5 (khóa/mở khóa).
