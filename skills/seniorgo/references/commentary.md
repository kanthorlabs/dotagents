# Commentary

Go uses C-style `/* */` block comments and C++ style `//` line comments. Line comments are the norm.

Doc comments appear before top-level declarations with no intervening newlines:

```go
// Package math provides basic constants and mathematical functions.
package math

// Pi is the ratio of a circle's circumference to its diameter.
const Pi = 3.14159265358979323846
```

For detailed guidance, see [Go Doc Comments](https://go.dev/doc/comment).
