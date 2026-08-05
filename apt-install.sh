#!/bin/bash

set -euo pipefail

# Keeps /run/user/$UID present from boot, which WSLg does not always create.
# Elsewhere pam_systemd covers it, so linger would only add side effects.
enable_linger() {
	if ! grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
		return 0
	fi

	if [ ! -d /run/systemd/system ] || ! command -v loginctl >/dev/null 2>&1; then
		return 0
	fi

	if loginctl show-user "${USER}" --property=Linger --value 2>/dev/null |
		grep -qx 'yes'; then
		echo "Linger already enabled for ${USER}"
		return 0
	fi

	echo "Enabling linger for ${USER}"
	sudo loginctl enable-linger "${USER}"
}

main() {
	sudo apt update

	sudo apt install -y \
		language-pack-en \
		language-pack-ja \
		build-essential \
		curl \
		unzip \
		bubblewrap \
		inotify-tools \
		fcitx5 \
		fcitx5-mozc \
		fonts-ipafont \
		fonts-noto-cjk \
		fonts-takao \
		librsvg2-common \
		adwaita-icon-theme \
		desktop-file-utils \
		wl-clipboard \
		xclip

	sudo update-desktop-database

	enable_linger
}

main "$@"
