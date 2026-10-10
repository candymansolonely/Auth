# T02 — Tạo các project unit test

> Giai đoạn 0 – Chuẩn bị · Ước lượng: 0.5 ngày · Phụ thuộc: T01 · Layer: Tests

## Mục tiêu
Tạo `Domain.Tests` và `Application.Tests` (xUnit), thêm vào `AuthenAtho.slnx`, có 1 test mẫu chạy xanh bằng `dotnet test`.

## Bối cảnh
Quy tắc dự án: mỗi public method ở Application phải có unit test. Có project test sẵn thì các task Domain/Application viết test ngay trong task đó.

## Kiến thức cần có
- xUnit cơ bản: `[Fact]`, `[Theory]` + `[InlineData]`, `Assert.*`.
- Cấu trúc test Arrange – Act – Assert.
- Lệnh `dotnet new`, `dotnet sln add`, `dotnet add reference`.

## Việc cần làm
1. Tạo project:
   ```bash
   dotnet new xunit -n Domain.Tests -o tests/Domain.Tests -f net9.0
   dotnet new xunit -n Application.Tests -o tests/Application.Tests -f net9.0
   dotnet sln AuthenAtho.slnx add tests/Domain.Tests/Domain.Tests.csproj tests/Application.Tests/Application.Tests.csproj
   ```
2. Reference:
   - `Domain.Tests` → `Domain`.
   - `Application.Tests` → `Application` và `Domain`.
3. Thêm thư viện mock cho `Application.Tests`: NSubstitute (hoặc Moq — chọn 1 và dùng thống nhất, hỏi lead nếu chưa rõ).
4. Bật `<Nullable>enable</Nullable>` trong 2 file `.csproj` test.
5. Xóa `UnitTest1.cs` mẫu, viết 1 test thật đơn giản (ví dụ `Assert.True(true)` tạm thời, sẽ thay ở T04).
6. Chạy `dotnet test` ở thư mục gốc.

## Tiêu chí hoàn thành
- [ ] `AuthenAtho.slnx` có 2 project test.
- [ ] `dotnet test` chạy và báo 0 lỗi.
- [ ] Project test không reference `Infrastructure` hay `WebAPI`.

## Lỗi hay gặp
- Template xunit tạo `net8.0` → nhớ `-f net9.0` hoặc sửa `TargetFramework`.
- Quên `dotnet sln add` → `dotnet test` ở root không chạy test mới.

## Tham khảo
- https://learn.microsoft.com/dotnet/core/testing/unit-testing-with-dotnet-test
- NSubstitute: https://nsubstitute.github.io/help/getting-started/
