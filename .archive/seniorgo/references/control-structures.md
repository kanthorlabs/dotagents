# Control Structures

## If

Accept initialization statement:

```go
if err := file.Chmod(0664); err != nil {
    return err
}
```

Avoid unnecessary else when body ends in `return`:

```go
f, err := os.Open(name)
if err != nil {
    return err
}
// continue with f
```

## For

Three forms, no `while` or `do-while`:

```go
for init; condition; post { }  // C-style
for condition { }              // while
for { }                        // infinite
```

**Range over integers** (Go 1.22+):

```go
for i := range 10 {
    fmt.Println(i)  // 0 through 9
}
```

**Loop variable semantics** (Go 1.22+): Loop variables are created fresh each iteration, preventing closure capture bugs.

## Switch

More flexible than C - expressions need not be constants. No automatic fallthrough. Use comma for multiple cases:

```go
switch c {
case ' ', '\t', '\n':
    return true
}
```

## Type Switch

```go
switch v := x.(type) {
case string:
    return v
case int:
    return strconv.Itoa(v)
default:
    return fmt.Sprint(v)
}
```
