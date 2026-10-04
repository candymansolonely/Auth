# Prompt: Dựng cấu trúc `.claude/` cho một project bất kỳ

File này chứa 1 prompt tái sử dụng được — copy toàn bộ phần trong khối "PROMPT" bên dưới,
điền các chỗ `{{...}}` (hoặc để nguyên và để Claude tự hỏi lại), rồi dán vào Claude Code
ở project mới để dựng bộ `.claude/` + `CLAUDE.md` tương tự project này.

---

## PROMPT

```
Hãy khảo sát project trong thư mục hiện tại rồi dựng cho tôi bộ nhớ/cấu hình cho Claude Code
gồm CLAUDE.md (ở ROOT repo, không đặt trong .claude/) và cây thư mục .claude/ sau:

.claude/
├── settings.json          # permissions + Claude Code hooks (team-shared, commit vào git)
├── settings.local.json    # override cá nhân, PHẢI thêm vào .gitignore
├── memory/                # ghi chú bền vững về project (quyết định kiến trúc, gotcha, incident)
├── rules/
│   ├── workflow.md        # quy trình dev, dispatch subagent, quy ước commit/push
│   ├── design.md          # quy tắc kiến trúc/layering + red flag khi review
│   └── tech-defaults.md   # thư viện/lựa chọn mặc định khi cần thêm dependency mới
├── agents/                # sub-agent chuyên dụng, mỗi file .md có frontmatter name/description/tools/model
├── skills/                # mỗi skill là 1 thư mục con có SKILL.md (frontmatter name/description) + script đi kèm
├── commands/              # (tuỳ chọn) custom slash command, mỗi file .md = 1 lệnh /ten-file
└── hooks/                 # GIT hooks thật (pre-commit.sh, pre-push.sh...), khác với Claude Code hooks trong settings.json

Và ở root: CLAUDE.local.md (ghi chú riêng tư, KHÔNG push — gitignore).

Trước khi viết file, hãy:

1. Tự khảo sát project để xác định:
   - Ngôn ngữ / framework / package manager (đọc file build: package.json, *.csproj,
     pom.xml, requirements.txt/pyproject.toml, go.mod, Cargo.toml, v.v.)
   - Kiến trúc hiện có (layered, Clean Architecture, MVC, monorepo nhiều package...) —
     suy ra từ cấu trúc thư mục thật, đừng đoán bừa.
   - Lệnh build/run/test thật sự chạy được (thử chạy nếu cần) — không bịa lệnh.
   - Có test project/framework nào chưa; có migration/database nào đã cấu hình chưa.
   - Có git repo chưa, có remote chưa, nhánh mặc định là gì.

2. Nếu có điểm mơ hồ ảnh hưởng tới nội dung sinh ra (vd: chưa rõ convention đặt tên,
   chưa rõ có dùng test framework nào, DB nào), HỎI LẠI tôi thay vì tự suy diễn — đặc biệt
   với các mục trong CLAUDE.md có thể sai sự thật nếu đoán (tech stack, database).
   Đừng khẳng định trong CLAUDE.md những gì project CHƯA thực sự có — ghi rõ "đề xuất
   mặc định, chưa chốt" nếu chỉ là gợi ý.

3. CLAUDE.md viết theo các mục sau (bỏ mục nào không áp dụng được cho project, đừng để
   placeholder rỗng):
   - Tech Stack
   - Commands (lệnh build/run/test thật, kèm giải thích ngắn)
   - Architecture (mô tả layering/kiến trúc thật + hướng dependency nếu có)
   - Cấu trúc thư mục
   - Quy tắc code (dependency injection style, test coverage kỳ vọng, logging, error
     handling convention... theo đúng ngôn ngữ/framework của project)
   - Quy trình làm việc (build trước khi code, test trước khi commit, convention commit)
   - Không được làm (danh sách cấm cụ thể cho project này — không phải danh sách chung
     chung copy từ project khác)
   - Database (nếu có — cách chạy migration, connection string dev nằm ở đâu)
   - Plans (nếu project dùng thư mục plans/ cho feature lớn — tạo plans/README.md nếu
     chưa có)
   - Rules / Memory / Specialized subagents / Skills — trỏ tới các thư mục tương ứng
     trong .claude/ vừa tạo

4. agents/ — tạo tối thiểu các vai trò sau, điều chỉnh tool/scope theo project:
   - 1 agent nghiên cứu/business analyst (read-only, viết plan)
   - 1 agent researcher kỹ thuật (read-only, research thư viện/best practice)
   - 1 agent coder (được Edit/Write/Bash, implement)
   - 1 agent tester (viết & chạy test)
   - 1 agent reviewer (read-only, review diff theo rules/design.md)
   Mỗi file .md phải có frontmatter: name, description (nêu RÕ khi nào dùng agent này,
   để Claude tự dispatch đúng), tools, model.

5. skills/ — chỉ tạo skill THỰC SỰ hữu ích cho project này (vd: security/dependency
   scan đúng với package manager của project, không copy skill của domain khác — ví dụ
   đừng tạo skill "đặt hàng Amazon" cho 1 project backend). Mỗi skill là thư mục riêng
   với SKILL.md (frontmatter name + description) và script thật chạy được, đã test thử.

6. hooks/ — phân biệt rõ 2 loại, đừng gộp lẫn:
   - Git hooks thật (.claude/hooks/pre-commit.sh, pre-push.sh...) — chạy khi user
     commit/push. Sau khi tạo, chạy `git config core.hooksPath .claude/hooks` và
     `chmod +x` các script, rồi TEST THỬ (vd: `dotnet test` / `npm test` khi chưa có gì
     để test không được lỗi) trước khi coi là xong.
   - Claude Code hooks thật (khai báo trong settings.json, key "hooks", chạy theo event
     PreToolUse/PostToolUse/Stop/... của chính Claude Code) — chỉ thêm nếu có nhu cầu cụ
     thể (vd: auto-format file vừa Edit), không thêm cho có.

7. .gitignore — thêm (nếu chưa có) ít nhất:
   CLAUDE.local.md
   .claude/settings.local.json
   .env / .env.local / các file secret thật của stack này

8. Sau khi dựng xong: liệt kê lại toàn bộ file đã tạo, chạy git status để tôi xem diff
   trước khi quyết định có commit hay không — ĐỪNG tự ý commit/push nếu tôi chưa yêu cầu.

Nếu project đã có sẵn 1 phần cấu trúc trên, đọc kỹ nội dung hiện có trước, bổ sung/điều
chỉnh thay vì ghi đè vô điều kiện, và hỏi lại nếu việc ghi đè có thể mất nội dung quan
trọng đã có.
```

---

## Ghi chú khi dùng lại prompt này

- Đây là prompt rút ra từ quá trình dựng `.claude/` cho project AuthenAtho (.NET Clean
  Architecture) — đã validated thực tế trên project đó, không phải lý thuyết suông.
- Những cạm bẫy đã gặp và prompt trên đã xử lý:
  - Nhầm `.claude/hooks/*.sh` (git hooks) với Claude Code's own `settings.json` hooks —
    hai cơ chế khác nhau hoàn toàn.
  - Đặt nhầm `CLAUDE.md`/`CLAUDE.local.md` vào trong `.claude/` — Claude Code chỉ tự
    load `CLAUDE.md` khi nó nằm ở root repo.
  - Copy nguyên xi 1 sơ đồ/template từ project khác (skill không liên quan, DB chưa
    chốt mà ghi như đã chốt) — prompt trên bắt phải khảo sát thật + hỏi lại khi mơ hồ.
  - `.claude/skills/<name>/SKILL.md` đúng format thật (frontmatter + thư mục riêng),
    không phải file `.md` rời rạc.
- Nếu dùng cho project không phải .NET, phần "Quy tắc code" / "Database" / tên agent sẽ
  tự đổi theo stack thật — không cần sửa tay prompt, Claude sẽ tự khảo sát.
