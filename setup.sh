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

main() {
	local dotfiles_dir=$HOME/dotfiles

	topic 'Clone the repository'

	if [ -d "${dotfiles_dir}" ]; then
		echo 'dotfiles repository already exists'
	else
		git clone git@github.com:shiwano/dotfiles.git "${dotfiles_dir}"
	fi

	topic 'Setup bin directory'

	local local_bin_dir=$HOME/bin
	ensure_dir "${local_bin_dir}"

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

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*.example' | while IFS= read -r dotfile; do
		local dest
		dest="$HOME/$(basename "${dotfile}" | sed -e 's/^dot\./\./' | sed -e 's/\.example//')"
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
}

main "$@"
