# Data

## Allocation with new

`new(T)` allocates zeroed storage, returns `*T`.

**Go 1.26+**: `new` accepts value expression for initialization:

```go
age := new(25)        // *int pointing to 25
name := new("Alice")  // *string pointing to "Alice"

type Person struct {
    Name string
    Age  *int
}
p := Person{Name: "Bob", Age: new(30)}
```

## Allocation with make

`make(T, args)` creates slices, maps, and channels only. Returns initialized value of type `T` (not `*T`):

```go
slice := make([]int, 10, 100)  // len=10, cap=100
m := make(map[string]int)
ch := make(chan int, 10)       // buffered
```

## Slices

Use `append` for growing:

```go
slice = append(slice, elem1, elem2)
slice = append(slice, otherSlice...)
```

**Concatenate slices** (Go 1.22+):

```go
import "slices"
combined := slices.Concat(slice1, slice2, slice3)
```

## Embedding Files

`//go:embed` embeds files into binary at compile time. Import `embed` package (even if using only directive).

```go
import "embed"

//go:embed schema.sql
var schema string

//go:embed config.json
var configBytes []byte

//go:embed templates/*
var templateFS embed.FS

// Use with fs interfaces
entries, _ := templateFS.ReadDir("templates")
data, _ := templateFS.ReadFile("templates/index.html")
```

## Maps

```go
m := make(map[string]int)
value, ok := m["key"]
if !ok {
    // key not present
}
delete(m, "key")
```
