# T23 — Xử lý exception tập trung, trả về ProblemDetails

> Giai đoạn 4 – WebAPI · Ước lượng: 1 ngày · Phụ thuộc: T09 · Layer: WebAPI

## Mục tiêu
Mọi exception được đổi thành response lỗi chuẩn ProblemDetails (RFC 7807) có thêm `code` và `traceId`, theo bảng ánh xạ ở tài liệu thiết kế mục II.1.

## Bối cảnh
Quy tắc dự án: không `try/catch` rải rác trong controller. Service chỉ việc ném exception đúng loại; middleware lo phần HTTP.

## Kiến thức cần có
- ASP.NET Core middleware pipeline, thứ tự middleware.
- `IExceptionHandler` (.NET 8+), `AddProblemDetails()`, `IProblemDetailsService`.
- RFC 7807 ProblemDetails.

## Việc cần làm
1. `WebAPI/Infrastructure/AppExceptionHandler.cs` implement `IExceptionHandler`:

   | Exception | Status | `code` |
   |---|---|---|
   | `ValidationException` (Application) | 400 | `VALIDATION_FAILED` + `errors` |
   | `DomainException` | 400 | `ex.Code` |
   | `UnauthorizedException` | 401 | `ex.Code` |
   | `NotFoundException` | 404 | `ex.Code` |
   | `ConflictException` | 409 | `ex.Code` |
   | còn lại | 500 | `INTERNAL_ERROR` — log `LogError(ex, ...)`, **không** trả `ex.Message`/stack trace |

   Ghi response bằng `IProblemDetailsService.TryWriteAsync(new ProblemDetailsContext { HttpContext, ProblemDetails, Exception })`. Với lỗi validate dùng `ValidationProblemDetails` (có sẵn thuộc tính `Errors`).
2. `Program.cs`:
   ```csharp
   builder.Services.AddProblemDetails(o => o.CustomizeProblemDetails = ctx =>
       ctx.ProblemDetails.Extensions.TryAdd("traceId", ctx.HttpContext.TraceIdentifier));
   builder.Services.AddExceptionHandler<AppExceptionHandler>();
   // ...
   app.UseExceptionHandler();   // đặt đầu pipeline
   app.UseStatusCodePages();    // 401/403/404 rỗng cũng trả ProblemDetails
   ```
3. Kiểm tra bằng một endpoint tạm ném từng loại exception (xóa trước khi merge) hoặc đợi test tích hợp T30.

## Tiêu chí hoàn thành
- [ ] Response lỗi có `type`, `title`, `status`, `detail`, `code`, `traceId`.
- [ ] Lỗi 500 không lộ thông tin nội bộ.
- [ ] Không controller nào có `try/catch`.

## Tham khảo
- https://learn.microsoft.com/aspnet/core/fundamentals/error-handling
- https://www.rfc-editor.org/rfc/rfc7807
