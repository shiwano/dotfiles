#!/bin/bash

set -exu

GO111MODULE=off

go get -u github.com/hashicorp/hcl2/cmd/hclfmt
go get -u github.com/cweill/gotests/...
go get -u github.com/davidrjenni/reftools/cmd/fillstruct
go get -u golang.org/x/tools/cmd/goimports
go get -u github.com/wvanlint/twf/cmd/twf
go get -u github.com/go-delve/delve/cmd/dlv

go get -u github.com/nathany/looper
go get -u github.com/motemen/gore/cmd/gore
go get -u github.com/pwaller/goimports-update-ignore
