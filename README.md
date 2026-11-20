# Dotterel

Dotterel is a steno theory and dictionary written for British English
(RP pronunciation, British spelling with Oxford -ize). It is built on
[Lapwing](https://lapwing.aerick.ca/) by Aerick: the same theory and
syllable splits, with the vowels and briefs changed where RP sounds
different from General American.

Its home is steno, the C steno engine in the
[dotfiles](https://github.com/AliceInUndernix/dotfiles) repo (`steno/`
there): one static program that reads a Gemini PR keyboard (such as a
ZSA Moonlander running QMK's steno feature) and types into X. The
dictionaries here are in steno's plain text format. A Plover version
is kept in `plover/` as an archive (below).

## What's in it

- **113,817 word outlines** plus 602 prefixes and suffixes, 15,787
  proper nouns, punctuation, numbers, commands and fingerspelling.
  Movement, modifier keys and raw mode are built into steno.
- **British by default, American on demand:** `#SU` switches the last
  word between UK and US spelling (colour / color).

## Layout

```
dictionaries/           the dictionaries steno reads
  dotterel-*.dict       TEXT <tab> OUTLINE [OUTLINE...]
data/
  uk_to_us.txt          UK <tab> US, for #SU
docs/
  commands-cheat-sheet.md  every command stroke
  rp-rules.md           how Dotterel differs from Lapwing
  lapwing-rules.md      the full Lapwing theory it builds on
plover/                 the Plover plugin, its JSON dictionaries and
                        installer: an archive (plover/README.md)
```

## Using it

With the dotfiles, `./install.sh steno` builds steno, clones this repo
into `~/.system/share/steno/dotterel` and updates it every run. On its
own, point steno's settings at the `dictionaries` directory here.

To add or change an outline, edit the `.dict` file (one entry a line:
the text first, a tab, then every outline that writes it, separated by
spaces), or let steno do it: `steno -a OUTLINE TEXT` adds to your own
user dictionary, which is first in the list.

```
cat	KAT
{^}.ca	#KRA #KRA* KRA*
```

In the text, `\t` is a tab, `\n` a newline, `\r` a carriage return and
`\\` a backslash. The text uses Plover's dictionary language
(`{^}`, `{-|}`, `{#Return}` ...), which steno follows exactly.

## Plover (archive)

`plover/` holds the Plover plugin (with the Builder, Quick add and a
dark theme), the same dictionaries as JSON, and an installer for
Plover and Dotterel in one go. It is kept for anyone who uses Plover,
but not maintained: its JSON is a snapshot from 2026-11-17, and changes
made since are only in `dictionaries/`. `steno -C DIR FILE...` turns
Plover JSON dictionaries into steno's format, if you have your own.

## Keys

Steno order: `# S T K P W H R A O * E U F R P B L G T S D Z`.

## Credits

- Lapwing theory and dictionaries: Aerick, MIT licence
  (`LICENSE-lapwing`).
- Definitions: WordNet 3.0, Princeton University (`LICENSE-meanings`).
- British hyphenation patterns: Dominik Wujastyk and Graham Toal
  (`LICENSE-hyphenation`).
- UK/US spelling list: hyperreality/American-British-English-Translator,
  MIT (`LICENSE-uk-us-list`).
