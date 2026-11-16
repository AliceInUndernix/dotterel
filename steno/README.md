# Dotterel for steno

The same dictionaries as `plover-dotterel/plover_dotterel/dictionaries`,
in the plain format of steno, the C steno engine in the dotfiles repo
(`steno/README` there). Plover keeps reading the JSON; steno reads
these. They are made from the JSON with `steno -C` by `make.sh`, so
edit the JSON and run `steno/make.sh` again.

```
dictionaries/
  dotterel-*.dict           TEXT <tab> OUTLINE [OUTLINE...]
  dotterel-movement.mode    option / entry / dict / exit lines
  dotterel-modifiers.mods   modifier and keys lines (what
                            dotterel-modifiers.py does in Plover)
data/
  uk_to_us.txt              UK <tab> US, for #SU
```

One entry a line: the text first, a tab, then every outline that
writes it, separated by spaces:

```
cat	KAT
{^}.ca	#KRA #KRA* KRA*
```

In the text, `\t` is a tab, `\n` a newline, `\r` a carriage return and
`\\` a backslash.
