# T17 — `AppDbContext` và cấu hình mapping cho từng entity

> Giai đoạn 3 – Infrastructure · Ước lượng: 1–1.5 ngày · Phụ thuộc: T05–T08, T03 · Layer: Infrastructure

## Mục tiêu
Tạo `AppDbContext` và một `IEntityTypeConfiguration<T>` cho mỗi entity, gồm 2 bảng nối nhiều-nhiều và các index unique.

## Bối cảnh
Entity Domain không có attribute EF nào (`[Key]`, `[Table]`...) để Domain sạch. Mọi mapping viết bằng Fluent API trong Infrastructure.

## Kiến thức cần có
- EF Core cơ bản: `DbContext`, `DbSet`, Fluent API (`HasKey`, `Property`, `HasIndex().IsUnique()`, `HasMany().WithMany().UsingEntity(...)`).
- Mapping backing field (`Metadata.FindNavigation(...).SetPropertyAccessMode(PropertyAccessMode.Field)`).
- Kiểu dữ liệu PostgreSQL: `uuid`, `varchar`, `timestamptz`, `boolean`.

## Việc cần làm
1. `Infrastructure/Persistence/AppDbContext.cs`: `DbSet` cho `User`, `Group`, `Permission`, `RefreshToken`; trong `OnModelCreating` gọi `ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly)`.
2. `Infrastructure/Persistence/Configurations/`:
   - `UserConfiguration`: bảng `users`; `Email` max 256, unique index; `PasswordHash` required; quan hệ n-n với `Group` qua bảng nối `user_groups` (cột `user_id`, `group_id`, khóa chính kép); navigation `Groups` dùng backing field.
   - `GroupConfiguration`: bảng `groups`; `Name` max 100 unique; `Description` max 500; n-n với `Permission` qua bảng `group_permissions` (`group_id`, `permission_code`).
   - `PermissionConfiguration`: bảng `permissions`; khóa chính `Code` (max 100).
   - `RefreshTokenConfiguration`: bảng `refresh_tokens`; `TokenHash` max 128 unique; FK `UserId` → `users` (cascade delete); index `UserId`.
3. Đặt tên bảng/cột thống nhất kiểu snake_case (có thể cấu hình tay từng cột, hoặc hỏi lead có muốn dùng package `EFCore.NamingConventions` không — **chưa có trong danh sách được duyệt**).

## Tiêu chí hoàn thành
- [ ] `dotnet build` xanh.
- [ ] Không entity Domain nào bị thêm attribute EF hay `using Microsoft.EntityFrameworkCore`.
- [ ] Reviewer xác nhận schema trước khi tạo migration (T18).

## Lỗi hay gặp
- Npgsql chỉ cho ghi `DateTimeOffset` có offset 0 (UTC) vào `timestamptz`. Luôn lấy giờ từ `IClock.UtcNow`.
- Quên cấu hình backing field → EF không nạp được `Groups`/`Permissions` vào list private.

## Tham khảo
- https://learn.microsoft.com/ef/core/modeling/relationships/many-to-many
- https://www.npgsql.org/efcore/
