# Dotterel for steno

The same dictionaries as `plover-dotterel/plover_dotterel/dictionaries`,
in the plain format of steno, the C steno engine in the dotfiles repo
(`steno/README` there). Plover keeps reading the JSON; steno reads
these. They are made from the JSON with `steno -C` by `make.sh`, so
edit the JSON and run `steno/make.sh` again.

```
dictionaries/
  dotterel-*.dict           TEXT <tab> OUTLINE [OUTLINE...]
data/
  uk_to_us.txt              UK <tab> US, for #SU
```

Three are not here, because steno has them built in, as C:
`dotterel-movement.modal`, `dotterel-modifiers.py` and
`dotterel-raw.json` are `dict dotterel-movement`, `dotterel-modifiers`
and `dotterel-raw` in steno's settings. A change to one of them needs
a change to steno (`steno/dotterel.c` in the dotfiles repo).

One entry a line: the text first, a tab, then every outline that
writes it, separated by spaces:

```
cat	KAT
{^}.ca	#KRA #KRA* KRA*
```

In the text, `\t` is a tab, `\n` a newline, `\r` a carriage return and
`\\` a backslash.
