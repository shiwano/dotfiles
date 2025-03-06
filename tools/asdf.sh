#!/bin/bash

set -eu
cd "$(dirname $0)"

asdf plugin-add jq https://github.com/AZMCode/asdf-jq.git
asdf plugin-add kubectl
asdf plugin-add kustomize
asdf plugin-add kubesec
asdf plugin-add helm
asdf plugin-add helmfile
asdf plugin-add yq
asdf plugin-add terraform
asdf plugin-add direnv
asdf plugin-add ruby
asdf plugin-add flutter
asdf plugin-add nodejs
asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git

asdf install
asdf reshim
