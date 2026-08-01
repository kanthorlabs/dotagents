# Semicolons

Semicolons are inserted automatically by the lexer. Never put opening brace on new line:

```go
// Correct
if x > 0 {
    return x
}

// Wrong - semicolon inserted before brace
if x > 0
{
    return x
}
```
