"""Word lists the Builder uses. Every list is read once, then kept.

- popular_words(): the "Popular words" list for the Builder (data/missing-words.txt):
  most common first, UK spelling with Oxford -ize, without words you can
  already make from a word + an affix (cats, walked, unhappy).
- rank(word): how common a word is in English, 1 = "the" (data/frequency.txt).
- lapwing_outlines(word): how original Lapwing writes a word, as a hint.
"""

import gzip
import re
import os

DATA = os.path.join(os.path.dirname(__file__), "data")

_cache = {}

# Dotterel writes typographic punctuation: ’ in words (don’t, o’clock),
# “ ” and ‘ ’ for quotes, … for an ellipsis. Word lists and typed texts
# often have the straight ones (don't, "...").
_PLAIN = str.maketrans({"’": "'", "‘": "'", "“": '"', "”": '"'})


def plain(text):
    """don’t -> don't, “hi” -> "hi", … -> ... (for comparing and word lists)."""
    return (text or "").translate(_PLAIN).replace("…", "...")


_BRACES = re.compile(r"(\{[^{}]*\})")
# Braces whose text Plover writes out: {^’s}, {~|’^}em, {^n’t} ...
# ({#Key}, {PLOVER:...}, {:retro...}, {*...}, {&c} and {MODE:...} are
# commands or fingerspelling and are left alone.)
_TEXT_BRACE = re.compile(r"\{(~\|)?\^?([^#:&*{}=<>|]*?)\^?\}")
_OPENS = " \t\n([{<‘“—–/-"


def _curly_text(text, before):
    """Straight quotes in a piece of text -> typographic ones.

    ' is always the apostrophe ’ (don’t, ’tis, dogs’, ’90s); " opens (“)
    after nothing, a space or an opening bracket, and closes (”) after
    anything else. `before` is the character written just before it."""
    out = []
    for c in text:
        if c == "'":
            c = "’"
        elif c == '"':
            c = "“" if not before or before in _OPENS else "”"
        out.append(c)
        before = c
    return "".join(out)


def curly(word):
    """don't -> don’t, "hi" -> “hi”: a translation as Dotterel writes it.

    Prose never gets a straight ' or ": every one in a translation that
    has a letter or a digit becomes the typographic one, also in affixes
    ({^'s} -> {^’s}, {~|'^}em -> {~|’^}em). Left alone: a translation
    with no letter or digit (a bare symbol, like #KR*RG ' for code),
    a {command} or fingerspelling ({#apostrophe}, {&'}), and a Plover
    meta (=...)."""
    if not word or "=" == word[:1] or ("'" not in word and '"' not in word):
        return word
    if not any(c.isalnum() for c in _BRACES.sub("", word)) and not any(
        m.group(2) and any(c.isalnum() for c in m.group(2))
        for m in _TEXT_BRACE.finditer(word)
    ):
        return word
    out = []
    before = ""
    for piece in _BRACES.split(word):
        if piece[:1] != "{":
            piece = _curly_text(piece, before)
            before = piece[-1:] or before
        else:
            m = _TEXT_BRACE.fullmatch(piece)
            if m and m.group(2):
                a, b = m.span(2)
                text = _curly_text(m.group(2), before)
                piece = piece[:a] + text + piece[b:]
                before = text[-1:]
        out.append(piece)
    return "".join(out)


def _lines(name):
    """The words of a data file, without # comment lines."""
    if name not in _cache:
        with open(os.path.join(DATA, name), encoding="utf-8") as f:
            _cache[name] = [w.strip() for w in f if w.strip() and not w.startswith("#")]
    return _cache[name]


def popular_words():
    return _lines("missing-words.txt")


def rank(word):
    """1 for the most common English word; None if it isn't in the list."""
    if "rank" not in _cache:
        table = {}
        for i, w in enumerate(_lines("frequency.txt"), 1):
            table.setdefault(w, i)
            table.setdefault(w.lower(), i)
        _cache["rank"] = table
    table = _cache["rank"]
    if not word:
        return None
    word = plain(word)
    return table.get(word) or table.get(word.lower())


def _lapwing():
    if "lapwing" not in _cache:
        table = {}
        with gzip.open(os.path.join(DATA, "lapwing-outlines.tsv.gz"), "rt", encoding="utf-8") as f:
            for line in f:
                if line.startswith("#") or "\t" not in line:
                    continue
                word, outlines = line.rstrip("\n").split("\t", 1)
                table[word] = outlines.split()
        _cache["lapwing"] = table
    return _cache["lapwing"]


def lapwing_outlines(word):
    """Lapwing's outlines for a word ([] if Lapwing doesn't have it).

    Lapwing's list is in -ise spelling, so realize also finds realise.
    """
    table = _lapwing()
    word = plain(word)
    for w in (word, word.lower(), word.replace("iz", "is"), word.lower().replace("iz", "is")):
        if w in table:
            return table[w]
    return []
