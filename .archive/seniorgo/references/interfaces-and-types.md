# Interfaces and Types

Interfaces specify behavior. Types implement interfaces implicitly:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Compose interfaces
type ReadWriter interface {
    Reader
    Writer
}
```

## Type Assertions

```go
str, ok := value.(string)
if !ok {
    // value is not a string
}
```

## Interface Checks

Compile-time verification:

```go
var _ json.Marshaler = (*MyType)(nil)
```
