# T14 — `UserService`: danh sách, chi tiết, tạo, cập nhật

> Giai đoạn 2 – Application · Ước lượng: 1 ngày · Phụ thuộc: T10 · Layer: Application

## Mục tiêu
Cài đặt 4 use case quản lý tài khoản cơ bản và mapping entity → `UserDto`.

## Bối cảnh
Quản trị viên tạo tài khoản cho người dùng (đề xuất: không cho tự đăng ký công khai — câu hỏi mở số 3). Không có xóa tài khoản; dùng khóa (T15).

## Kiến thức cần có
- Mapping thủ công entity → DTO (không cần AutoMapper).
- HTTP 201 Created và header `Location` (để hiểu controller sẽ dùng kết quả thế nào ở T27).

## Việc cần làm
1. `Application/Users/UserService.cs`, inject: `IUserRepository`, `IGroupRepository`, `IPasswordHasher`, `IUnitOfWork`, `IClock`, các validator.
2. Method:
   - `GetPagedAsync(UserQuery q, ct)` → `PagedResult<UserDto>`.
   - `GetByIdAsync(Guid id, ct)` → `UserDto`; không thấy → `NotFoundException(USER_NOT_FOUND)`.
   - `CreateAsync(CreateUserRequest r, ct)`:
     validate → email (đã chuẩn hóa) tồn tại → `ConflictException(EMAIL_ALREADY_EXISTS)` → nếu có `GroupIds`: `GetByIdsAsync`, thiếu id nào → `NotFoundException(GROUP_NOT_FOUND)` → `new User(email, hasher.Hash(password), now)`, gán nhóm, `IsActive=false` nếu request yêu cầu → `Add` → lưu → trả `UserDto`.
   - `UpdateAsync(Guid id, UpdateUserRequest r, ct)`: email trùng user **khác** → `EMAIL_ALREADY_EXISTS`.
3. Mapping `UserMapper.ToDto(User u, DateTimeOffset now)` (cần `now` để tính `IsLockedOut`).
4. Đăng ký `AddScoped<UserService>()`.
5. Unit test cho từng method: thành công + từng nhánh lỗi; kiểm tra mật khẩu được băm (repository nhận user có `PasswordHash` = kết quả của `hasher.Hash`).

## Tiêu chí hoàn thành
- [ ] Mỗi public method có test thành công + test lỗi.
- [ ] `UserDto` không có `PasswordHash`.

## Tham khảo
- Tài liệu thiết kế: mục II.6.1–6.4.
