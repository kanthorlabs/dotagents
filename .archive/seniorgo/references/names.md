# Names

## Package Names

Package names should be lowercase, single-word, concise, and evocative. The package name becomes the accessor for contents:

```go
import "encoding/json"
json.Marshal(v)  // Not encoding_json.Marshal
```

Avoid repetition - `bufio.Reader`, not `bufio.BufReader`.

## Abbreviations

Abbreviate only when familiar to the programmer:

- `strconv` (string conversion), `syscall`, `fmt` (formatted I/O) — OK
- Ambiguous or unclear abbreviations — don't

Don't steal good variable names. Buffered I/O is `bufio`, not `buf`, since `buf` is a common variable name for buffers.

## Naming Package Contents

Client code uses package name as prefix, so don't repeat it:

```go
http.Server     // not http.HTTPServer
http.Get        // not http.HTTPGet
```

When function returns `pkg.Pkg` type, omit the type name:

```go
list.New()              // returns *list.List
time.Now()              // returns time.Time
context.WithTimeout()   // returns context.Context
```

When function returns `pkg.T` where T is not Pkg, include T:

```go
time.ParseDuration()    // returns time.Duration
time.NewTicker()        // returns *time.Ticker
```

## Bad Package Names

Avoid `util`, `common`, `misc`, `helpers`, `api`, `types` — they provide no context, grow without bound, and collide with other imports.

Fix by extracting into focused packages:

```go
// Bad
util.NewStringSet("a", "b")
util.SortStringSet(set)

// Good — pull into its own package
stringset.New("a", "b")
set.Sort()
```

Don't put all APIs in one package. Don't reuse standard library names (`io`, `http`, `os`).

## Getters and Setters

No automatic support for getters/setters. If you have field `owner`, getter is `Owner()`, setter is `SetOwner()`:

```go
func (c *Config) Timeout() time.Duration { return c.timeout }
func (c *Config) SetTimeout(d time.Duration) { c.timeout = d }
```

## Interface Names

One-method interfaces use method name + `-er` suffix: `Reader`, `Writer`, `Stringer`, `Marshaler`.

## MixedCaps

Use `MixedCaps` or `mixedCaps`, not underscores.
