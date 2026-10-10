# T29 — Dựng project integration test với `WebApplicationFactory`

> Giai đoạn 5 – Kiểm thử tích hợp · Ước lượng: 1 ngày · Phụ thuộc: T26–T28 · Layer: Tests

## Mục tiêu
Tạo `WebAPI.IntegrationTests` chạy toàn bộ API trong bộ nhớ, nối với một database PostgreSQL riêng cho test, có helper đăng nhập lấy token.

## Bối cảnh
Unit test đã kiểm từng service với mock. Integration test kiểm việc ghép nối thật: routing, JWT, policy phân quyền, middleware lỗi, EF + PostgreSQL.

## Kiến thức cần có
- `WebApplicationFactory<TEntryPoint>`, `IClassFixture<T>`, `IAsyncLifetime` trong xUnit.
- `HttpClient`, `System.Net.Http.Json` (`PostAsJsonAsync`, `ReadFromJsonAsync`).
- Ghi đè cấu hình khi test (`ConfigureAppConfiguration`, `UseEnvironment`).

## Việc cần làm
1. `dotnet new xunit -n WebAPI.IntegrationTests -o tests/WebAPI.IntegrationTests -f net9.0`, add vào `AuthenAtho.slnx`, reference `WebAPI`, thêm package `Microsoft.AspNetCore.Mvc.Testing`.
2. Cuối `Program.cs` thêm `public partial class Program;` để test truy cập được.
3. `AuthApiFactory : WebApplicationFactory<Program>, IAsyncLifetime`:
   - `UseEnvironment("Testing")`.
   - Ghi đè cấu hình: `ConnectionStrings:Default` → DB `authenatho_test`, `Jwt:SigningKey` (chuỗi test ≥ 32 byte), `Seed:AdminEmail/AdminPassword` cố định cho test.
   - `InitializeAsync`: `EnsureDeletedAsync()` → `MigrateAsync()` → `DbSeeder.SeedAsync()`.
   - Đảm bảo `Program.cs` không tự migrate/seed ở môi trường `Testing` để tránh chạy 2 lần.
4. Helper `TestAuth`:
   - `LoginAsAdminAsync(HttpClient)` → trả access token.
   - `CreateUserWithPermissionsAsync(params string[] permissions)` → tạo group + user qua API bằng token admin, đăng nhập user đó, trả token.
5. Một test khói: `POST /api/auth/login` bằng admin → 200.

## Tiêu chí hoàn thành
- [ ] `dotnet test` chạy được cả unit test và integration test.
- [ ] Integration test không đụng DB `authenatho_dev`.

## Lưu ý
- Cách này cần PostgreSQL local đang chạy. Phương án tự dựng DB bằng Testcontainers tiện hơn cho CI nhưng là **package mới, phải hỏi lead**.

## Tham khảo
- https://learn.microsoft.com/aspnet/core/test/integration-tests
