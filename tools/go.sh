#!/bin/bash

set -exu

go install github.com/hashicorp/hcl/v2/cmd/hclfmt@latest
go install github.com/cweill/gotests/...@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/gopls@latest
go install github.com/x-motemen/gore/cmd/gore@latest
go install github.com/pwaller/goimports-update-ignore@latest
go install goa.design/goa/v3/cmd/goa@v3
