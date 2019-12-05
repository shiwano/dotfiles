#!/bin/bash

set -exu

GO111MODULE=off

go get -u github.com/nathany/looper
go get -u github.com/motemen/gore
go get -u github.com/cweill/gotests/...
go get -u github.com/golang/dep/cmd/dep
go get -u github.com/saibing/bingo
go get -u github.com/go-delve/delve/cmd/dlv
go get -u github.com/hashicorp/hcl2/cmd/hclfmt
