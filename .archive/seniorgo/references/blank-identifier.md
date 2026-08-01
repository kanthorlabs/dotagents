# The Blank Identifier

Discard unwanted values:

```go
_, err := io.Copy(dst, src)

for _, v := range slice { }
```

## Import for Side Effect

```go
import _ "net/http/pprof"
```

## Interface Satisfaction Check

```go
var _ io.Reader = (*MyReader)(nil)
```
