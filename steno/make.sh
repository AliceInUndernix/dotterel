#!/bin/sh
# Makes steno's copies of the dictionaries (steno/dictionaries,
# steno/data) from Plover's (plover-dotterel/plover_dotterel). Run it
# after changing a dictionary, from anywhere; it needs steno (the
# dotfiles repo's steno/, ./install.sh steno). The .json files stay
# the ones to edit: these are made from them.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=$here/../plover-dotterel/plover_dotterel
command -v steno >/dev/null 2>&1 || {
	echo "make.sh: steno not found (./install.sh steno in dotfiles)" >&2
	exit 1
}
steno -C "$here/dictionaries" "$src"/dictionaries/*.json \
	"$src"/dictionaries/*.modal "$src"/dictionaries/dotterel-modifiers.py
steno -C "$here/data" "$src"/data/uk_to_us.json
