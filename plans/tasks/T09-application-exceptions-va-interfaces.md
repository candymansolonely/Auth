# T09 — Exception nghiệp vụ và các interface của tầng Application

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T05–T08 · Layer: Application

## Mục tiêu
Khai báo toàn bộ "hợp đồng" (interface) mà Application cần từ bên ngoài, cùng bộ exception nghiệp vụ và danh sách mã lỗi. Chưa có implementation.

## Bối cảnh
Application chỉ biết **interface**, không biết EF Core, BCrypt hay JWT là gì. Infrastructure (giai đoạn 3) sẽ implement các interface này. Nhờ vậy service ở T11–T16 test được bằng mock mà không cần DB.

## Kiến thức cần có
- Dependency Inversion (chữ D trong SOLID), interface trong C#.
- `async`/`await`, `Task<T>`, `CancellationToken`.
- Repository pattern và Unit of Work.

## Việc cần làm
1. `Application/Common/Exceptions/`:
   - `AppException(string code, string message)` (abstract, có `Code`).
   - `NotFoundException`, `ConflictException`, `UnauthorizedException` kế thừa `AppException`.
   - `ValidationException` có thêm `IReadOnlyDictionary<string, string[]> Errors`, code mặc định `VALIDATION_FAILED`.
2. `Application/Common/Exceptions/ErrorCodes.cs` — hằng số cho mọi mã lỗi trong tài liệu thiết kế:
   `INVALID_CREDENTIALS`, `ACCOUNT_DISABLED`, `ACCOUNT_LOCKED`, `INVALID_REFRESH_TOKEN`, `REFRESH_TOKEN_REUSED`,
   `INVALID_CURRENT_PASSWORD`, `USER_NOT_FOUND`, `GROUP_NOT_FOUND`, `EMAIL_ALREADY_EXISTS`, `CANNOT_DEACTIVATE_SELF`,
   `LAST_ADMIN_PROTECTED`, `PERMISSION_NOT_FOUND`, `GROUP_NAME_EXISTS`, `SYSTEM_GROUP_PROTECTED`, `GROUP_IN_USE`, `VALIDATION_FAILED`.
3. `Application/Abstractions/` — interface (gợi ý chữ ký, có thể điều chỉnh khi làm, nhưng ghi rõ trong PR):
   ```csharp
   public interface IClock { DateTimeOffset UtcNow { get; } }
   public interface ICurrentUser { Guid? UserId { get; } bool IsAuthenticated { get; } }
   public interface IPasswordHasher { string Hash(string password); bool Verify(string password, string hash); }
   public interface IUnitOfWork { Task SaveChangesAsync(CancellationToken ct); }

   public sealed record AccessTokenResult(string Token, DateTimeOffset ExpiresAt);
   public sealed record RefreshTokenResult(string Token, string TokenHash, DateTimeOffset ExpiresAt);
   public interface ITokenService
   {
       AccessTokenResult CreateAccessToken(User user, IReadOnlyCollection<string> permissions);
       RefreshTokenResult CreateRefreshToken();
       string HashRefreshToken(string token);
   }

   public interface IUserRepository
   {
       Task<User?> GetByIdAsync(Guid id, CancellationToken ct);        // kèm Groups + Permissions
       Task<User?> GetByEmailAsync(string normalizedEmail, CancellationToken ct);
       Task<bool> EmailExistsAsync(string normalizedEmail, Guid? excludeUserId, CancellationToken ct);
       Task<PagedResult<User>> GetPagedAsync(UserQuery query, CancellationToken ct);
       Task<int> CountActiveUsersInGroupAsync(string groupName, CancellationToken ct);
       void Add(User user);
   }
   public interface IGroupRepository
   {
       Task<Group?> GetByIdAsync(Guid id, CancellationToken ct);       // kèm Permissions
       Task<IReadOnlyList<Group>> GetByIdsAsync(IReadOnlyCollection<Guid> ids, CancellationToken ct);
       Task<bool> NameExistsAsync(string name, Guid? excludeGroupId, CancellationToken ct);
       Task<bool> HasMembersAsync(Guid groupId, CancellationToken ct);
       Task<int> CountMembersAsync(Guid groupId, CancellationToken ct);
       Task<PagedResult<Group>> GetPagedAsync(GroupQuery query, CancellationToken ct);
       void Add(Group group);
       void Remove(Group group);
   }
   public interface IPermissionRepository
   {
       Task<IReadOnlyList<Permission>> GetAllAsync(CancellationToken ct);
       Task<IReadOnlyList<Permission>> GetByCodesAsync(IReadOnlyCollection<string> codes, CancellationToken ct);
   }
   public interface IRefreshTokenRepository
   {
       Task<RefreshToken?> GetByHashAsync(string tokenHash, CancellationToken ct);
       Task<IReadOnlyList<RefreshToken>> GetActiveByUserIdAsync(Guid userId, DateTimeOffset now, CancellationToken ct);
       void Add(RefreshToken token);
   }
   ```
4. `Application/Common/PagedResult.cs`: `record PagedResult<T>(IReadOnlyList<T> Items, int Page, int PageSize, int TotalCount)`;
   `UserQuery(int Page, int PageSize, string? Keyword, bool? IsActive)`, `GroupQuery(int Page, int PageSize, string? Keyword)`.

## Tiêu chí hoàn thành
- [ ] `dotnet build` xanh.
- [ ] Không interface nào có kiểu của EF Core (`DbSet`, `IQueryable`, `DbContext`) hay ASP.NET (`HttpContext`) trong chữ ký.
- [ ] Reviewer xác nhận chữ ký interface trước khi bắt đầu T11.

## Lỗi hay gặp
- Trả `IQueryable<User>` từ repository cho "tiện" → rò rỉ EF ra Application. Không được.
- Đặt tên `ValidationException` trùng với `FluentValidation.ValidationException` → dùng namespace đầy đủ hoặc alias `using`.

## Tham khảo
- `.claude/rules/design.md` (red flags).
