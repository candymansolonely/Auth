# T01 — Làm quen solution, chạy được API và PostgreSQL local

> Giai đoạn 0 – Chuẩn bị · Ước lượng: 0.5 ngày · Phụ thuộc: không · Layer: không sửa code

## Mục tiêu
Hiểu cấu trúc solution AuthenAtho, chạy được WebAPI trên máy, có một PostgreSQL local để các task sau dùng.

## Bối cảnh
Mọi task sau đều giả định bạn đã build/run được solution và có database. Task này không viết code nghiệp vụ, chỉ dựng môi trường và đọc tài liệu.

## Kiến thức cần có
- Dùng terminal cơ bản, `git` (clone, branch, commit).
- Khái niệm .NET SDK, `dotnet build` / `dotnet run`.
- Docker cơ bản (chạy container, map port) — hoặc cài PostgreSQL trực tiếp.

## Việc cần làm
1. Đọc lần lượt: `CLAUDE.md`, `.claude/rules/design.md`, `.claude/rules/workflow.md`, `.claude/rules/tech-defaults.md`.
2. Đọc plan gốc `plans/2026-10-06-authn-authz-account-management.md` và tài liệu thiết kế
   `../Docs/[AUTH] AuthenAtho - Module Xác thực, Phân quyền và Quản lý tài khoản.docx` (tính từ thư mục gốc repo; file nằm ngoài repo — xin lead nếu chưa có), đọc mục I và mục II.1.
3. Kiểm tra SDK: `dotnet --version` phải là 9.x.
4. Từ thư mục gốc (nơi có `AuthenAtho.slnx`): `dotnet build`, rồi `dotnet run --project WebAPI`.
   Mở `https://localhost:<port>/weatherforecast` (port xem trong `WebAPI/Properties/launchSettings.json`).
5. Chạy PostgreSQL local, ví dụ bằng Docker:
   ```bash
   docker run -d --name authenatho-pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16
   ```
6. Kết nối thử bằng `psql` hoặc DBeaver, tạo database `authenatho_dev`.
7. Cài công cụ EF Core CLI: `dotnet tool install --global dotnet-ef` (dùng ở T18).

## Tiêu chí hoàn thành
- [ ] `dotnet build` thành công, API trả về dữ liệu WeatherForecast.
- [ ] Kết nối được PostgreSQL local, có database `authenatho_dev`.
- [ ] Trả lời được bằng lời: 4 project là gì, project nào được reference project nào, và vì sao `Domain` không được reference project khác.

## Lỗi hay gặp
- Cổng 5432 đã bị chiếm do máy có PostgreSQL cài sẵn → đổi `-p 5433:5432` và nhớ port này.
- Chạy lệnh `dotnet` sai thư mục → luôn đứng ở thư mục chứa `AuthenAtho.slnx`.

## Tham khảo
- Clean Architecture tóm tắt: https://learn.microsoft.com/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures
