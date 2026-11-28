# Dotterel

**Read this first.** Everything here was written with an AI (vibecoded).
It was made for one person's computer and works there; it is not
tested anywhere else. Read what a script does before you run it, and
use it with care. Improvements are still welcome.

Dotterel is a stenography theory and dictionary for British English:
RP pronunciation, British spelling with Oxford -ize. It is built on
[Lapwing](https://lapwing.aerick.ca/) by Aerick, with the same theory
and syllable splits, and with the vowels and briefs changed where RP
sounds different from General American.

It is made for steno, the C steno engine in the
[dotfiles](https://github.com/AliceInUndernix/dotfiles) repository
(`steno/` there): one static program that reads a Gemini PR keyboard,
such as a ZSA Moonlander running QMK's steno feature, and types into
X. The dictionaries are plain text.

## What is in it

- 113,741 word outlines, 590 prefixes and suffixes, 15,782 proper
  nouns, punctuation, numbers, commands and fingerspelling. Movement,
  modifier keys and raw mode are built into steno itself.
- British by default, American on demand: `#SU` switches the last
  word between UK and US spelling (colour / color).
- The data steno needs to show how a word sounds and what it means,
  and to make outlines for new words.

```
dictionaries/             the dictionaries steno reads, in this order:
  dotterel-base.dict        your words, filled as you go (steno -W)
  dotterel-old-base.dict    the full old base, for every word not in
                            yours yet
  dotterel-proper-nouns.dict, dotterel-old-proper-nouns.dict
  dotterel-punctuation.dict, dotterel-old-punctuation.dict
  dotterel-affixes.dict, -commands, -fingerspelling, -numbers
data/
  uk_to_us.txt              UK <tab> US spelling, for #SU
  word-homes.txt            which dictionary a word belongs in
  pron-uk.txt               British (RP) sounds, from Britfone
  pron-us.txt               American sounds, from CMUdict
  meanings.txt              short meanings, one line for each kind
  lapwing.txt               Lapwing's outlines for each word
  frequency.txt             words, most common first
  hyph_en_GB.dic            British hyphenation, for written syllables
docs/
  commands-cheat-sheet.md   every command stroke
  rp-rules.md               how Dotterel differs from Lapwing
  lapwing-rules.md          the Lapwing theory it builds on
```

## Using it

With the dotfiles, `./install.sh steno` builds steno, clones this
repository into `~/.system/share/steno/dotterel` and updates it on
every run, keeping the words you added. On its own, point steno's
settings at the `dictionaries` directory here.

Each line of a `.dict` file is the text, a tab, then every outline
that writes it, separated by spaces:

```
cat	KAT
{^}.ca	#KRA #KRA* KRA*
```

In the text, `\t` is a tab, `\n` a newline, `\r` a carriage return and
`\\` a backslash. The text uses Plover's dictionary language (`{^}`,
`{-|}`, `{#Return}` ...), which steno follows exactly.

To add a word, edit a `.dict` file, or let steno do it:

- `steno -a OUTLINE TEXT` adds to your own user dictionary, which is
  first in the list.
- `steno -W` shows the last word you wrote: how it sounds (RP and US),
  its syllables, the outlines Dotterel's rules make for it, Lapwing's
  and yours. Stroke the outline and it goes into the right
  `dotterel-*.dict` (`data/word-homes.txt` says which).

The words you add are changes in your clone. To keep them here too,
commit and push from it:

```sh
git -C ~/.system/share/steno/dotterel commit -am "New words"
git -C ~/.system/share/steno/dotterel push
```

If you have Plover dictionaries of your own, `steno -C DIR FILE...`
turns their JSON into steno's format.

## Keys

Steno order: `# S T K P W H R A O * E U F R P B L G T S D Z`.

## The other repositories

Each can be used on its own; the dotfiles installer sets them all up
(`./install.sh keyboard games`).

- [dotfiles](https://github.com/AliceInUndernix/dotfiles):
  the whole Linux desktop: configs, the installer, steno, the diary
  and the other programs
- [moonlander](https://github.com/AliceInUndernix/moonlander):
  the QMK layout for the ZSA Moonlander
- [kspkan](https://github.com/AliceInUndernix/kspkan):
  a small mod manager for Kerbal Space Program

## Credits and licenses

Each part taken from others keeps its own license:

- Lapwing theory, dictionaries and word list: Aerick, MIT
  (`LICENSE-lapwing`).
- Meanings: WordNet 3.0, Princeton University, and GCIDE,
  GPL-3.0-or-later (`LICENSE-meanings`).
- British hyphenation patterns: Dominik Wujastyk and Graham Toal,
  BSD-style (`LICENSE-hyphenation`).
- British pronunciations: Britfone, Jose Llarena, MIT
  (`LICENSE-britfone`).
- American pronunciations: CMUdict, Carnegie Mellon University, BSD
  (`LICENSE-cmudict`).
- Word order by frequency: wordfreq, Robyn Speer, CC BY-SA 4.0
  (`LICENSE-frequency`).
- UK/US spelling list: hyperreality/American-British-English-Translator,
  MIT (`LICENSE-uk-us-list`).

Copyright (c) 2026 AliceInUndernix. Dotterel's own work (its theory
changes, dictionaries and docs) is under Croco's Individualistic Free
Software License, version 0.251225 (`LICENSE`); `COPYRIGHT` says
which file is under which license.
