# T07 — Logic khóa tạm thời khi đăng nhập sai (lockout) trên `User`

> Giai đoạn 1 – Domain · Ước lượng: 0.5 ngày · Phụ thuộc: T06 · Layer: Domain

## Mục tiêu
Thêm vào `User` các method `RegisterFailedLogin`, `ResetFailedLogin`, `IsLockedOut` và test đầy đủ các mốc thời gian.

## Bối cảnh
Chống dò mật khẩu: sai liên tiếp N lần (đề xuất 5) thì khóa M phút (đề xuất 15). Hai con số này là cấu hình (T21/T22 sẽ bind từ `appsettings`), nên entity nhận chúng qua tham số, không hard-code.

## Kiến thức cần có
- `DateTimeOffset`, `TimeSpan`, so sánh thời gian.
- `[Theory]` + `[InlineData]` trong xUnit để test nhiều trường hợp.

## Việc cần làm
1. Thêm vào `User`:
   ```csharp
   public bool IsLockedOut(DateTimeOffset now) => LockoutEnd is not null && LockoutEnd > now;

   public void RegisterFailedLogin(DateTimeOffset now, int maxFailedAttempts, TimeSpan lockoutDuration)
   {
       // tăng FailedAccessCount; nếu >= maxFailedAttempts:
       //   LockoutEnd = now + lockoutDuration; FailedAccessCount = 0
   }

   public void ResetFailedLogin() { /* FailedAccessCount = 0; LockoutEnd = null */ }
   ```
2. Validate tham số: `maxFailedAttempts <= 0` hoặc `lockoutDuration <= TimeSpan.Zero` → `ArgumentOutOfRangeException`.
3. Unit test:
   - Sai 4 lần (max 5) → chưa bị khóa, `FailedAccessCount = 4`.
   - Sai lần thứ 5 → `IsLockedOut(now)` = true, `FailedAccessCount = 0`.
   - `IsLockedOut(now + 14 phút 59 giây)` = true; `IsLockedOut(now + 15 phút)` = false.
   - `ResetFailedLogin` xóa cả đếm và `LockoutEnd`.

## Tiêu chí hoàn thành
- [ ] Test các mốc biên (đúng 15 phút) xanh.

## Lỗi hay gặp
- Dùng `>=` thay `>` khi so `LockoutEnd` với `now` → lệch mốc biên. Viết test biên trước rồi mới code.

## Tham khảo
- Tài liệu thiết kế: mục II.2 "Nghiệp vụ đăng nhập", bước 5.
