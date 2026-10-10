# Plan: Xác thực, ủy quyền, quản lý tài khoản / quyền / nhóm quyền


## Goal
Solution hiện chỉ là scaffold trống (WebAPI còn WeatherForecast mẫu). Cần xây nền tảng:
đăng nhập/đăng xuất, cấp & làm mới token, CRUD tài khoản, CRUD quyền, CRUD nhóm quyền,
và kiểm soát truy cập endpoint theo quyền.

## Quyết định đã chốt
- DB: PostgreSQL + EF Core (Npgsql), migration trong `Infrastructure`.
- Identity tự xây (không dùng ASP.NET Core Identity) → Domain giữ sạch.
- RBAC: User ↔ Group (n-n), Group ↔ Permission (n-n). Permission là mã chuỗi (vd `users.create`).
- Access JWT ngắn hạn + refresh token xoay vòng (lưu hash trong DB, có revoke).

## Scope
In: register/login/refresh/logout/change-password, quản lý user (tạo, sửa, khoá/mở, gán nhóm),
quản lý group (CRUD, gán permission), danh mục permission (read-only, seed từ code),
authorization policy theo permission, seed admin ban đầu, exception middleware, unit test.
Out (làm sau): email xác minh/quên mật khẩu, MFA, OAuth/SSO, audit log, rate limiting (chỉ nêu lockout cơ bản).

## Design

### Domain
- `User` (Id, Email/UserName, PasswordHash, IsActive, FailedAccessCount, LockoutEnd, Groups) — hành vi: `Deactivate/Activate`, `AssignToGroup/RemoveFromGroup`, `RegisterFailedLogin/ResetFailedLogin`, `IsLockedOut(now)`.
- `Group` (Id, Name unique, Description, Permissions) — `GrantPermission/RevokePermission`.
- `Permission` (mã duy nhất, mô tả) + `Permissions` static class chứa hằng số mã quyền (nguồn sự thật cho seed + policy).
- `RefreshToken` (UserId, TokenHash, ExpiresAt, RevokedAt, ReplacedByHash) — `Revoke`, `IsActive(now)`.
- Domain exceptions (vd `DomainException`) cho vi phạm bất biến.

### Application (chỉ ref Domain)
- Interface: `IUserRepository`, `IGroupRepository`, `IPermissionRepository`, `IRefreshTokenRepository`, `IUnitOfWork`, `IPasswordHasher`, `ITokenService` (issue access + refresh), `IClock`, `ICurrentUser`.
- Use case (service hoặc handler, không thêm MediatR): `AuthService` (Login, Refresh, Logout, ChangePassword), `UserService`, `GroupService`, `PermissionService`.
- DTO + FluentValidation validators; exception nghiệp vụ (`NotFoundException`, `ConflictException`, `UnauthorizedException`, `ValidationException`).
- Refresh: phát hiện reuse token đã revoke → revoke toàn bộ chuỗi token của user.
- Claims access token: `sub`, `email`, danh sách permission gộp từ các group (token ngắn hạn, ~15 phút).

### Infrastructure
- `AppDbContext` + `IEntityTypeConfiguration` cho từng entity, bảng nối UserGroup/GroupPermission, index unique (email, group name, permission code, token hash), migration đầu tiên.
- Repository + `UnitOfWork` implementations.
- `PasswordHasher` (BCrypt, bọc sau `IPasswordHasher`), `JwtTokenService`, `SystemClock`.
- `DbSeeder`: đồng bộ permission từ `Permissions` + tạo group `Administrator` (toàn quyền) + user admin từ config/user-secrets.
- `AddInfrastructure(IConfiguration)` extension.

### WebAPI
- `Program.cs`: `AddInfrastructure`, `AddApplication`, JwtBearer (`JwtOptions` bind từ config, key lấy từ user-secrets/env, không commit), `UseAuthentication` trước `UseAuthorization`, exception-handling middleware ánh xạ exception → ProblemDetails.
- Authorization: `PermissionRequirement` + handler đọc claim permission; `[HasPermission("users.read")]` attribute dựng policy động. Policy provider tùy biến.
- Controllers mỏng: `AuthController` (`/api/auth/login|refresh|logout|change-password`), `UsersController`, `GroupsController`, `PermissionsController`.
- Xóa WeatherForecast mẫu.

### Test
- `Domain.Tests`, `Application.Tests` (xUnit + Moq/NSubstitute), thêm vào `AuthenAtho.slnx`; `WebAPI.IntegrationTests` bằng `WebApplicationFactory` cho luồng login → refresh → gọi endpoint có quyền / bị 403.

## Steps (thứ tự, mỗi bước build xanh)
1. Dependency: Npgsql.EntityFrameworkCore.PostgreSQL, EF Core Design, FluentValidation, JwtBearer, BCrypt.Net-Next; test projects. (Xin xác nhận BCrypt — xem Open questions.)
2. Domain: entities, `Permissions`, exceptions + Domain.Tests.
3. Application: interfaces, DTO, validators, services + Application.Tests.
4. Infrastructure: DbContext, configurations, repos, hasher, token service, migration `InitialIdentity`, seeder.
5. WebAPI: JWT config, exception middleware, permission authorization, controllers, bỏ template mẫu.
6. Integration tests + chạy `dotnet build`, `dotnet test`, `dotnet format`.
7. Cập nhật mục Database trong `CLAUDE.md` (đã chốt PostgreSQL) và để `architect-doc` sync `.claude/rules` (API envelope/routing).

Chi tiết từng task nhỏ (cho thực tập sinh): xem [`tasks/00-tong-hop.md`](tasks/00-tong-hop.md).

## Dispatch subagent
business-analyst (chốt rule nghiệp vụ còn mở) → coder (bước 1–5) → tester (bước 2–3, 6) → reviewer (layering) → architect-doc (bước 7).

## Verification
- `dotnet build`, `dotnet test`, `dotnet format --verify-no-changes`, skill `security-scan`.
- `dotnet ef database update` trên Postgres local, chạy `dotnet run --project WebAPI`, thử bằng curl/OpenAPI: login admin → gọi `/api/users` 200; user không có quyền → 403; không token → 401; refresh xoay vòng; dùng lại refresh token cũ → bị từ chối và revoke chuỗi; user bị khoá → không login được.

## Open questions
- Đăng nhập bằng email hay username? (đề xuất: email, unique)
- Chính sách mật khẩu & lockout (đề xuất: ≥10 ký tự, khoá 15 phút sau 5 lần sai).
- Có cho tự đăng ký (public register) hay chỉ admin tạo tài khoản? (đề xuất: chỉ admin tạo.)
- Nhóm hệ thống `Administrator` có bất khả xóa/sửa không? (đề xuất: có, bảo vệ.)
- Xác nhận thêm BCrypt.Net-Next (tech-defaults cho phép BCrypt/Argon2 nhưng chưa chọn gói).
