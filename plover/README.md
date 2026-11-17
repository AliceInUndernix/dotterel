# Dotterel for Plover (archive)

This is the Plover version of Dotterel, kept for anyone who uses
[Plover](https://www.openstenoproject.org/plover/). It is no longer
maintained: the main dictionaries are the ones at the top of this repo
(`dictionaries/`, `data/`), in the plain format of steno, the C steno
engine in the dotfiles repo. The JSON here is a snapshot of them from
2026-11-17 and does not get the changes made since.

## What's in it

- `plover-dotterel/`: the Plover plugin (version 1.5.0): the Dotterel
  system (keys, steno order, Gemini PR mapping), the dictionaries as
  JSON, and its tools:
  - **The Builder** (Ctrl+B in Plover, or in the toolbar), a window for
    growing your dictionary: suggests outlines for a word from Lapwing
    and the Dotterel rules; UK pronunciation and audio from the
    Cambridge Dictionary, the meaning (WordNet), the Russian
    translation; one table of every outline to search, edit, move or
    delete; a Practice tab (a typing test on any text or EPUB book) and
    a Stats tab read from Plover's stroke log.
  - **Quick add** (`TK*UPT`): give the last word an outline without
    leaving what you're writing.
  - **Raw mode** (`RA*U`): see raw steno instead of words.
- `plover-dotterel/dark-theme/`: a dark theme for Plover's windows, as
  its own small plugin.
- `install.sh`, `plover.sh`, `plover.cfg`: Plover and Dotterel in one
  go (below).

The Builder looks words up on the Cambridge Dictionary's website, so
using it tells that site which words you look up.

## Install

Plover and Dotterel in one go (Linux; nothing needs root):

```
git clone https://github.com/AliceInUndernix/dotterel
cd dotterel/plover
./install.sh
```

It puts the newest Plover release (its AppImage, unpacked) in
`~/.local/share/plover-dotterel` with first settings for a Gemini PR
keyboard on `/dev/ttyACM0` (`plover.cfg`), installs Dotterel and its
dark theme from here into Plover's own plugins, and makes the `plover`
command in `~/.local/bin`. Plover runs in portable mode there, so its
settings, plugins and logs stay in that directory.
`DOTTEREL_CLEAN=yes ./install.sh` reinstalls Dotterel from scratch.
`PLOVER_DIR=...` and `BIN_DIR=...` choose other places. To read the
keyboard you must be in the serial port's group (`dialout`, `uucp` on
Arch): as root, `usermod -aG dialout user`, then log in again.

With a Plover you already have, install the plugin in Plover's own
Python instead:

```
plover -s plover_plugins install ./plover-dotterel
plover -s plover_plugins install ./plover-dotterel/dark-theme   # optional
```

Restart Plover, then in Configure pick **System: Dotterel** and
**Machine: Gemini PR**.
