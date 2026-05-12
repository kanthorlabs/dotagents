# Formatting

Formatting is handled by `gofmt` (or `go fmt` at package level). Let the machine handle indentation, alignment, and spacing.

Key points:
- **Tabs for indentation** - `gofmt` emits tabs by default
- **No line length limit** - wrap long lines with extra tab indent
- **Fewer parentheses** - control structures (`if`, `for`, `switch`) have no parentheses in syntax

```go
// gofmt handles alignment automatically
type Config struct {
    Timeout     time.Duration
    MaxRetries  int
    EnableDebug bool
}
```
