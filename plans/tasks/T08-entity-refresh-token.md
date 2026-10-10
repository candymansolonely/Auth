# T08 — Entity `RefreshToken`

> Giai đoạn 1 – Domain · Ước lượng: 0.5 ngày · Phụ thuộc: T04 · Layer: Domain

## Mục tiêu
Tạo entity lưu refresh token đã cấp (dạng hash), có hành vi `Revoke` và `IsActive`.

## Bối cảnh
Refresh token là chìa khóa để lấy access token mới, nên **không lưu bản gốc** trong DB — chỉ lưu hash (giống mật khẩu). Mỗi token chỉ dùng 1 lần: khi dùng thì bị thu hồi (`RevokedAt`) và ghi lại hash của token thay thế (`ReplacedByHash`) để truy vết chuỗi xoay vòng.

## Kiến thức cần có
- Khái niệm access token vs refresh token, vì sao refresh token phải xoay vòng (rotation).
- `DateTimeOffset`.

## Việc cần làm
1. `Domain/Entities/RefreshToken.cs`: `Id` (Guid), `UserId`, `TokenHash`, `ExpiresAt`, `CreatedAt`, `RevokedAt?`, `ReplacedByHash?`.
2. Constructor `RefreshToken(Guid userId, string tokenHash, DateTimeOffset createdAt, DateTimeOffset expiresAt)`; `expiresAt <= createdAt` → `DomainException`.
3. Method:
   - `bool IsRevoked => RevokedAt is not null;`
   - `bool IsExpired(DateTimeOffset now) => ExpiresAt <= now;`
   - `bool IsActive(DateTimeOffset now) => !IsRevoked && !IsExpired(now);`
   - `void Revoke(DateTimeOffset now, string? replacedByHash = null)` — đã revoke thì không ghi đè `RevokedAt` lần đầu.
4. Unit test: token mới là active; hết hạn → không active; revoke → không active và giữ `ReplacedByHash`; revoke 2 lần không đổi `RevokedAt`.

## Tiêu chí hoàn thành
- [ ] Test xanh.

## Tham khảo
- Tài liệu thiết kế: mục I.6 "Luồng xác thực tổng quan", mục II.3.
- OWASP – refresh token rotation: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
