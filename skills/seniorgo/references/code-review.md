# Code Review Comments

Common review comments for Go code. Checklist format — use as shorthand during reviews.

## Contexts

- First parameter: `func F(ctx context.Context, ...)`
- Don't store `context.Context` in structs — pass as parameter
- Use `context.Background()` only when truly not request-scoped
- Contexts are immutable — safe to pass same ctx to multiple calls

## Copying

Don't copy a value of type `T` if methods are on `*T`. Copied structs with slices/maps may alias the original's underlying data:

```go
// Bad: buf2's slice may alias buf1's internal array
buf2 := buf1

// Good: explicit copy
var buf2 bytes.Buffer
buf2.Write(buf1.Bytes())
```

## Declaring Empty Slices

```go
var t []string    // preferred — nil slice
t := []string{}   // non-nil, zero-length — only when JSON encoding needs []
```

## Error Strings

Lowercase, no punctuation — they get composed into larger messages:

```go
fmt.Errorf("something bad")       // good
fmt.Errorf("Something bad.")      // bad
```

## Goroutine Lifetimes

Make it clear when goroutines exit. Blocked goroutines are never GC'd. Prefer goroutines whose lifetime is obvious from the code; document non-obvious cases.

## Handle Errors

Never discard errors with `_`. Check, return, or handle every error.

## Imports

Group with blank lines: stdlib first, then external. Avoid renaming unless collision. Use `goimports`.

```go
import (
    "fmt"
    "os"

    "github.com/foo/bar"
)
```

**Import blank** (`import _ "pkg"`): only in main package or tests.

**Import dot** (`import . "pkg"`): only for circular test dependencies. Never in non-test code.

## In-Band Errors

Don't return sentinel values (-1, "", nil) to signal errors. Use multiple returns:

```go
// Bad
func Lookup(key string) string          // returns "" on miss

// Good
func Lookup(key string) (string, bool)  // ok=false on miss
```

## Indent Error Flow

Keep happy path at minimal indentation. Handle errors first and return early:

```go
// Bad
if err != nil {
    // error handling
} else {
    // normal code
}

// Good
if err != nil {
    return err
}
// normal code
```

## Initialisms

Consistent case for acronyms: `URL` or `url`, never `Url`. `ID` not `Id`. `HTTP` not `Http`.

```go
ServeHTTP    // not ServeHttp
xmlHTTPRequest  // multiple initialisms
appID        // not appId
```

## Interfaces

Define in consumer package, not producer. Return concrete types from producers. Don't define interfaces before they are used. Don't define interfaces "for mocking."

```go
// Good: interface in consumer
package consumer
type Thinger interface { Thing() bool }
func Foo(t Thinger) string { ... }

// Good: concrete type in producer
package producer
type Thinger struct{ ... }
func NewThinger() Thinger { return Thinger{} }
```

## Line Length

No rigid limit. Break lines by semantics, not character count. Long lines often signal long names — fix the names.

## Named Result Parameters

Use when meaning isn't clear from types alone. Don't use just to enable naked returns or avoid declaring vars:

```go
// Unnecessary — types are clear
func (n *Node) Parent() (node *Node, err error)

// Better
func (n *Node) Parent() (*Node, error)

// Useful — disambiguates same-type returns
func (f *Foo) Location() (lat, long float64, err error)
```

## Naked Returns

Only in short functions (handful of lines). In longer functions, be explicit.

## Package Comments

Adjacent to package clause, no blank line:

```go
// Package math provides basic constants and mathematical functions.
package math
```

## Pass Values

Don't use pointers just to save bytes. If a function only dereferences `*x`, pass `x` directly. Applies to `string`, interface values, small structs. Does not apply to large structs.

## Receiver Names

Short (1-2 letters), consistent across methods. Not "self", "this", or "me":

```go
func (c *Client) Get() {}   // good
func (cl *Client) Set() {}  // bad — inconsistent with Get
func (self *Client) Do() {} // bad — not Go style
```

## Receiver Type

When in doubt, use pointer. Use value receiver when:

- Small immutable struct (like `time.Time`)
- Basic types (`int`, `string`)
- No mutation needed

Must use pointer when:

- Method mutates receiver
- Struct contains `sync.Mutex` or similar
- Large struct or array
- Elements are pointers to mutable data

Don't mix receiver types on a type.

## Synchronous Functions

Prefer synchronous over async. Let callers add concurrency — it's easy to add, hard to remove.

## Useful Test Failures

Include: what was tested, inputs, got, want. Use `got != want` order:

```go
if got != tt.want {
    t.Errorf("Foo(%q) = %d; want %d", tt.in, got, tt.want)
}
```

## Variable Names

Short for local scope, descriptive for distant usage. `c` not `lineCount` for locals. `i` not `sliceIndex` for loop indices. Further from declaration = more descriptive.
