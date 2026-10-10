# T22 — `DbSeeder` và extension `AddInfrastructure()`

> Giai đoạn 3 – Infrastructure · Ước lượng: 1 ngày · Phụ thuộc: T19, T20, T21 · Layer: Infrastructure, WebAPI (gọi)

## Mục tiêu
Gom mọi đăng ký DI của Infrastructure vào `AddInfrastructure(IConfiguration)`, và viết seeder khởi tạo quyền, nhóm Administrator, tài khoản admin.

## Bối cảnh
Lần chạy đầu tiên, DB trống thì không ai đăng nhập được. Seeder tạo sẵn tài khoản admin từ cấu hình bí mật. Seeder phải **idempotent**: chạy mỗi lần khởi động mà không tạo trùng.

## Kiến thức cần có
- DI lifetime: Singleton / Scoped / Transient; vì sao `DbContext` là Scoped.
- Tạo scope khi khởi động: `app.Services.CreateScope()`.
- Options pattern, user-secrets.

## Việc cần làm
1. `Infrastructure/DependencyInjection.cs`:
   ```csharp
   public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration config)
   {
       services.AddDbContext<AppDbContext>(o => o.UseNpgsql(config.GetConnectionString("Default")));
       services.AddScoped<IUserRepository, UserRepository>();
       // ... các repository khác, IUnitOfWork
       services.AddSingleton<IPasswordHasher, BCryptPasswordHasher>();
       services.AddSingleton<IClock, SystemClock>();
       services.AddScoped<ITokenService, JwtTokenService>();
       services.AddOptions<JwtOptions>().Bind(config.GetSection("Jwt")).Validate(...).ValidateOnStart();
       services.Configure<SeedOptions>(config.GetSection("Seed"));
       services.AddScoped<DbSeeder>();
       return services;
   }
   ```
   Xóa đăng ký `AddDbContext` tạm trong `Program.cs` ở T18.
2. `Infrastructure/Persistence/DbSeeder.cs` — `SeedAsync(CancellationToken)`:
   1. Đồng bộ `Permissions.All`: thêm mã chưa có, cập nhật mô tả nếu khác.
   2. Tạo nhóm `Administrator` (`IsSystem = true`) nếu chưa có; `GrantPermission` mọi quyền.
   3. Nếu `Seed:AdminEmail` và `Seed:AdminPassword` có giá trị và chưa có user với email đó → tạo user, gán nhóm Administrator. Thiếu cấu hình → `LogWarning` và bỏ qua.
   4. Một lần `SaveChangesAsync`.
3. Trong `Program.cs` (sau `builder.Build()`): ở môi trường Development, `MigrateAsync()` rồi `SeedAsync()` trong một scope.
4. Set secret cho admin:
   ```bash
   dotnet user-secrets set "Seed:AdminEmail" "admin@authenatho.local" --project WebAPI
   dotnet user-secrets set "Seed:AdminPassword" "<mật khẩu ≥ 10 ký tự>" --project WebAPI
   dotnet user-secrets set "Jwt:SigningKey" "<chuỗi ngẫu nhiên ≥ 32 byte>" --project WebAPI
   ```

## Tiêu chí hoàn thành
- [ ] Chạy app 2 lần liên tiếp: DB có đúng 11 quyền, 1 nhóm Administrator, 1 admin — không trùng.
- [ ] Thêm thử 1 hằng số quyền mới → khởi động lại → quyền mới có trong DB và thuộc nhóm Administrator (xong thì xóa hằng số thử).

## Tham khảo
- Tài liệu thiết kế: mục II.10, II.12.
- https://learn.microsoft.com/ef/core/modeling/data-seeding
