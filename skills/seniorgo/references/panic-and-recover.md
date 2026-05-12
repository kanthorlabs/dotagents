# Panic and Recover

Use panic only for unrecoverable errors:

```go
func init() {
    if config == nil {
        panic("configuration not loaded")
    }
}
```

Recover in deferred functions:

```go
func safeCall(fn func()) (err error) {
    defer func() {
        if r := recover(); r != nil {
            err = fmt.Errorf("panic: %v", r)
        }
    }()
    fn()
    return nil
}
```
