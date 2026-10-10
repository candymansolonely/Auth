# T26 — `AuthController`

> Giai đoạn 4 – WebAPI · Ước lượng: 0.5 ngày · Phụ thuộc: T11–T13, T23, T24 · Layer: WebAPI

## Mục tiêu
Expose 4 endpoint xác thực, controller mỏng — chỉ nhận request, gọi `AuthService`, trả kết quả.

## Bối cảnh
Toàn bộ logic đã nằm ở `AuthService`. Controller không có `if` nghiệp vụ, không `try/catch` (middleware T23 lo lỗi).

## Kiến thức cần có
- `[ApiController]`, `[Route]`, `[HttpPost]`, `[FromBody]`, `[AllowAnonymous]`, `[Authorize]`.
- `ActionResult<T>`, `Ok()`, `NoContent()`.

## Việc cần làm
`WebAPI/Controllers/AuthController.cs`, route gốc `api/auth`:

| Endpoint | Attribute | Gọi | Trả |
|---|---|---|---|
| `POST /api/auth/login` | `[AllowAnonymous]` | `LoginAsync` | 200 `TokenResponse` |
| `POST /api/auth/refresh` | `[AllowAnonymous]` | `RefreshAsync` | 200 `TokenResponse` |
| `POST /api/auth/logout` | `[Authorize]` | `LogoutAsync` | 204 |
| `POST /api/auth/change-password` | `[Authorize]` | `ChangePasswordAsync` | 204 |

Thêm `[ProducesResponseType]` cho các mã lỗi chính để OpenAPI hiển thị đúng. Truyền `CancellationToken` từ action xuống service.

Kiểm tra thủ công bằng file `WebAPI/WebAPI.http` hoặc curl: login bằng tài khoản admin seed ở T22.

## Tiêu chí hoàn thành
- [ ] Login admin trả token; refresh trả token mới; dùng lại refresh token cũ → 401 `REFRESH_TOKEN_REUSED`.
- [ ] Controller không chứa logic nghiệp vụ.

## Tham khảo
- Tài liệu thiết kế: mục II.2–II.5.
- https://learn.microsoft.com/aspnet/core/web-api/
