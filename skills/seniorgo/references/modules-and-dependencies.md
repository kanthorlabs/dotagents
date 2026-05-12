# Modules and Dependencies

## Module Initialization

```bash
go mod init example.com/mymodule
```

## go.mod File

```
module example.com/myproject

go 1.26

require (
    github.com/pkg/errors v0.9.1
)
```

## Ignore Directive (Go 1.25+)

Exclude directories from package patterns:

```
ignore (
    testdata
    examples
)
```

## Tool Dependencies (Go 1.24+)

```bash
go get -tool github.com/golangci/golangci-lint/cmd/golangci-lint
go tool golangci-lint run
```

## Project Layout

```
myproject/
├── cmd/
│   ├── server/       # main package for server binary
│   │   └── main.go
│   └── cli/          # main package for CLI binary
│       └── main.go
├── internal/         # private packages, not importable by other modules
│   ├── auth/
│   └── store/
├── go.mod
└── go.sum
```

`cmd/` holds main packages. `internal/` enforces import boundaries — compiler rejects imports from outside parent module.

## go.work for Workspaces

```
go 1.26

use (
    ./api
    ./web
    ./shared
)
```
