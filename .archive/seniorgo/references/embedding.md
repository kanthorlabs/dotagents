# Embedding

## Struct Embedding

```go
type ReadWriter struct {
    *bufio.Reader
    *bufio.Writer
}
// ReadWriter has methods of both Reader and Writer
```

## Interface Embedding

```go
type ReadWriteCloser interface {
    io.Reader
    io.Writer
    io.Closer
}
```
