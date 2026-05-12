#!/bin/bash
set -e
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
