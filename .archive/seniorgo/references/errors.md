# Errors

## Error Interface

```go
type error interface {
    Error() string
}
```

## Creating Errors

```go
import "errors"

var ErrNotFound = errors.New("not found")

func process(id int) error {
    if id < 0 {
        return fmt.Errorf("invalid id: %d", id)
    }
    return nil
}
```

## Error Wrapping

```go
if err != nil {
    return fmt.Errorf("processing failed: %w", err)
}

// Unwrap
if errors.Is(err, ErrNotFound) { }

var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println(pathErr.Path)
}
```

## Sentinel Errors

```go
var (
    ErrNotFound    = errors.New("not found")
    ErrPermission  = errors.New("permission denied")
)
```
