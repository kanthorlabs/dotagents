# Iterators

Go 1.23+ supports range-over-function iterators.

## Iterator Function Signatures

```go
func(yield func() bool)           // No values
func(yield func(V) bool)          // Single value
func(yield func(K, V) bool)       // Key-value pairs
```

## Using Iterators

```go
import "slices"

for v := range slices.Values(mySlice) {
    fmt.Println(v)
}

import "maps"
for k := range maps.Keys(myMap) {
    fmt.Println(k)
}
```

## Creating Custom Iterators

```go
func Fibonacci(n int) iter.Seq[int] {
    return func(yield func(int) bool) {
        a, b := 0, 1
        for i := 0; i < n; i++ {
            if !yield(a) {
                return
            }
            a, b = b, a+b
        }
    }
}
```

## Reflection Iterators (Go 1.26+)

```go
import "reflect"

t := reflect.TypeOf(MyStruct{})
for field := range t.Fields() {
    fmt.Println(field.Name, field.Type)
}
```
