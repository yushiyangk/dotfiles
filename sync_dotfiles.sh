#!/usr/bin/env bash

# Update from remote git repository and install dotfiles
# Usage: ./update_dotfiles.sh
#
# Yu Shiyang <yu.shiyang@gnayihs.uy>


name='sync_dotfiles.sh'

help="Usage: $name [-h] [<options>] [<target>]"
help="$help\nPull the latest version of dotfiles from the remote repository and install them"
help="$help\n"
help="$help\nParameters:"
help="$help\n  <target>        Target label that describes the local system, which also"
help="$help\n                  corresponds to the subdirectory of the same name;"
help="$help\n                  default: posix"
help="$help\n"
help="$help\nOptions:"
help="$help\n  -h, -?, --help  Display this help message and exit"


target='posix'
quiet=0

argi=0
while [ $# -gt 0 ]; do
	arg="$1"
	case "$arg" in
		--help)
			echo -e "$help"
			exit 0
			;;
		--quiet)
			((++quiet))
			;;
		--*)
			echo "$name: invalid option '$arg'" >& 2
			exit 2
			;;
		-*)
			for i in $(seq 1 $((${#arg} - 1))); do
				flag="${arg:$i:1}"
				case "$flag" in
					h|\?)
						echo -e "$help"
						exit 0
						;;
					q)
						((++quiet))
						;;
					*)
						echo "$name: invalid option '$flag'" >& 2
						exit 2
				esac
			done
			;;
		*)
			case "$argi" in
				0)
					target="$arg"
					;;
				*)
					echo "$name: unexpected parameter '$arg'" >& 2
					exit 2
					;;
			esac
			((++argi))
	esac
	shift
done


install_args=("$target")
if [ $quiet -ne 0 ]; then
	install_args+=("-$( printf 'q%.0s' {1..$quiet} )")
	# {1..$quiet} expands to integers 1 through $quiet
	# 'q%.0s' turns each into just 'q' because the '%.0s' specifies a string of maximum length 0
fi

# Update from git repository and install
git pull --ff-only && ./install_dotfiles.sh ${install_args[@]}

# Check if bash
if [ -n "$BASH" ] || [ -n "$BASH_VERSION"]; then
	profiled=0
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.bash_profile" ]; then
		source "$HOME/.bash_profile"
		profiled=1
	fi
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.bash_login" ]; then
		source "$HOME/.bash_login"
		profiled=1
	fi
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.profile" ]; then
		source "$HOME/.profile"
		profiled=1
	fi
fi
