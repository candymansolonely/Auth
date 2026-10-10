# T25 — Phân quyền endpoint theo permission (`[HasPermission]`)

> Giai đoạn 4 – WebAPI · Ước lượng: 1 ngày · Phụ thuộc: T24, T04 · Layer: WebAPI

## Mục tiêu
Viết attribute `[HasPermission(Permissions.X)]` để chặn endpoint theo mã quyền: thiếu quyền → 403.

## Bối cảnh
Không thể khai báo trước một policy cho từng quyền bằng tay (sẽ quên khi thêm quyền mới). Thay vào đó policy được dựng động từ tên: `perm:users.read` → policy yêu cầu claim `permission = users.read`.

## Kiến thức cần có
- Policy-based authorization: `IAuthorizationRequirement`, `AuthorizationHandler<T>`, `IAuthorizationPolicyProvider`.
- Kế thừa attribute (`AuthorizeAttribute`).

## Việc cần làm
1. `WebAPI/Authorization/HasPermissionAttribute.cs`:
   ```csharp
   public sealed class HasPermissionAttribute(string permission)
       : AuthorizeAttribute(PolicyPrefix + permission)
   {
       public const string PolicyPrefix = "perm:";
   }
   ```
2. `PermissionRequirement(string Permission) : IAuthorizationRequirement`.
3. `PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>` — `Succeed` khi `context.User.HasClaim("permission", requirement.Permission)`.
4. `PermissionPolicyProvider : DefaultAuthorizationPolicyProvider`:
   ```csharp
   public override async Task<AuthorizationPolicy?> GetPolicyAsync(string policyName)
   {
       if (policyName.StartsWith(HasPermissionAttribute.PolicyPrefix, StringComparison.Ordinal))
       {
           var code = policyName[HasPermissionAttribute.PolicyPrefix.Length..];
           return new AuthorizationPolicyBuilder()
               .RequireAuthenticatedUser()
               .AddRequirements(new PermissionRequirement(code))
               .Build();
       }
       return await base.GetPolicyAsync(policyName);
   }
   ```
5. Đăng ký: `AddSingleton<IAuthorizationPolicyProvider, PermissionPolicyProvider>()`, `AddSingleton<IAuthorizationHandler, PermissionAuthorizationHandler>()`.
6. Unit test cho handler (tạo `ClaimsPrincipal` bằng tay): có claim → succeed; không có → không succeed. Test provider: tên `perm:x` → policy có `PermissionRequirement("x")`; tên khác → chuyển cho base.

## Tiêu chí hoàn thành
- [ ] Test xanh (đặt trong `WebAPI.IntegrationTests` hoặc project test riêng — hỏi lead).
- [ ] Mọi chỗ dùng attribute đều truyền hằng số `Permissions.*`, không truyền chuỗi viết tay.

## Tham khảo
- https://learn.microsoft.com/aspnet/core/security/authorization/iauthorizationpolicyprovider
- Tài liệu thiết kế: mục II.9.
