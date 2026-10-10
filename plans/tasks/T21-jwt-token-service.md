# T21 — `JwtOptions` và `JwtTokenService`

> Giai đoạn 3 – Infrastructure · Ước lượng: 1 ngày · Phụ thuộc: T09, T03 · Layer: Infrastructure

## Mục tiêu
Implement `ITokenService`: tạo access token JWT (HMAC-SHA256) chứa claim quyền, sinh refresh token ngẫu nhiên và băm refresh token.

## Bối cảnh
Access token mang theo danh sách quyền để WebAPI kiểm tra mà không cần truy vấn DB mỗi request. Refresh token chỉ là chuỗi ngẫu nhiên đủ dài; DB lưu hash SHA-256 của nó (SHA-256 phù hợp ở đây vì token ngẫu nhiên entropy cao — khác mật khẩu).

## Kiến thức cần có
- Cấu trúc JWT, các claim chuẩn: `sub`, `jti`, `iat`, `exp`, `iss`, `aud`.
- Khóa đối xứng (symmetric key), vì sao khóa phải ≥ 32 byte và để trong secret.
- `RandomNumberGenerator`, `SHA256`, Base64Url.

## Việc cần làm
1. `Infrastructure/Security/JwtOptions.cs` (section `Jwt`): `Issuer`, `Audience`, `SigningKey`, `AccessTokenMinutes = 15`, `RefreshTokenDays = 7`. Validate khi khởi động: `SigningKey` ≥ 32 byte (dùng `services.AddOptions<JwtOptions>().Bind(...).Validate(...).ValidateOnStart()`).
2. `Infrastructure/Security/JwtTokenService.cs`:
   - `CreateAccessToken(user, permissions)`:
     claims `sub` = `user.Id`, `email`, `jti` = Guid mới, mỗi quyền một claim `permission`; `Expires = clock.UtcNow + AccessTokenMinutes`; ký bằng `SigningCredentials(new SymmetricSecurityKey(bytes), SecurityAlgorithms.HmacSha256)`; tạo chuỗi bằng `JsonWebTokenHandler.CreateToken(SecurityTokenDescriptor)`.
   - `CreateRefreshToken()`: `RandomNumberGenerator.GetBytes(32)` → `Base64Url.EncodeToString(...)` (namespace `System.Buffers.Text`, có sẵn trong .NET 9); trả kèm `TokenHash` và `ExpiresAt`.
   - `HashRefreshToken(token)`: `Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)))`.
3. Unit test:
   - Đọc lại token bằng `JsonWebTokenHandler.ReadJsonWebToken` → có đúng `sub`, `email`, đủ claim `permission`, `exp` ≈ now + 15 phút.
   - `ValidateTokenAsync` với đúng key → hợp lệ; sai key → không hợp lệ.
   - Hai lần `CreateRefreshToken` → khác nhau; `HashRefreshToken` cùng input → cùng output.

## Tiêu chí hoàn thành
- [ ] Test xanh.
- [ ] Không có signing key nào trong `appsettings*.json` được commit (chỉ để giá trị rỗng/placeholder).

## Lỗi hay gặp
- Dùng `IClock` cho `Expires` nhưng `NotBefore`/`IssuedAt` vẫn lấy giờ thật → khi test với FakeClock token "chưa có hiệu lực". Đặt cả `IssuedAt`, `NotBefore` từ `IClock`.

## Tham khảo
- https://jwt.io/introduction
- https://learn.microsoft.com/dotnet/api/microsoft.identitymodel.jsonwebtokens.jsonwebtokenhandler
