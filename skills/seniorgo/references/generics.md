# Generics

Go 1.18+ supports type parameters on functions and types.

## Generic Functions

```go
func Min[T cmp.Ordered](a, b T) T {
    if a < b {
        return a
    }
    return b
}
```

## Generic Types

```go
type Stack[T any] struct {
    items []T
}

func (s *Stack[T]) Push(item T) {
    s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T
        return zero, false
    }
    item := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return item, true
}
```

## When to Use Generics

Use type parameters when you find yourself writing the exact same code multiple times where only the types differ.

**Good uses:**

- Operating on slices, maps, channels where element type doesn't matter
- General-purpose data structures (trees, queues, caches)
- Implementing a common method that looks identical across types

```go
// Good: same logic for any map type
func Keys[K comparable, V any](m map[K]V) []K {
    s := make([]K, 0, len(m))
    for k := range m {
        s = append(s, k)
    }
    return s
}
```

**Don't use type parameters when:**

- You're just calling a method on the value — use an interface instead
- Implementations differ per type — use interface + separate implementations
- Reflection is more appropriate (e.g., encoding/json)

```go
// Bad: type parameter adds nothing over interface
func ReadSome[T io.Reader](r T) ([]byte, error)

// Good: just use the interface
func ReadSome(r io.Reader) ([]byte, error)
```

**Prefer functions over method constraints** — requiring a `Less` method forces users to wrap simple types. Accept a comparison function instead:

```go
// Easier to use: pass a func
type Tree[T any] struct {
    cmp  func(T, T) int
    root *node[T]
}
```

## Generic Type Aliases (Go 1.24+)

```go
type MyMap[K comparable, V any] = map[K]V
type StringMap[V any] = MyMap[string, V]
```

## Self-Referential Generics (Go 1.26+)

```go
type Adder[A Adder[A]] interface {
    Add(A) A
}
```
