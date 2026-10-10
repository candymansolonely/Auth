# T30 — Integration test cho các kịch bản nghiệm thu

> Giai đoạn 5 – Kiểm thử tích hợp · Ước lượng: 1–1.5 ngày · Phụ thuộc: T29 · Layer: Tests

## Mục tiêu
Tự động hóa các kịch bản nghiệm thu ở tài liệu thiết kế mục III.2 bằng integration test.

## Kiến thức cần có
- Như T29.
- Đọc và assert ProblemDetails (`code`, `status`).

## Việc cần làm
Viết test (mỗi kịch bản một `[Fact]`, chia file theo nhóm `AuthFlowTests`, `UsersApiTests`, `GroupsApiTests`):

| # | Kịch bản | Kỳ vọng |
|---|---|---|
| 1 | Admin login → `GET /api/users` | 200 |
| 2 | User không có `users.read` gọi `GET /api/users` | 403 |
| 3 | `GET /api/users` không token | 401 |
| 4 | Refresh với token hợp lệ | 200, token mới khác token cũ |
| 5 | Dùng lại refresh token cũ sau khi đã refresh | 401 `REFRESH_TOKEN_REUSED`; token mới nhất cũng không dùng được nữa |
| 6 | Admin khóa user → user đó login | 401 `ACCOUNT_DISABLED` |
| 7 | Sai mật khẩu 5 lần → login đúng mật khẩu | 401 `ACCOUNT_LOCKED` |
| 8 | Tạo user email đã tồn tại | 409 `EMAIL_ALREADY_EXISTS` |
| 9 | `PUT` / `DELETE` nhóm Administrator | 409 `SYSTEM_GROUP_PROTECTED` |
| 10 | Đổi mật khẩu → refresh bằng token cũ | 401 |
| 11 | Body sai định dạng (email rỗng) | 400 `VALIDATION_FAILED`, có `errors.email` |

Mỗi test tự tạo dữ liệu riêng (email ngẫu nhiên như `user-{Guid}@test.local`) để các test không ảnh hưởng nhau.

## Tiêu chí hoàn thành
- [ ] 11 test xanh, chạy lại nhiều lần vẫn xanh (không phụ thuộc thứ tự).

## Tham khảo
- Tài liệu thiết kế: mục III.2.
