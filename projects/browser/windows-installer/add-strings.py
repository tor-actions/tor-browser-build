#!/usr/bin/env python3
import argparse
import configparser
from pathlib import Path
import sys


def nsis_escape(string):
    return string.replace("$", "$$").replace('"', r"$\"")


parser = argparse.ArgumentParser()
parser.add_argument(
    "--enable-languages",
    action="store_true",
    help="Enable the passed languages on NSIS (needs to be done only once)",
)
parser.add_argument(
    "directory",
    type=Path,
    help="Directory where the installer strings have been extracted",
)
parser.add_argument("langs", nargs="+")
args = parser.parse_args()

# This does not contain en-US, as en-US strings should already be in
# languages.nsh.
languages = {
    "ar": "Arabic",
    "ca": "Catalan",
    "cs": "Czech",
    "da": "Danish",
    "de": "German",
    "el": "Greek",
    "es-ES": "Spanish",
    "fa": "Farsi",
    "fi": "Finnish",
    "fr": "French",
    "ga-IE": "ScotsGaelic",
    "he": "Hebrew",
    "hu": "Hungarian",
    "id": "Indonesian",
    "is": "Icelandic",
    "it": "Italian",
    "ja": "Japanese",
    "ka": "Georgian",
    "ko": "Korean",
    "lt": "Lithuanian",
    "mk": "Macedonian",
    "ms": "Malay",
    # Burmese not available on NSIS
    # "my": "Burmese",
    "nb-NO": "Norwegian",
    "nl": "Dutch",
    "pl": "Polish",
    "pt-BR": "PortugueseBR",
    "ro": "Romanian",
    "ru": "Russian",
    "sq": "Albanian",
    "sv-SE": "Swedish",
    "th": "Thai",
    "tr": "Turkish",
    "uk": "Ukrainian",
    "vi": "Vietnamese",
    "zh-CN": "SimpChinese",
    "zh-TW": "TradChinese",
    # Nightly-only at the moment
    "be": "Belarusian",
    "bg": "Bulgarian",
    "pt-PT": "Portuguese",
}

replacements = {
    "min_windows_version": {
        "program": "${PROJECT_NAME}",
        "version": "10",
    },
    "welcome_title": ("${DISPLAY_NAME}",),
    "mb_intro": ("${PROJECT_NAME}",),
    "standalone_description": ("${PROJECT_NAME}",),
}


def read_strings(code):
    strings = configparser.ConfigParser(interpolation=None)
    strings.read(args.directory / code / "windows-installer/strings.ini")
    if "strings" not in strings:
        return {}
    strings = strings["strings"]
    for key, value in strings.items():
        strings[key] = nsis_escape(value.replace("\n", "").replace("\r", ""))
    return strings


strings_en = read_strings("en-US")
if not strings_en:
    print("Strings not found for en-US.", file=sys.stderr)
    sys.exit(1)

for code in args.langs:
    if code not in languages:
        print(f"Unknown or unsupported language {code}.", file=sys.stderr)
        continue
    lang = languages[code]
    if args.enable_languages:
        print(f'!insertmacro MUI_LANGUAGE "{lang}"')

    strings = read_strings(code)
    for key, string in strings_en.items():
        tr = strings.get(key)
        # Use an explicit if in case the string is found but it is empty.
        if tr:
            string = tr
        if key in replacements:
            string = string % replacements[key]
        print(f'LangString {key} ${{LANG_{lang}}} "{string}"')
    print()
