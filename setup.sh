#!/bin/bash

set -euo pipefail

topic() {
	printf "\033[1;34m%s\033[0m\n" "$*"
}

main() {
	local dotfiles_dir=$HOME/dotfiles

	topic 'Clone the repository'

	if [ -d "${dotfiles_dir}" ]; then
		echo 'dotfiles repository already exists'
	else
		git clone git@github.com:shiwano/dotfiles.git "${dotfiles_dir}"
	fi

	topic 'Create bin directory'

	local local_bin_dir=$HOME/bin
	if [ -d "${local_bin_dir}" ]; then
		echo 'bin directory already exists'
	else
		echo 'Creating bin directory'
		mkdir -p "${local_bin_dir}"
	fi

	topic 'Setup .config directory'

	local local_dotconfig_dir=$HOME/.config
	mkdir -p "${local_dotconfig_dir}"

	find "${dotfiles_dir}/dot.config" -maxdepth 1 -mindepth 1 | grep -v '.DS_Store' | while IFS= read -r src; do
		echo 'Linking' "${src}" '->' "${local_dotconfig_dir}"
		ln -sf "${src}" "${local_dotconfig_dir}"
	done

	topic 'Setup dotdirs'

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type d -name 'dot.*' | grep -v 'example' | while IFS= read -r dotdir; do
		if [ "$(basename "${dotdir}")" = 'dot.config' ]; then
			continue
		fi
		local dest
		dest="$HOME/$(basename "${dotdir}" | sed -e 's/^dot\./\./')"
		echo 'Linking' "${dotdir}" '->' "${dest}"
		ln -sfn "${dotdir}" "${dest}"
	done

	topic 'Setup dotfiles'

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*' | grep -v 'example' | while IFS= read -r dotfile; do
		local dest
		dest="$HOME/$(basename "${dotfile}" | sed -e 's/^dot\./\./')"
		echo 'Linking' "${dotfile}" '->' "${dest}"
		ln -sfn "${dotfile}" "${dest}"
	done

	find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*.example' | while IFS= read -r dotfile; do
		local dest
		dest="$HOME/$(basename "${dotfile}" | sed -e 's/^dot\./\./' | sed -e 's/\.example//')"
		if [ ! -f "${dest}" ]; then
			echo 'Copying' "${dotfile}" '->' "${dest}"
			cp "${dotfile}" "${dest}"
		else
			echo 'Already copied' "${dotfile}" '->' "${dest}"
		fi
	done

	topic 'Setup bat'

	if command -v bat >/dev/null 2>&1; then
		cd "$(bat --config-dir)/themes"
		bat cache --build
		cd "$(bat --config-dir)/syntaxes"
		bat cache --build
		cd -
	fi
}

main "$@"
