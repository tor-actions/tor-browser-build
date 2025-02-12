import argparse
import json
import re

arg_parser = argparse.ArgumentParser(
    description="Filter a branding file to only include the expected strings"
)
arg_parser.add_argument("file", metavar="<file>", help="branding file to process")
arg_parser.add_argument(
    "details", metavar="<details>", help="JSON specification for renaming"
)

args = arg_parser.parse_args()
details_dict = json.loads(args.details)
# The suffix we want to search for or remove.
# Can be empty if we want to select the IDs that have no suffix.
suffix = details_dict["suffix"]
# The string IDs we want to rename.
rename_ids = details_dict["ids"]


def parse_ids(string, pattern):
    """
    Extract the IDs found in a string.

    :param string: The string to parse.
    :param pattern: The pattern to capture IDs.

    :yields: A tuple containing a chunk of string and whether the chunk
      is an ID.
    """
    regex = re.compile(pattern, flags=re.MULTILINE + re.ASCII)
    while True:
        match = regex.search(string)
        if not match:
            yield string, False
            return

        yield string[: match.start("id")], False
        yield match.group("id"), True
        string = string[match.end("id") :]


# We want to parse the file and rename the IDs we are interested in.
# If the ID starts with one of the `rename_ids` but the suffix does
# not match we append an "_UNUSED" suffix to the ID, to keep it in the output
# but functionally unused in the final build.
# Otherwise, if the ID starts with one of the `rename_ids` and the suffix
# matches we will remove the suffix from the ID, so that it is used in the
# final build.
# Everything else found in the file, like entry values, comments and blank
# lines, will be included in the output as it was.
#
# NOTE: This script is constructed to be *independent* of the order in which
# strings are present in the file. Weblate does not guarantee the order of
# translated files to use the same ordering as the original en-US file.
#
# NOTE: This script should work for all locales. In particular, for Fluent files
# it needs to be able to handle Fluent Terms that are multi-valued (conditional)
# and Terms with attributes. Therefore, whilst we could have written a script to
# *remove* unwanted strings, the parsing logic would have been far more complex
# to be able to handle all these cases. Hence why we only parse for the Fluent
# IDs and rename them, which is much simpler.
with open(args.file, "r") as file:
    if file.name.endswith(".ftl"):
        # A Fluent ID is the identifier for a Message or Term, which always
        # starts on a newline, and will be followed by an "=" character.
        id_pattern = r"^(?P<id>-?[a-zA-Z][a-zA-Z0-9_-]*) *="
    elif file.name.endswith(".properties"):
        # A properties ID can be preceded by whitespace, and can be any
        # character other than whitespace, ":" or "=". The first character also
        # cannot be "!" or "#" since this starts a comment. Technically the
        # Java ".properties" spec allows a ID to include one of these characters
        # if it is escaped by a "\", but we don't expect or care about such IDs.
        # The Java spec also has a limited set of whitespace, which excludes
        # "\v", but we do not expect Weblate or any other serialiser to
        # insert whitespace beyond "\n", "\r", "\t" or " ".
        id_pattern = r"^\s*(?P<id>[^!#:=\s][^:=\s]*)"
    else:
        raise ValueError(f"Unknown file type {file.name}")

    for part, is_id in parse_ids(file.read(), id_pattern):
        if is_id:
            for string_id in rename_ids:
                if part.startswith(string_id):
                    if part == string_id + suffix:
                        # This string matches the suffix, so we want to use its
                        # value. We adjust the ID to remove the suffix before
                        # printing.
                        part = string_id
                    else:
                        # Keep this entry in the output, but make it unused by
                        # appending to the ID.
                        part += "_UNUSED"
                    break
        print(part, end="")
