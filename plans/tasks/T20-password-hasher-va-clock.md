# T20 — `PasswordHasher` (BCrypt) và `SystemClock`

> Giai đoạn 3 – Infrastructure · Ước lượng: 0.5 ngày · Phụ thuộc: T09, T03 (BCrypt đã được duyệt) · Layer: Infrastructure

## Mục tiêu
Implement `IPasswordHasher` bằng BCrypt.Net-Next và `IClock` bằng giờ hệ thống, có unit test.

## Bối cảnh
Mật khẩu không bao giờ được lưu dạng gốc hay mã hóa hai chiều. BCrypt là hàm băm chậm có salt, chống dò mật khẩu. Bọc sau interface để sau này đổi sang Argon2 không ảnh hưởng Application.

> ⚠️ Câu hỏi mở số 5: lead chưa chốt BCrypt.Net-Next. Nếu đổi thư viện, chỉ task này thay đổi.

## Kiến thức cần có
- Hashing vs encryption; salt; work factor.
- Vì sao không tự viết hàm băm (SHA-256) cho mật khẩu.

## Việc cần làm
1. `Infrastructure/Security/BCryptPasswordHasher.cs`:
   ```csharp
   public sealed class BCryptPasswordHasher : IPasswordHasher
   {
       private const int WorkFactor = 12;
       public string Hash(string password) => BCrypt.Net.BCrypt.EnhancedHashPassword(password, WorkFactor);
       public bool Verify(string password, string hash) => BCrypt.Net.BCrypt.EnhancedVerify(password, hash);
   }
   ```
2. `Infrastructure/Time/SystemClock.cs`: `UtcNow => DateTimeOffset.UtcNow`.
3. Tạo project `tests/Infrastructure.Tests` (nếu lead đồng ý) hoặc đặt test tạm trong `Application.Tests` với reference phù hợp — **hỏi lead**. Test:
   - Hash 2 lần cùng mật khẩu → 2 chuỗi khác nhau (do salt).
   - `Verify` đúng mật khẩu → true; sai → false.

## Tiêu chí hoàn thành
- [ ] Test xanh.
- [ ] Không có chỗ nào log mật khẩu.

## Tham khảo
- OWASP Password Storage: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
- https://github.com/BcryptNet/bcrypt.net
