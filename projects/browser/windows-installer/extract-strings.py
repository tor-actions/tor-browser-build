#!/usr/bin/env python3
import re


with open("languages.nsh") as f:
    strings = re.findall(
        r'LangString (\S+) \${LANG_ENGLISH} "(.+)"$', f.read(), re.I | re.M
    )
print("[strings]")
for key, value in strings:
    print(f"{key}={value}")
