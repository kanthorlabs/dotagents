# Methods

## Pointer vs Value Receivers

Value methods can be invoked on pointers and values. Pointer methods can only be invoked on pointers:

```go
type Counter int

func (c Counter) Value() int    { return int(c) }
func (c *Counter) Increment()   { *c++ }

var c Counter
c.Increment()      // Compiler rewrites to (&c).Increment()
fmt.Println(c.Value())
```

Use pointer receiver when:
- Method modifies receiver
- Receiver is large struct
- Consistency with other methods
