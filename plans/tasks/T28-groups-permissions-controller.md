# T28 — `GroupsController`, `PermissionsController` và dọn template mẫu

> Giai đoạn 4 – WebAPI · Ước lượng: 0.5–1 ngày · Phụ thuộc: T16, T25 · Layer: WebAPI

## Mục tiêu
Expose endpoint quản lý nhóm quyền và danh mục quyền; xóa `WeatherForecast` mẫu.

## Kiến thức cần có
- Như T27; thêm `[HttpDelete]`.

## Việc cần làm
1. `GroupsController`, route `api/groups`:

   | Endpoint | Quyền | Trả |
   |---|---|---|
   | `GET /api/groups?page&pageSize&keyword` | `GroupsRead` | 200 `PagedResult<GroupDto>` |
   | `GET /api/groups/{id}` | `GroupsRead` | 200 `GroupDto` |
   | `POST /api/groups` | `GroupsCreate` | 201 + `Location` |
   | `PUT /api/groups/{id}` | `GroupsUpdate` | 200 `GroupDto` |
   | `DELETE /api/groups/{id}` | `GroupsDelete` | 204 |
   | `PUT /api/groups/{id}/permissions` | `GroupsAssignPermissions` | 200 `GroupDto` |

2. `PermissionsController`: `GET /api/permissions` — quyền `PermissionsRead` — 200 `PermissionDto[]`.
3. Xóa `WebAPI/Controllers/WeatherForecastController.cs` và `WebAPI/WeatherForecast.cs`; xóa endpoint tạm (`/api/me`…) nếu còn.
4. Cập nhật `WebAPI/WebAPI.http` với ví dụ gọi các endpoint mới (dùng biến `@token`).

## Tiêu chí hoàn thành
- [ ] `dotnet build` xanh, không còn code WeatherForecast.
- [ ] Sửa/xóa nhóm Administrator → 409 `SYSTEM_GROUP_PROTECTED`.

## Tham khảo
- Tài liệu thiết kế: mục II.7, II.8, II.11.
