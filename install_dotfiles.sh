#!/usr/bin/env bash

# Install configuration dotfiles into user home directory.
# Usage: ./install_dotfiles.sh
#
# Yu Shiyang <yu.shiyang@gnayihs.uy>

# Make a copy of a file with a tilde added to its filename.
# If a file of the new name already exists, do not make a copy.
# This function is idempotent.
# Usage: tildeless <filename>
tildeless() {
	file="$1"
	if [ ! -e "$file" ]; then
		echo "tildeless: $file does not exist" 1>&2
		return 1
	fi

	tildefile="$file~"
	if [ -e "$tildefile" ]; then
		if [ -d "$file" ]; then
			if [ ! -d "$tildefile" ]; then
				echo "tildeless: $tildefile already exists but is not a directory" 1>&2
				return 3
			else
				return
			fi
		elif [ -f "$file" ]; then
			if [ ! -f "$tildefile" ]; then
				echo "tildeless: $tildefile already exists but is not a file" 1>&2
				return 3
			else
				return
			fi
		fi
	fi

	if [ -d "$file" ]; then
		mv "$file" "$tildefile"
		cp -a "$tildefile" "$file"
		chmod -R --preserve-root a-wx,+X "$tildefile"
	elif [ -f "$file" ]; then
		mv "$file" "$tildefile"
		cp -a "$tildefile" "$file"
		chmod a-wx "$tildefile"
	else
		echo "tildeless: $file is not a file or a directory" 1>&2
		return 2
	fi
}

# If a local patch for the file exists, apply it.
# A local patch for a given file is denoted by filename.local.patch in the same directory.
# Also appends files locally if one exists, denoted by filename.local.append in the same directory.
# Usage: local_patch_append <filename> [<source_file_to_patch_from = filename> [<output_filename = filename>]]
local_patch_append() {
	file="$1"
	source="$2"
	output="$3"
	source="${source:-"$file"}"
	output="${output:-"$file"}"
	if [ -f "$file.local.patch" ]; then
		if [ "$source" = "$output" ]; then
			patch "$source" "$file.local.patch"
		else
			patch "$source" "$file.local.patch" -o "$output"
		fi
		if [ -f "$file.local.append" ]; then
			cat "$output" "$file.local.append" > "$output"
		fi
	elif [ -f "$file.local.append" ]; then
		cat "$source" "$file.local.append" > "$output"
	fi
}

# Install a new file, then apply any local patches and appends in the same directory.
# Usage: install_file <source_file> <filename_after_install>
install_file() {
	source="$1"
	installed="$2"

	if [ ! -e "$source" ];  then
		echo "install_file: $source does not exist" 1>&2
		return 1
	elif [ ! -f "$source" ]; then
		echo "install_file: $source is not a file" 1>&2
		return 2
	fi

	# ${VAR%pattern} returns VAR with the shortest matching pattern stripped from the back
	if [ -e "$installed" ]; then
		if [ -f "$installed" ]; then
			# Exit if there will be no change after installation
			# Check if the installed file has patches or appends

			# ${VAR##pattern} returns VAR with the longest matching pattern stripped from the front
			simulated_installed="/tmp/${installed##*/}.installed"
			local_patch_append "$installed" "$source" "$simulated_installed" &> /dev/null
			if [ ! -f "$simulated_installed" ]; then
				simulated_installed="$source"
			fi
			if cmp --silent "$installed" "$simulated_installed"; then
				# Exit if identical
				echo "Skipping '$source'; aleady installed at '$installed'"
				return 0
			fi

			echo "Installing '$source' -> '$installed'"

			tildeless "$installed"  # Does not tilde if a tilde file already exists
			rm "$installed"
		else
			echo "install_file: $installed is not a file" 1>&2
			return 2
		fi
	else
		echo "Installing '$source' -> '$installed'"

		mkdir -p "${installed%/*}"
	fi

	cp "$source" "$installed"
	local_patch_append "$installed"
}

export -f tildeless
export -f local_patch_append
export -f install_file

base_path="$1"
base_path="${base_path:-posix}"

# `bash -c '<command> $0 $1' <arg1> <arg2>` executes <command> with <arg1> and <arg2> as its first and second arguments
# `${<VAR>#<pattern>}`` returns <VAR> with the shortest string that matches <pattern> stripped from the front
# `"{}"`` would be any file in `posix/` by default
find "$base_path" -type f -exec bash -c 'install_file "$1/${0#*/}" "$HOME/${0#*/}"' "{}" "$base_path" \;

unset base_path

unset tildeless
unset local_patch_append
unset install_file
