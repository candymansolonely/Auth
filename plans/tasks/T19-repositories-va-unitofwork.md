# T19 — Repository và UnitOfWork

> Giai đoạn 3 – Infrastructure · Ước lượng: 1–1.5 ngày · Phụ thuộc: T09, T18 · Layer: Infrastructure

## Mục tiêu
Implement 4 repository và `UnitOfWork` theo đúng interface ở T09 bằng EF Core.

## Bối cảnh
Service ở Application chỉ gọi interface. Ở đây là nơi duy nhất viết truy vấn EF. Repository **không** gọi `SaveChanges` — chỉ `UnitOfWork` gọi, để một use case commit một lần.

## Kiến thức cần có
- LINQ to Entities: `Where`, `Include`/`ThenInclude`, `AnyAsync`, `CountAsync`, `Skip`/`Take`, `OrderBy`.
- `AsNoTracking` cho truy vấn chỉ đọc; khác biệt tracked vs untracked entity.
- `EF.Functions.ILike` (tìm kiếm không phân biệt hoa thường trong PostgreSQL).

## Việc cần làm
1. `Infrastructure/Persistence/Repositories/UserRepository.cs`:
   - `GetByIdAsync`, `GetByEmailAsync`: `Include(u => u.Groups).ThenInclude(g => g.Permissions)` (cần cho login và tính quyền).
   - `EmailExistsAsync(email, excludeUserId)`.
   - `GetPagedAsync`: lọc `Keyword` bằng `EF.Functions.ILike(u.Email, $"%{keyword}%")`, lọc `IsActive`, sắp xếp `CreatedAt` giảm dần, đếm tổng trước khi `Skip/Take`.
   - `CountActiveUsersInGroupAsync(groupName)`.
2. `GroupRepository`, `PermissionRepository`, `RefreshTokenRepository` theo interface.
3. `UnitOfWork : IUnitOfWork` gọi `_db.SaveChangesAsync(ct)`.
4. Kiểm tra thủ công bằng một endpoint tạm hoặc test tích hợp nhỏ (chính thức ở T29).

## Gợi ý
- Thoát ký tự `%` và `_` trong keyword trước khi đưa vào `ILike` để người dùng không gõ wildcard.
- Truy vấn danh sách dùng `AsNoTracking()`; truy vấn lấy entity để sửa thì **không** dùng.

## Tiêu chí hoàn thành
- [ ] Mọi method trong interface đã implement.
- [ ] Không repository nào gọi `SaveChangesAsync`.
- [ ] Không trả `IQueryable` ra ngoài.

## Tham khảo
- https://learn.microsoft.com/ef/core/querying/related-data/eager
- https://learn.microsoft.com/ef/core/querying/tracking
