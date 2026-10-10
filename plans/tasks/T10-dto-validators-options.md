# T10 — DTO, validator FluentValidation, options và `AddApplication()`

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T09 · Layer: Application

## Mục tiêu
Tạo các DTO request/response, validator cho từng request, lớp options (mật khẩu, lockout) và extension method đăng ký DI của tầng Application.

## Bối cảnh
Controller chỉ nhận DTO và chuyển xuống service; service gọi validator trước khi xử lý. Gom validate về FluentValidation thay vì chuỗi `if` rải rác (quy tắc trong `tech-defaults.md`).

## Kiến thức cần có
- `record` trong C#.
- FluentValidation: `AbstractValidator<T>`, `RuleFor`, `NotEmpty`, `EmailAddress`, `MinimumLength`, `MaximumLength`.
- Options pattern (`IOptions<T>`), DI `IServiceCollection`.

## Việc cần làm
1. DTO (`Application/Auth/Dtos`, `Application/Users/Dtos`, `Application/Groups/Dtos`), tên field theo tài liệu thiết kế mục II:
   - Auth: `LoginRequest(Email, Password)`, `RefreshRequest(RefreshToken)`, `LogoutRequest(RefreshToken)`, `ChangePasswordRequest(CurrentPassword, NewPassword)`, `TokenResponse(AccessToken, AccessTokenExpiresAt, RefreshToken, RefreshTokenExpiresAt)`.
   - Users: `CreateUserRequest(Email, Password, IReadOnlyList<Guid>? GroupIds, bool? IsActive)`, `UpdateUserRequest(Email)`, `AssignGroupsRequest(IReadOnlyList<Guid> GroupIds)`, `UserDto(Id, Email, IsActive, IsLockedOut, LockoutEnd, Groups, CreatedAt)`, `GroupRefDto(Id, Name)`.
   - Groups: `CreateGroupRequest(Name, Description, IReadOnlyList<string>? Permissions)`, `UpdateGroupRequest(Name, Description)`, `AssignPermissionsRequest(IReadOnlyList<string> Permissions)`, `GroupDto(Id, Name, Description, IsSystem, Permissions, UserCount)`, `PermissionDto(Code, Description)`.
2. Options:
   - `PasswordPolicyOptions { int MinLength = 10; }` (section `Password`)
   - `LockoutOptions { int MaxFailedAttempts = 5; int DurationMinutes = 15; }` (section `Lockout`)
3. Validator cho mọi request:
   - Email: `NotEmpty`, `EmailAddress`, `MaximumLength(256)`.
   - Mật khẩu mới: `NotEmpty`, `MinimumLength(options.MinLength)` (inject `IOptions<PasswordPolicyOptions>` vào validator), `NotEqual(CurrentPassword)` cho đổi mật khẩu.
   - Group name: `NotEmpty`, `MaximumLength(100)`; description `MaximumLength(500)`.
   - Query phân trang: `Page >= 1`, `1 <= PageSize <= 100`.
4. Helper `ValidateOrThrowAsync<T>(this IValidator<T> v, T request, CancellationToken ct)` ném `ValidationException` (của Application) với `Errors` nhóm theo tên field.
5. `Application/DependencyInjection.cs`:
   ```csharp
   public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration config)
   {
       services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);
       services.Configure<PasswordPolicyOptions>(config.GetSection("Password"));
       services.Configure<LockoutOptions>(config.GetSection("Lockout"));
       // services.AddScoped<AuthService>() ... (thêm dần ở T11–T16)
       return services;
   }
   ```
6. Unit test cho validator (`Application.Tests/Validators`): mỗi validator 1 case hợp lệ + các case sai chính.

## Tiêu chí hoàn thành
- [ ] Mỗi request có validator và test.
- [ ] DTO không chứa `PasswordHash` hay entity Domain.

## Lỗi hay gặp
- Trả thẳng entity `User` ra controller → lộ `PasswordHash`. Luôn map sang `UserDto`.

## Tham khảo
- https://docs.fluentvalidation.net/en/latest/
- https://learn.microsoft.com/aspnet/core/fundamentals/configuration/options
