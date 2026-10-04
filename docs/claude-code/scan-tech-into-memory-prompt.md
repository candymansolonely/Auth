# Prompt: Quét công nghệ/convention/cách giải quyết vấn đề thật trong code → ghi vào `.claude/memory/`

Prompt tái sử dụng được cho project này hoặc bất kỳ project nào khác dùng Claude Code.
Dán nguyên khối "PROMPT" bên dưới vào Claude Code khi muốn nó rà lại toàn bộ codebase và
chốt lại những gì đang thực sự được dùng (công nghệ ngoài, format code, cách xử lý vấn đề
đặc thù) thành các file memory ngắn gọn, có dẫn chứng, để các lần làm việc sau không phải
dò lại từ đầu.

Khác với [setup-dot-claude-prompt.md](setup-dot-claude-prompt.md) (dựng bộ khung `.claude/`
lần đầu) và agent `doc-architect` (viết RULE bắt buộc tuân theo cho API/pattern/messaging),
prompt này tập trung vào **ghi nhận hiện trạng** (memory, mang tính mô tả "đang có gì, ở
đâu, dùng sao") — có thể chạy định kỳ để memory không bị lạc hậu so với code.

---

## PROMPT

```
Hãy rà soát toàn bộ codebase hiện tại (không chỉ đọc README/doc có sẵn — đọc code thật,
package manifest thật, config thật) để tìm ra những thứ ĐANG THỰC SỰ được dùng trong dự
án, rồi ghi lại thành các file trong `.claude/memory/`. Chỉ ghi nhận cái có bằng chứng cụ
thể trong code — không đoán, không liệt kê cái "có vẻ sẽ cần".

Tìm theo 3 nhóm:

1. **Công nghệ/dịch vụ ngoài cụ thể đang được tích hợp thật** — ví dụ (không giới hạn):
   Kafka, RabbitMQ, Redis, Supabase, Firebase, Stripe/VNPay/Momo, Auth0/Keycloak,
   SendGrid/Twilio, S3/MinIO/Azure Blob, Elasticsearch, gRPC, GraphQL, WebSocket/SignalR...
   Cách xác nhận: tìm trong file quản lý dependency thật (package.json, *.csproj,
   packages.lock.json, pom.xml, requirements.txt/pyproject.toml, go.mod, Cargo.toml...)
   VÀ xác nhận có code thực sự import/khởi tạo client của nó (không chỉ khai báo package
   rồi không dùng). Nếu thấy package được khai báo nhưng grep không ra chỗ nào dùng thật,
   đừng ghi nhận là "đang dùng" — liệt kê riêng ra để hỏi lại tôi.

2. **Format code / convention đang thực sự được enforce** — đọc file cấu hình thật
   (.editorconfig, eslint/.prettierrc, stylecop.json, ktlint config, ruff/black config...)
   và đối chiếu với code thật xem convention đó có được tuân theo nhất quán không. Nếu
   không có file config nhưng code thể hiện 1 convention lặp lại rõ ràng (vd: luôn đặt
   tên file theo PascalCase, luôn tổ chức DTO theo 1 cấu trúc nhất định), ghi nhận đó là
   "convention ngầm" (implicit), nêu rõ chưa có config enforce.

3. **Cách giải quyết vấn đề đặc thù của dự án** — pattern lặp lại để xử lý 1 vấn đề cụ
   thể theo cách riêng của dự án này, ví dụ: retry/backoff, idempotency key, outbox
   pattern, circuit breaker, rate limiting, soft delete, multi-tenancy, feature flag,
   cách xử lý transaction phân tán, cách versioning API, cách xử lý lỗi tập trung. Chỉ
   ghi nhận khi thấy pattern đó xuất hiện ở ít nhất 1 chỗ cụ thể trong code — kèm
   file:line làm bằng chứng.

Với MỖI mục tìm được, tạo 1 file riêng trong `.claude/memory/` (tạo thư mục này nếu chưa
có), tên file kebab-case mô tả đúng chủ đề (vd: `kafka-event-publishing.md`,
`supabase-auth-integration.md`, `api-error-handling-pattern.md`). Nội dung mỗi file gồm:

- **Vai trò trong dự án**: dùng để làm gì, tại layer/module nào.
- **Bằng chứng**: file:line hoặc tên class/function cụ thể trong code thật.
- **Convention cần theo khi viết code mới liên quan** (naming, cách khởi tạo/inject,
  cách test/mock, lỗi thường gặp nếu làm sai cách).
- **Ngày phát hiện** (để biết memory còn mới hay đã cũ khi đọc lại sau này).

Quy tắc:
- Không tạo file cho công nghệ "lỡ cài nhưng không dùng" — chỉ liệt kê ra để hỏi lại tôi
  có muốn gỡ dependency đó không.
- Nếu phát hiện 2 cách làm khác nhau cho cùng 1 vấn đề ở 2 chỗ khác nhau trong code (vd:
  2 kiểu kết nối Redis, 2 format response lỗi khác nhau), ghi nhận CẢ HAI trong cùng 1
  file, đánh dấu rõ cái nào mới hơn/nên dùng tiếp, và báo cho tôi biết sự không nhất
  quán này — đừng tự chọn 1 cái rồi coi như cái kia không tồn tại.
- Không sửa code, không sửa file ngoài `.claude/memory/` (nếu muốn biến phát hiện thành
  RULE bắt buộc tuân theo thay vì chỉ ghi nhận, nói tôi biết để dùng agent `doc-architect`
  việc đó khác với việc ghi memory).
- Sau khi xong, cập nhật `.claude/memory/README.md` thêm 1 dòng index ngắn cho mỗi file
  mới (tên file + 1 câu mô tả), và liệt kê lại toàn bộ file đã tạo/cập nhật cho tôi xem
  — không tự ý commit.
```

---

## Ghi chú

- Prompt này nên chạy lại định kỳ (sau khi thêm tích hợp mới, hoặc trước khi onboard
  thành viên mới vào dự án) để `.claude/memory/` không bị lạc hậu so với code thật.
- Nếu chạy lại và thấy 1 file memory cũ không còn đúng với code hiện tại (vd: đã gỡ
  Kafka, chuyển sang công nghệ khác), yêu cầu Claude cập nhật/xoá file đó thay vì để tồn
  tại thông tin sai.
