#!/bin/sh
# Starts Plover (install.sh makes the plover command from this file,
# with the directory it installed Plover into). Started in a directory
# that holds plover.cfg, Plover keeps everything there ("portable
# mode"): settings, plugins, dictionaries, strokes.log. Nothing goes to
# ~/.config or ~/.local.
#
# --python skips the AppImage launcher's own start step, which asks for
# your password (pkexec) to add a udev rule for /dev/uinput. That is only
# for Wayland; on X11 Plover types through X.
#
#   plover                                  start it
#   plover -s plover_plugins install <pkg>  add a plugin
#
# Plover 5 types through X only when XDG_SESSION_TYPE is x11. startx
# leaves it at tty, and then Plover uses uinput, which types characters
# that aren't on the keyboard (curly quotes, ellipsis) as Ctrl+Shift+U
# and a hex code: that only works with ibus or fcitx5.
if [ -n "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    export XDG_SESSION_TYPE=x11
fi
dir=@PLOVER_DIR@
cd "$dir" || exit 1
# Without plover.cfg here Plover leaves portable mode and uses
# ~/.config/plover instead: run install.sh again to put it back.
if [ ! -f plover.cfg ]; then
    echo "plover: no $dir/plover.cfg; run Dotterel's install.sh again" >&2
    exit 1
fi
exec "$dir/app/AppRun" --python -s -m plover.scripts.dist_main "$@"
