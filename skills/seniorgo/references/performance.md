# Performance

## Profiling

```go
import "runtime/pprof"

f, _ := os.Create("cpu.prof")
pprof.StartCPUProfile(f)
defer pprof.StopCPUProfile()
```

## Flight Recorder (Go 1.25+)

```go
import "runtime/trace"

fr := trace.NewFlightRecorder()
fr.SetPeriod(10 * time.Second)
if err := fr.Start(); err != nil {
    log.Fatal(err)
}
// ... run application ...
f, _ := os.Create("trace.out")
n, err := fr.WriteTo(f) // Capture buffered trace data
```

## Memory Efficiency

Use `sync.Pool` for frequently allocated objects:

```go
var bufPool = sync.Pool{
    New: func() any {
        return new(bytes.Buffer)
    },
}
```

## Resource Cleanup (Go 1.24+)

`runtime.AddCleanup` replaces `runtime.SetFinalizer` — attaches cleanup function to object, runs after GC collects it. Supports multiple cleanups, no resurrection issues.

```go
import "runtime"

type FileHandle struct {
    fd int
}

func NewFileHandle(fd int) *FileHandle {
    h := &FileHandle{fd: fd}
    runtime.AddCleanup(h, func(fd int) {
        syscall.Close(fd)
    }, h.fd)
    return h
}
```

## Green Tea GC (Go 1.26)

Enabled by default. 10-40% reduction in GC overhead.

## Container-Aware GOMAXPROCS (Go 1.25+)

Runtime respects cgroup CPU limits automatically on Linux.

## Goroutine Leak Detection (Go 1.26+)

```bash
GOEXPERIMENT=goroutineleakprofile go build
```

Access via `/debug/pprof/goroutineleak`.
