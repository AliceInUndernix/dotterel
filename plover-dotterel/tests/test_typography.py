"""Prose never gets a straight quote: every dictionary writes the
typographic ’ ‘ ’ “ ”, and a straight ' or " (or `) is only in the
strokes for code. Needs no Plover.  Run: python -m pytest tests
"""

import glob
import json
import os

import pytest

from plover_dotterel.words import curly

DICTS = os.path.join(os.path.dirname(__file__), "..", "plover_dotterel", "dictionaries")

# Strokes allowed to write a straight quote or a backtick: the code ones.
CODE = {
    "#KW-GS": '{~|"^}', "#KW*GS": '{^~|"}',   # " for code
    "#KR-RG": "{~|'^}", "#KR*RG": "{^~|'}",   # ' for code
    "KH-FG": "`{^}", "KH*FG": "{^}`",         # ` (backtick), code only
}


def _entries():
    for path in sorted(glob.glob(os.path.join(DICTS, "*.json"))):
        with open(path, encoding="utf-8") as f:
            for stroke, text in json.load(f).items():
                yield os.path.basename(path), stroke, text


def test_no_straight_quote_in_prose():
    bad = [
        (name, stroke, text)
        for name, stroke, text in _entries()
        if any(c in text for c in "'\"`") and CODE.get(stroke) != text
    ]
    assert bad == []


def test_code_quotes_are_there():
    found = {s: t for name, s, t in _entries() if name == "dotterel-punctuation.json"}
    for stroke, text in CODE.items():
        assert found.get(stroke) == text


def test_curly_changes_no_dictionary_entry():
    changed = [(n, s, t) for n, s, t in _entries() if curly(t) != t]
    assert changed == []


@pytest.mark.parametrize("typed, saved", [
    ("don't", "don’t"),
    ("O'Neal", "O’Neal"),
    ("'90s", "’90s"),
    ("rock 'n' roll", "rock ’n’ roll"),
    ('say "yes"', "say “yes”"),
    ("{^'s}", "{^’s}"),
    ("{^n't}", "{^n’t}"),
    ("{^}'d", "{^}’d"),
    ("{~|'^}em", "{~|’^}em"),
    # Left alone: bare symbols (code), commands, fingerspelling, metas.
    ("'", "'"),
    ('{~|"^}', '{~|"^}'),
    ("{#apostrophe}", "{#apostrophe}"),
    ("{&'}", "{&'}"),
    ("=undo", "=undo"),
])
def test_curly(typed, saved):
    assert curly(typed) == saved
