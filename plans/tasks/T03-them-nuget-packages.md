# T03 — Thêm các NuGet package cần dùng

> Giai đoạn 0 – Chuẩn bị · Ước lượng: 0.5 ngày · Phụ thuộc: T01 · Layer: Application, Infrastructure, WebAPI

## Mục tiêu
Thêm đúng package vào đúng project, solution vẫn build xanh.

## Bối cảnh
Dự án quy định không tự ý thêm dependency ngoài danh sách đã duyệt (`CLAUDE.md`, `.claude/rules/tech-defaults.md`). Đặt package sai layer sẽ phá vỡ Clean Architecture (ví dụ EF Core lọt vào Application).

## Kiến thức cần có
- NuGet và lệnh `dotnet add <project> package <tên>`.
- Hiểu vì sao package hạ tầng (EF Core, BCrypt, JWT) chỉ nằm ở Infrastructure/WebAPI.

## Việc cần làm
Chọn phiên bản ổn định mới nhất tương thích .NET 9 (với package Microsoft/EF Core: dòng `9.0.x`).

| Project | Package | Dùng cho |
|---|---|---|
| Application | `FluentValidation`, `FluentValidation.DependencyInjectionExtensions` | Validate request (T10) |
| Application | `Microsoft.Extensions.Options`, `Microsoft.Extensions.Logging.Abstractions` (nếu chưa có) | Options, `ILogger<T>` |
| Infrastructure | `Npgsql.EntityFrameworkCore.PostgreSQL` | EF Core + PostgreSQL (T17) |
| Infrastructure | `Microsoft.EntityFrameworkCore.Design` | Tạo migration (T18) |
| Infrastructure | `BCrypt.Net-Next` | Băm mật khẩu (T20) — **chờ lead xác nhận** |
| Infrastructure | `Microsoft.IdentityModel.JsonWebTokens` | Tạo JWT (T21) — **hỏi lead trước**, cùng họ thư viện với JwtBearer |
| WebAPI | `Microsoft.AspNetCore.Authentication.JwtBearer` | Xác thực JWT (T24) |
| WebAPI | `Microsoft.EntityFrameworkCore.Design` | Chạy `dotnet ef` với startup project WebAPI |

Sau khi thêm: `dotnet build`, rồi chạy skill/lệnh kiểm tra lỗ hổng: `dotnet list package --vulnerable`.

## Tiêu chí hoàn thành
- [ ] `Domain.csproj` không có PackageReference nào.
- [ ] `Application.csproj` không có EF Core, BCrypt, JWT.
- [ ] `dotnet build` xanh, `dotnet list package --vulnerable` không báo lỗi nghiêm trọng.
- [ ] Ghi lại trong PR các package đang "chờ xác nhận".

## Lỗi hay gặp
- Trộn phiên bản EF Core (ví dụ 9.0.1 và 9.0.8) giữa các project → lỗi lúc chạy migration. Dùng cùng một phiên bản.

## Tham khảo
- https://learn.microsoft.com/nuget/consume-packages/install-use-packages-dotnet-cli
