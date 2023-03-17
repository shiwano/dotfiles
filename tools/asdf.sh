#!/bin/bash

set -eu
cd "$(dirname $0)"

asdf plugin add jq https://github.com/AZMCode/asdf-jq.git || true
asdf plugin add kubectl || true
asdf plugin add kustomize || true
asdf plugin add kubesec || true
asdf plugin add helm || true
asdf plugin add helmfile || true
asdf plugin add yq || true
asdf plugin add terraform || true
asdf plugin add direnv || true
asdf plugin add ruby || true
asdf plugin add flutter || true

asdf install
