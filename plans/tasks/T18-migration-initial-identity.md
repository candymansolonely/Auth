# T18 — Migration `InitialIdentity` và cập nhật DB local

> Giai đoạn 3 – Infrastructure · Ước lượng: 0.5 ngày · Phụ thuộc: T17 · Layer: Infrastructure, WebAPI (cấu hình)

## Mục tiêu
Tạo migration đầu tiên từ model EF và áp dụng lên PostgreSQL local.

## Bối cảnh
Migration là lịch sử schema. Quy tắc dự án: **không sửa/xóa migration đã apply** — nếu sai thì tạo migration mới để sửa.

## Kiến thức cần có
- EF Core migrations: `dotnet ef migrations add`, `dotnet ef database update`, startup project vs migrations project.
- Connection string PostgreSQL, user-secrets.

## Việc cần làm
1. Đăng ký tạm `AppDbContext` trong `Program.cs` (sẽ chuyển vào `AddInfrastructure` ở T22):
   `builder.Services.AddDbContext<AppDbContext>(o => o.UseNpgsql(builder.Configuration.GetConnectionString("Default")));`
2. Lưu connection string bằng user-secrets (không commit):
   ```bash
   dotnet user-secrets init --project WebAPI
   dotnet user-secrets set "ConnectionStrings:Default" "Host=localhost;Port=5432;Database=authenatho_dev;Username=postgres;Password=postgres" --project WebAPI
   ```
3. Tạo migration:
   ```bash
   dotnet ef migrations add InitialIdentity --project Infrastructure --startup-project WebAPI --output-dir Persistence/Migrations
   ```
4. Đọc file migration sinh ra, đối chiếu với T17 (tên bảng, unique index, khóa chính kép của bảng nối).
5. `dotnet ef database update --project Infrastructure --startup-project WebAPI`, rồi mở DB kiểm tra 6 bảng.

## Tiêu chí hoàn thành
- [ ] Có thư mục `Infrastructure/Persistence/Migrations` với migration `InitialIdentity`.
- [ ] DB local có 6 bảng: `users`, `groups`, `permissions`, `user_groups`, `group_permissions`, `refresh_tokens` (+ `__EFMigrationsHistory`).
- [ ] Không có connection string chứa mật khẩu trong file được commit.

## Lỗi hay gặp
- "Unable to create a DbContext" → thiếu package `Microsoft.EntityFrameworkCore.Design` ở WebAPI, hoặc connection string chưa được set.
- Migration sinh ra sai → **trước khi merge** có thể `dotnet ef migrations remove`; sau khi đã apply ở môi trường chung thì không được.

## Tham khảo
- https://learn.microsoft.com/ef/core/managing-schemas/migrations/
- https://learn.microsoft.com/aspnet/core/security/app-secrets
