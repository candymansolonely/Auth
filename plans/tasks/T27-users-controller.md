# T27 — `UsersController`

> Giai đoạn 4 – WebAPI · Ước lượng: 0.5–1 ngày · Phụ thuộc: T14, T15, T25 · Layer: WebAPI

## Mục tiêu
Expose các endpoint quản lý tài khoản, mỗi endpoint gắn đúng quyền.

## Kiến thức cần có
- Như T26; thêm `[FromQuery]`, route parameter `{id:guid}`, `CreatedAtAction`.

## Việc cần làm
`WebAPI/Controllers/UsersController.cs`, route gốc `api/users`:

| Endpoint | Quyền | Gọi | Trả |
|---|---|---|---|
| `GET /api/users?page&pageSize&keyword&isActive` | `Permissions.UsersRead` | `GetPagedAsync` | 200 `PagedResult<UserDto>` |
| `GET /api/users/{id}` | `Permissions.UsersRead` | `GetByIdAsync` | 200 `UserDto` |
| `POST /api/users` | `Permissions.UsersCreate` | `CreateAsync` | 201 + `Location` |
| `PUT /api/users/{id}` | `Permissions.UsersUpdate` | `UpdateAsync` | 200 `UserDto` |
| `POST /api/users/{id}/deactivate` | `Permissions.UsersLock` | `DeactivateAsync` | 204 |
| `POST /api/users/{id}/activate` | `Permissions.UsersLock` | `ActivateAsync` | 204 |
| `PUT /api/users/{id}/groups` | `Permissions.UsersAssignGroups` | `AssignGroupsAsync` | 200 `UserDto` |

Tạo mới dùng `CreatedAtAction(nameof(GetById), new { id = dto.Id }, dto)`. Giá trị mặc định query: `page = 1`, `pageSize = 20`.

## Tiêu chí hoàn thành
- [ ] Mỗi action có `[HasPermission(...)]` đúng bảng trên (reviewer đối chiếu với mục II.11 tài liệu thiết kế).
- [ ] Gọi bằng admin → thành công; bằng user không quyền → 403.

## Tham khảo
- Tài liệu thiết kế: mục II.6, II.11.
