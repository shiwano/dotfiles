#!/bin/bash

set -euo pipefail

main() {
	sudo apt update

	sudo apt install -y \
		language-pack-en \
		language-pack-ja \
		build-essential \
		curl \
		unzip \
		bubblewrap \
		fcitx5 \
		fcitx5-mozc \
		fonts-ipafont \
		fonts-noto-cjk \
		fonts-takao \
		librsvg2-common \
		adwaita-icon-theme \
		wl-clipboard \
		xclip
}

main "$@"
