# Testing

## Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive", 2, 3, 5},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

## Benchmarks

```go
func BenchmarkProcess(b *testing.B) {
    for b.Loop() {  // Go 1.24+ - preferred
        Process(data)
    }
}
```

## Testing Concurrent Code (Go 1.25+)

```go
import "testing/synctest"

func TestConcurrent(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        ch := make(chan int)
        go func() {
            ch <- 42
        }()

        synctest.Wait()  // Wait for goroutines to block

        v := <-ch
        if v != 42 {
            t.Errorf("got %d, want 42", v)
        }
    })
}
```

## Race Detector

Built-in tool for finding data races — two goroutines access same variable concurrently with at least one write.

```bash
go test -race ./...
go run -race main.go
go build -race -o myapp
```

**CI integration** — always run `go test -race` in CI. Configure via `GORACE` env var:

```bash
GORACE="halt_on_error=1 exitcode=1" go test -race ./...
```

| GORACE Option | Default | Description |
|---------------|---------|-------------|
| `halt_on_error` | `0` | Exit on first race |
| `exitcode` | `66` | Exit code on race detected |
| `history_size` | `1` | Per-goroutine history (`32K * 2^val` elements) |
| `log_path` | `stderr` | Output path (`stdout`, `stderr`, or file) |

**Overhead:** 5-10x memory, 2-20x slower. Not for production builds.

**Common race patterns:**

- Loop counter captured by reference — pass as goroutine parameter
- Shared `err` variable across goroutines — use `:=` for local copy
- Unprotected global map — guard with `sync.Mutex` or use `sync.Map`
- Primitive variable (`int64`, `bool`) — use `sync/atomic`

## Test Helpers

```go
func TestWithResources(t *testing.T) {
    // t.TempDir — auto-cleaned temp directory
    dir := t.TempDir()
    os.WriteFile(filepath.Join(dir, "input.txt"), data, 0644)

    // t.Setenv — restores original value after test
    t.Setenv("DATABASE_URL", "postgres://localhost/test")

    // t.Cleanup — runs teardown in LIFO order after test
    db := openTestDB(t)
    t.Cleanup(func() { db.Close() })
}
```

## Test Artifacts (Go 1.26+)

```go
func TestGenerate(t *testing.T) {
    result := Generate()

    dir := t.ArtifactDir()
    os.WriteFile(filepath.Join(dir, "output.txt"), result, 0644)
}
```
