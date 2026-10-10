# T31 — Kiểm tra cuối và cập nhật tài liệu dự án

> Giai đoạn 5 – Hoàn thiện · Ước lượng: 0.5 ngày · Phụ thuộc: T30 · Layer: toàn solution, tài liệu

## Mục tiêu
Chạy toàn bộ bước kiểm tra chất lượng, nghiệm thu thủ công một lượt, và cập nhật tài liệu cho khớp code.

## Kiến thức cần có
- `dotnet format`, `dotnet list package --vulnerable`.
- Đọc hiểu `CLAUDE.md` và `.claude/rules/`.

## Việc cần làm
1. Từ thư mục gốc:
   ```bash
   dotnet build
   dotnet test
   dotnet format --verify-no-changes
   dotnet list package --vulnerable --include-transitive
   ```
   (hoặc chạy skill `security-scan` nếu dùng Claude Code).
2. Nghiệm thu thủ công trên DB dev (`dotnet ef database update`, `dotnet run --project WebAPI`), theo bảng kịch bản mục III.2 tài liệu thiết kế, bằng `WebAPI.http` hoặc curl.
3. Cập nhật tài liệu:
   - `CLAUDE.md` mục **Database**: đã chốt PostgreSQL + EF Core (Npgsql), lệnh migration thực tế, cách set user-secrets.
   - `CLAUDE.md` mục **Commands/Architecture**: bỏ câu "solution is currently a bare scaffold", thêm các project test.
   - `.claude/rules/`: quy ước response lỗi ProblemDetails + `code`, quy ước route `/api/<resource>`, quy ước `[HasPermission]`.
4. Ghi các câu hỏi mở đã được trả lời vào plan gốc (mục Open questions) và tài liệu thiết kế.

## Tiêu chí hoàn thành
- [ ] 4 lệnh ở bước 1 đều qua.
- [ ] Mọi kịch bản thủ công đúng kỳ vọng.
- [ ] Tài liệu không còn mô tả sai so với code.

## Tham khảo
- Plan gốc: `plans/2026-10-06-authn-authz-account-management.md` mục Verification.
