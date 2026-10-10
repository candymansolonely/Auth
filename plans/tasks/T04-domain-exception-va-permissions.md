# T04 — DomainException và danh mục quyền `Permissions`

> Giai đoạn 1 – Domain · Ước lượng: 0.5 ngày · Phụ thuộc: T02 · Layer: Domain

## Mục tiêu
Tạo exception dùng chung cho vi phạm bất biến ở Domain, và lớp hằng số `Permissions` — nguồn sự thật duy nhất của mọi mã quyền.

## Bối cảnh
- Mã quyền được dùng ở 2 nơi: seed DB (T22) và gắn lên endpoint (`[HasPermission(...)]`, T25). Nếu viết tay chuỗi `"users.read"` rải rác, gõ sai một ký tự là lỗ hổng phân quyền. Vì vậy mọi nơi phải dùng hằng số trong `Permissions`.
- `DomainException` để entity báo lỗi khi bị dùng sai (ví dụ gán quyền rỗng). Middleware (T23) sẽ đổi nó thành HTTP 400.

## Kiến thức cần có
- C#: `static class`, `const`, `record`/tuple, `IReadOnlyList<T>`.
- Khái niệm "invariant" (bất biến) của entity.

## Việc cần làm
1. `Domain/Exceptions/DomainException.cs`:
   ```csharp
   public class DomainException(string code, string message) : Exception(message)
   {
       public string Code { get; } = code;
   }
   ```
2. `Domain/Authorization/Permissions.cs` với đủ 11 quyền (bảng ở mục II.11 tài liệu thiết kế):

   | Hằng số | Mã |
   |---|---|
   | `UsersRead` | `users.read` |
   | `UsersCreate` | `users.create` |
   | `UsersUpdate` | `users.update` |
   | `UsersLock` | `users.lock` |
   | `UsersAssignGroups` | `users.assign-groups` |
   | `GroupsRead` | `groups.read` |
   | `GroupsCreate` | `groups.create` |
   | `GroupsUpdate` | `groups.update` |
   | `GroupsDelete` | `groups.delete` |
   | `GroupsAssignPermissions` | `groups.assign-permissions` |
   | `PermissionsRead` | `permissions.read` |

   Thêm thuộc tính `All` chứa cặp `(Code, Description)` (mô tả tiếng Việt) cho từng quyền.
3. Thêm hằng số tên nhóm hệ thống: `public const string AdministratorGroupName = "Administrator";` (đặt trong `Domain/Authorization/SystemGroups.cs`).
4. Unit test trong `Domain.Tests`:
   - Không có mã trùng nhau trong `All`.
   - Mọi mã khớp regex `^[a-z]+(-[a-z]+)*\.[a-z]+(-[a-z]+)*$`.
   - Mọi hằng số `const string` trong lớp đều có mặt trong `All` (gợi ý: dùng reflection `typeof(Permissions).GetFields(...)`).

## Tiêu chí hoàn thành
- [ ] 3 test trên chạy xanh.
- [ ] Không có `using` nào tới project khác trong Domain.

## Lỗi hay gặp
- Thêm hằng số mới nhưng quên thêm vào `All` → test số 3 bắt được lỗi này, đó là lý do test tồn tại.

## Tham khảo
- Tài liệu thiết kế: mục II.8 "Danh mục quyền", mục II.11 "Phân quyền module Auth".
