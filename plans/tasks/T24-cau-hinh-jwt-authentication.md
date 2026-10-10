# T24 — Cấu hình JWT authentication và `ICurrentUser`

> Giai đoạn 4 – WebAPI · Ước lượng: 1 ngày · Phụ thuộc: T21, T22 · Layer: WebAPI

## Mục tiêu
WebAPI xác thực được access token do `JwtTokenService` cấp, và cung cấp `ICurrentUser` cho tầng Application.

## Bối cảnh
`Program.cs` là composition root — nơi duy nhất ghép Application + Infrastructure. Thứ tự `UseAuthentication()` trước `UseAuthorization()` là bắt buộc.

## Kiến thức cần có
- Authentication vs Authorization trong ASP.NET Core; authentication scheme.
- `TokenValidationParameters`; `ClaimsPrincipal`, claim.
- `IHttpContextAccessor`.

## Việc cần làm
1. `Program.cs`:
   ```csharp
   builder.Services.AddApplication(builder.Configuration);
   builder.Services.AddInfrastructure(builder.Configuration);

   var jwt = builder.Configuration.GetSection("Jwt").Get<JwtOptions>()!;
   builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
       .AddJwtBearer(o =>
       {
           o.MapInboundClaims = false; // giữ nguyên tên claim "sub", "permission"
           o.TokenValidationParameters = new TokenValidationParameters
           {
               ValidateIssuer = true, ValidIssuer = jwt.Issuer,
               ValidateAudience = true, ValidAudience = jwt.Audience,
               ValidateIssuerSigningKey = true,
               IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SigningKey)),
               ValidateLifetime = true, ClockSkew = TimeSpan.FromSeconds(30),
               NameClaimType = "sub",
           };
       });
   builder.Services.AddAuthorization();
   // ...
   app.UseAuthentication();
   app.UseAuthorization();
   ```
2. `appsettings.json`: thêm section `Jwt` (Issuer/Audience = `AuthenAtho`, `SigningKey` để rỗng), `Lockout`, `Password`, `Seed` (rỗng). Giá trị bí mật nằm trong user-secrets (T22).
3. `WebAPI/Infrastructure/CurrentUser.cs : ICurrentUser` đọc claim `sub` từ `IHttpContextAccessor.HttpContext.User`; đăng ký `AddHttpContextAccessor()` + `AddScoped<ICurrentUser, CurrentUser>()`.
4. Kiểm tra: tạo tạm endpoint `[Authorize] GET /api/me` trả `sub`; gọi không token → 401; gọi với token lấy từ `JwtTokenService` → 200. Xóa endpoint tạm sau khi có `AuthController`.

## Tiêu chí hoàn thành
- [ ] Không token → 401; token sai chữ ký hoặc hết hạn → 401.
- [ ] `ICurrentUser.UserId` trả đúng id khi có token.

## Lỗi hay gặp
- Quên `MapInboundClaims = false` → `sub` bị đổi thành `http://schemas.xmlsoap.org/.../nameidentifier`, đọc claim `sub` ra null.

## Tham khảo
- https://learn.microsoft.com/aspnet/core/security/authentication/configure-jwt-bearer-authentication
