#!/bin/bash

set -euo pipefail

topic() {
	printf "\033[1;34m%s\033[0m\n" "$*"
}

ensure_dir() {
	local dir=$1
	if [ -d "${dir}" ]; then
		echo "$(basename "${dir}") already exists"
	else
		echo "Creating $(basename "${dir}")"
		mkdir -p "${dir}"
	fi
}

echo_link() {
	local src=$1
	local dest=$2
	local action=${3:-Linking}
	echo "${action}" "${src/$HOME/~}" '->' "${dest/$HOME/~}"
}

setup_zenhan() (
	local install_dir="${HOME}/.local/bin"
	local exe_path="${install_dir}/zenhan.exe"
	if [ -x "${exe_path}" ] && [ ! -L "${exe_path}" ]; then
		echo "zenhan.exe already installed"
		return 0
	fi

	local temp_dir
	temp_dir="$(mktemp -d)"
	trap 'rm -rf "${temp_dir}"' EXIT

	local url="https://github.com/iuchim/zenhan/releases/download/v0.0.1/zenhan.zip"
	local sha256="057e4ad47163c31d530a695353958e989200381b048c1e4f1bd8b40a97c20e28"
	curl -fL --retry 2 "${url}" -o "${temp_dir}/zenhan.zip"
	printf '%s  %s\n' "${sha256}" "${temp_dir}/zenhan.zip" | sha256sum --check
	unzip -q "${temp_dir}/zenhan.zip" -d "${temp_dir}"
	mkdir -p "${install_dir}"
	cp --remove-destination "${temp_dir}/zenhan/bin64/zenhan.exe" "${exe_path}"
	chmod +x "${exe_path}"
	echo "Installed: ${exe_path}"
	return 0
)

main() {
	local dotfiles_dir=$HOME/dotfiles

	topic 'Clone the repository'

	if [ -d "${dotfiles_dir}" ]; then
		echo 'dotfiles repository already exists'
	else
		git clone git@github.com:shiwano/dotfiles.git "${dotfiles_dir}"
	fi

	topic 'Setup dotdirs'

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type d -name 'dot.*' | grep -v 'example' | while IFS= read -r dotdir; do
		local destdir
		destdir="$HOME/$(basename "${dotdir}" | sed -e 's/^dot\./\./')"
		ensure_dir "${destdir}"

		find "${dotdir}" -maxdepth 1 -mindepth 1 | grep -v '.DS_Store' | while IFS= read -r src; do
			echo_link "${src}" "${destdir}"
			ln -sf "${src}" "${destdir}"
		done
	done

	topic 'Setup dotfiles'

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*' | grep -v 'example' | while IFS= read -r dotfile; do
		local dest
		dest="$HOME/$(basename "${dotfile}" | sed -e 's/^dot\./\./')"
		echo_link "${dotfile}" "${dest}"
		ln -sfn "${dotfile}" "${dest}"
	done

	topic 'Setup example files'

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name '*.example' | while IFS= read -r dotfile; do
		local dest
		dest="$HOME/$(basename "${dotfile}" | sed -e 's/^dot\./\./' | sed -e 's/\.example$//')"
		if [ ! -f "${dest}" ]; then
			echo_link "${dotfile}" "${dest}" 'Copying'
			cp "${dotfile}" "${dest}"
		else
			echo_link "${dotfile}" "${dest}" 'Already copied'
		fi
	done

	if command -v bat >/dev/null 2>&1; then
		topic 'Setup bat'

		(
			cd "$(bat --config-dir)/themes"
			bat cache --build
		)
		(
			cd "$(bat --config-dir)/syntaxes"
			bat cache --build
		)
	fi

	if command -v fcitx5 >/dev/null 2>&1; then
		topic 'Setup fcitx5'
		fcitx5 -r -d
	fi

	if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
		topic 'Setup Windows IME'
		setup_zenhan
	fi
}

main "$@"
