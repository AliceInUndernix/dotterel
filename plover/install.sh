#!/bin/sh
# Install Plover with Dotterel in one go, for Linux on x86-64 (or any
# machine Plover ships an AppImage for). Run it as yourself from this
# repo; nothing needs root. Running it again updates both.
#
#   ./install.sh                     install or update
#   DOTTEREL_CLEAN=yes ./install.sh  reinstall Dotterel from scratch
#
# What it puts where:
#   $PLOVER_DIR/app         the newest Plover release (its AppImage,
#                           unpacked, so it runs without FUSE)
#   $PLOVER_DIR/plover.cfg  settings (plover.cfg from here, the first
#                           time); Plover keeps all its files next to it
#                           ("portable mode"): plugins/, strokes.log, ...
#   $BIN_DIR/plover         starts it (made from plover.sh)
# PLOVER_DIR is ${XDG_DATA_HOME:-~/.local/share}/plover-dotterel and
# BIN_DIR ~/.local/bin, unless you set them.
#
# Dotterel and its dark theme are installed from this repo into Plover's
# own plugins directory. The first settings are Machine: Gemini PR on
# /dev/ttyACM0 and System: Dotterel; to read the keyboard you must be in
# the serial port's group (dialout, or uucp on Arch).
#
# It needs curl, and the commands sed, grep, find, diff and awk.
# POSIX sh.

set -eu

say()  { printf '==> %s\n' "$*"; }
warn() { printf '!!  %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

REPO=$(cd "$(dirname "$0")" && pwd)
PLOVER_DIR=${PLOVER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/plover-dotterel}
BIN_DIR=${BIN_DIR:-$HOME/.local/bin}
PLOVER_API=https://api.github.com/repos/openstenoproject/plover/releases/latest

[ "$(id -u)" -ne 0 ] || die "run it as yourself, not root"
command -v curl >/dev/null 2>&1 || die "curl not found"
mkdir -p "$PLOVER_DIR" "$BIN_DIR"

# The keyboard's serial port: only a warning, adding you needs root.
port_group=$(stat -c %G /dev/ttyACM0 2>/dev/null || :)
case $port_group in ""|root) port_group=dialout ;; esac
id -nG | tr ' ' '\n' | grep -qx "$port_group" ||
    warn "Plover can't read the keyboard until you are in group" \
        "$port_group (as root: usermod -aG $port_group $(id -un), then" \
        "log in again)"

# 1. Plover: the newest release's AppImage for this machine.
url=$(curl -fsSL "$PLOVER_API" |
    grep -o '"browser_download_url": *"[^"]*-'"$(uname -m)"'\.AppImage"' |
    sed 's/.*"\(http[^"]*\)"$/\1/' | head -n 1) || :
app=$PLOVER_DIR/app
if [ -z "$url" ]; then
    [ -x "$app/AppRun" ] ||
        die "could not find the newest Plover release ($PLOVER_API)"
    warn "could not check for a newer Plover; keeping the one in $app"
elif [ "$(cat "$app/.release" 2>/dev/null)" = "$url" ]; then
    say "ok      Plover ${url##*/}"
else
    say "fetch   ${url##*/}"
    rm -rf "$app.tmp"
    mkdir "$app.tmp"
    curl -fL -o "$app.tmp/plover.AppImage" "$url"
    chmod 755 "$app.tmp/plover.AppImage"
    ( cd "$app.tmp" && ./plover.AppImage --appimage-extract >/dev/null )
    echo "$url" > "$app.tmp/squashfs-root/.release"
    rm -rf "$app"
    mv "$app.tmp/squashfs-root" "$app"
    rm -rf "$app.tmp"
    say "install Plover -> $app"
fi

# 2. The launcher, with PLOVER_DIR written in.
sed "s|@PLOVER_DIR@|$PLOVER_DIR|" "$REPO/plover.sh" > "$BIN_DIR/plover.tmp"
chmod 755 "$BIN_DIR/plover.tmp"
mv -f "$BIN_DIR/plover.tmp" "$BIN_DIR/plover"
say "install $BIN_DIR/plover"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *)
    warn "$BIN_DIR is not in your PATH: start Plover with $BIN_DIR/plover" ;;
esac

# 3. Settings: a copy, since Plover rewrites the file. Yours is never
# overwritten.
if [ -e "$PLOVER_DIR/plover.cfg" ]; then
    say "ok      $PLOVER_DIR/plover.cfg (kept yours)"
else
    sed '/^#/d' "$REPO/plover.cfg" > "$PLOVER_DIR/plover.cfg"
    say "copy    plover.cfg -> $PLOVER_DIR/plover.cfg"
fi

# 4. Dotterel and its dark theme. pip's cache is off, so nothing lands
# in ~/.cache.
#
# Every run: stop Plover and delete the dictionary copies it made in
# PLOVER_DIR (no backup). Plover copies a plugin's dictionaries there
# the first time it starts and never updates them; started again, it
# copies the installed ones, so they are always the newest.
if pkill -u "$(id -un)" -f "python.* -m plover\.scripts" 2>/dev/null; then
    sleep 2
    say "stop    Plover (start it again when this is done)"
fi
rm -f "$PLOVER_DIR"/dotterel-*.json "$PLOVER_DIR"/dotterel-*.py \
    "$PLOVER_DIR"/dotterel-*.modal
say "delete  $PLOVER_DIR/dotterel-* (Plover copies them again at start)"

# dicts: the installed plugin's dictionaries directory, or nothing.
dicts() {
    find "$PLOVER_DIR/plugins" -type d \
        -path '*/plover_dotterel/dictionaries' 2>/dev/null | head -n 1
}
# A clean install when the commit is new, the installed dictionaries
# differ from this repo's, or DOTTEREL_CLEAN=yes: Dotterel is
# uninstalled, every Dotterel dictionary file anywhere in PLOVER_DIR is
# deleted (no backup), the dictionary list saved in plover.cfg is
# dropped so Plover uses the plugin's own list, and the plugin is
# installed fresh.
commit=$(git -C "$REPO" rev-parse HEAD 2>/dev/null || echo unknown)
short=$(git -C "$REPO" log -1 --format=%h 2>/dev/null || echo unknown)
new=$REPO/plover-dotterel/plover_dotterel/dictionaries
old=$(dicts)
plover="$BIN_DIR/plover"
if [ "${DOTTEREL_CLEAN:-no}" != yes ] && [ "$commit" != unknown ] &&
    [ "$(cat "$PLOVER_DIR/plugins/.dotterel" 2>/dev/null)" = "$commit" ] &&
    [ -n "$old" ] && diff -rq -x __pycache__ "$new" "$old" >/dev/null 2>&1
then
    say "ok      Dotterel ($short)"
else
    PIP_NO_CACHE_DIR=1 "$plover" -s plover_plugins uninstall -y \
        plover-dotterel plover-dotterel-dark-theme >/dev/null 2>&1 || :
    find "$PLOVER_DIR/plugins" -depth -name 'plover_dotterel*' \
        -exec rm -rf {} + 2>/dev/null || :
    find "$PLOVER_DIR" -path "$REPO" -prune -o -type f \
        \( -name 'dotterel-*.json' -o -name 'dotterel-*.py' \
        -o -name 'dotterel-*.modal' \) -print -exec rm -f {} + \
        2>/dev/null | sed 's/^/==> delete  /'
    cfg=$PLOVER_DIR/plover.cfg
    if [ -f "$cfg" ] && grep -q '^dictionaries *=' "$cfg"; then
        awk '/^\[/ { sec = $0 }
            !(sec == "[System: Dotterel]" && /^dictionaries *=/)' \
            "$cfg" > "$cfg.tmp"
        mv "$cfg.tmp" "$cfg"
        say "reset   Dotterel's dictionary list in plover.cfg"
    fi
    say "plugin  Dotterel and its dark theme, fresh ($short)"
    PIP_NO_CACHE_DIR=1 "$plover" -s plover_plugins install \
        "$REPO/plover-dotterel" "$REPO/plover-dotterel/dark-theme"
    old=$(dicts)
    if [ -n "$old" ] && diff -rq -x __pycache__ "$new" "$old" >/dev/null 2>&1
    then
        echo "$commit" > "$PLOVER_DIR/plugins/.dotterel"
        say "ok      Dotterel's dictionaries match the repo"
    else
        warn "Dotterel's installed dictionaries differ from $new"
    fi
fi

# Any other dictionary list in plover.cfg that still names Dotterel
# files outside the plugin (another system's section, say).
if grep '^dictionaries *=' "$PLOVER_DIR/plover.cfg" 2>/dev/null |
    grep -o '"path": *"[^"]*"' | grep -v 'asset:plover_dotterel:' |
    grep -q dotterel
then
    warn "plover.cfg still lists Dotterel dictionaries outside the plugin"
fi
say "done: start Plover with plover"
