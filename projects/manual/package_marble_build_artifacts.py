import html
import html.parser
import os
import re
import shutil
from urllib.parse import quote_plus, urlparse

DEFAULT_LOCALE = "en"
ORIG_HTML_PATH = "offline/tor-browser/index.html"

# The '#' will be replaced with the locale name.
HTML_NAME_TEMPLATE = "aboutManual-#.html"
ASSETS_DIR_NAME = "assets"


class ManualParser(html.parser.HTMLParser):
    """
    A parser for the Tor Browser manual. Extracts the <body> of the input HTML,
    swaps attributes, and writes out a new HTML.
    """

    _CHROME_URI_BASE = "chrome://browser/content/aboutmanual/"
    _CHROME_ASSET_PATH = _CHROME_URI_BASE + ASSETS_DIR_NAME + "/"
    _CHROME_JS = _CHROME_URI_BASE + "aboutManual.js"

    # The base for external support pages.
    _SUPPORT_URI_BASE = "https://support.torproject.org"

    # The name of online page that the offline manual is derived from (the
    # `data-olm-product` value).
    # In our case, the offline manual is derived from
    # https://support.torproject.org/tor-browser/
    _TOP_PAGE_NAME = "tor-browser"

    # The `id` attribute value that points to the top-page.
    _TOP_ID = "index"

    # The pages that are covered by the offline manual.
    # The first value in the tuple specifies the paths that are covered. Every
    # path that starts with this is considered internal.
    # The second value indicates whether an anchor reference to this page should
    # include the start of the path or not.
    _INTERNAL_PAGES = [
        ([_TOP_PAGE_NAME], False),
        (["get-in-touch", "bug-or-feedback"], True),
        (["get-in-touch", "user-support"], True),
    ]

    # The content security policy we want for the output.
    _CSP = "default-src 'none'; style-src chrome:; img-src chrome:; script-src chrome:"

    # Elements that should not appear in the <body>.
    _FORBIDDEN_BODY_TAGS = [
        "script",
        "noscript",
        "meta",
        "link",
        "html",
        "head",
        "body",
    ]

    # HTML elements that are void elements.
    _VOID_HTML_TAGS = [
        "area",
        "base",
        "br",
        "col",
        "embed",
        "hr",
        "img",
        "input",
        "link",
        "meta",
        "source",
        "track",
        "wbr",
    ]

    _VALID_DIR_VALS = ["rtl", "ltr"]

    def __init__(
        self, locale: str, html_path: str, top_dir: str, all_locales: list[str]
    ) -> None:
        """
        Create a new parser for the offline manual.
        """
        super().__init__(convert_charrefs=True)
        self._locale = locale
        self._html_path = html_path
        self._html_dir = os.path.dirname(html_path)
        self._top_dir = top_dir
        self._all_locales = all_locales

        # As we parse the HTML, we track which tags we are currently inside, as
        # well as some other details about those tags.
        # The last element in the list is the most recent tag.
        self._ancestor_details: list[dict[str, str]] = []

        # The <body> content we should write to the output.
        self._body_content = ""

        # Whether we are currently below the <body> tag.
        self._in_body = False
        # Whether we have encountered the <body> tag at some point.
        self._visited_body = False
        # The lang attribute found on the <html> element.
        self._lang: None | str = None
        # The dir attribute found on the <html> element.
        self._dir: None | str = None
        # The <title> content we have found.
        self._title = ""
        # The stylesheet references to include.
        self._style_hrefs: list[str] = []
        # The found asset paths.
        self._asset_paths: dict[str, str] = {}
        # A list of all internal references we want to verify exist.
        # The first member of the tuple gives the document position where the
        # `href` was found.
        # The second member of the tuple gives the `href` value.
        self._internal_hrefs: list[tuple[tuple[int, int], str]] = []
        # The list of all `id` attributes we found in the <body>.
        self._all_ids: list[str] = []

    def _error(self, message: str, pos: None | tuple[int, int] = None) -> ValueError:
        """
        Create a new parsing error.

        :param message: The message to show.
        :param pos: The document position associated with the error. Defaults to
        the current position.

        :returns: A new error instance.
        """
        if pos is None:
            pos = self.getpos()
        return ValueError(f"{self._html_path}: {pos}: {message}")

    def _in_context(self, expected_ancestors: list[str]) -> bool:
        """
        Test if we are currently below the given ancestors.

        :param expected_ancestors: The tag names for the ancestors we expect.

        :returns: Whether we are directly below the specified ancestors.
        """
        return [d["tag"] for d in self._ancestor_details] == expected_ancestors

    def _add_to_body(self, data: str) -> None:
        """
        Write to the body content.

        :param data: The content to write.
        """
        self._body_content += data

    def _add_end_tag_to_body(self, tag: str) -> None:
        """
        Write an ending tag to the body.

        :param tag: The name of the tag to close.
        """
        self._add_to_body(f"</{tag}>")

    def _add_start_tag_to_body(
        self, tag: str, attrs: dict[str, None | str], self_close: bool
    ) -> None:
        """
        Write a starting tag to the body.

        :param tag: The name of the tag to open.
        :param attrs: The attributes for this tag.
        :param self_close: Whether this tag should be self-closed.
        """
        attr_part = ""
        for name, value in attrs.items():
            attr_part += f" {name}"
            if value is not None:
                attr_part += f'="{html.escape(value, quote=True)}"'
        close_part = " />" if self_close else ">"
        self._add_to_body(f"<{tag}{attr_part}{close_part}")

    def _has_class(self, attrs: dict[str, None | str], class_name: str) -> bool:
        """
        Test if an element has a certain class.

        :param attrs: The attributes for the element.
        :param class_name: The name of the class to check for.

        :returns: Whether the element has the given class.
        """
        class_val = attrs.get("class")
        if not class_val:
            return False
        return class_name in class_val.split(" ")

    def _handle_html_tag(self, attrs: dict[str, None | str]) -> None:
        """
        Process a html tag.

        :param attrs: The tag's attributes.
        """
        if not self._in_context([]):
            raise self._error("html has a parent")
        if self._lang:
            raise self._error("More than one html tag")
        lang = attrs.get("lang")
        if not lang:
            raise self._error("html is missing a lang attribute")
        if lang != self._locale:
            raise self._error(f"Unexpected lang attribute: {lang}")
        dir_val = attrs.get("dir")
        if not dir_val:
            raise self._error("html is missing a dir attribute")
        if dir_val not in self._VALID_DIR_VALS:
            raise self._error(f"Unexpected dir attribute: {dir_val}")

        self._lang = lang
        self._dir = dir_val

    _NON_SAFE_ASSET_CHARS = re.compile(r"[^a-zA-Z0-9_.-]")

    def _swap_asset_path(self, orig_path: str) -> str:
        """
        Swap an an asset path with a new one, and record the old path.

        :param orig_path: The original path for the asset.

        :returns: The new path to use.
        """
        # Parse as a URL so we can strip any queries.
        url = urlparse(orig_path)
        if url.scheme:
            raise self._error(f"Unexpected asset path with a scheme: {url.scheme}")

        if url.path.startswith("/"):
            abs_path = os.path.abspath(os.path.join(self._top_dir, url.path[1:]))
        else:
            abs_path = os.path.abspath(os.path.join(self._html_dir, url.path))

        if os.path.commonpath([self._top_dir, abs_path]) != self._top_dir:
            raise self._error(f"References an asset outside {self._top_dir}")
        if not os.path.isfile(abs_path):
            raise self._error(f"References a non-existent asset: {abs_path}")

        # Replace any (unexpected) non-safe characters with underscores.
        asset_name = self._NON_SAFE_ASSET_CHARS.sub(
            "_", os.path.relpath(abs_path, start=self._top_dir).replace("/", "__")
        )

        if asset_name not in self._asset_paths:
            self._asset_paths[asset_name] = abs_path
        elif self._asset_paths[asset_name] != abs_path:
            raise self._error(f"More than one asset with the same name: {asset_name}")

        return self._CHROME_ASSET_PATH + asset_name

    def _handle_link_tag(self, attrs: dict[str, None | str]) -> None:
        """
        Process a link tag.

        :param attrs: The tag's attributes.
        """
        if attrs.get("rel") != "stylesheet":
            return

        href = attrs.get("href")
        if not href:
            raise self._error("stylesheet link missing an href")

        self._style_hrefs.append(self._swap_asset_path(href))

    def _handle_body_tag(self) -> None:
        """
        Process a body tag.
        """
        if not self._in_context(["html"]):
            raise self._error("Wrong context for the body tag")
        if self._visited_body:
            raise self._error("More than one body tag")
        self._visited_body = True

    def _handle_img_tag(self, attrs: dict[str, None | str]) -> None:
        """
        Process an img tag.

        :param attrs: The tag's attributes, which may be modified.
        """
        if "srcset" in attrs:
            # In principle, we should also map "srcset" as we map "src", but it
            # is unexpected and not worth the parsing logic.
            raise self._error("Unhandled srcset attribute")
        src = attrs.get("src")
        if not src:
            return

        attrs["src"] = self._swap_asset_path(src)

    def _convert_relative_href(self, href: str) -> tuple[str, bool]:
        """
        Convert a relative href into a href that can be used in the final HTML.

        :param href: The href to convert.

        :returns: The new href, and whether the href is an internal link.
        """
        url = urlparse(href)
        parts = [p for p in url.path.replace("../../", "").split("/") if p]
        if not parts or ".." in parts or "." in parts:
            raise self._error(f"Unexpected path: {href}")

        if parts == [self._TOP_PAGE_NAME] and not url.fragment:
            href = "#" + self._TOP_ID
            return href, True

        for page_path, keep_prefix in self._INTERNAL_PAGES:
            cmp_len = len(page_path)
            if parts[:cmp_len] == page_path:
                if not keep_prefix:
                    parts = parts[cmp_len:]
                href = "#" + "__".join(parts)
                if url.fragment:
                    href += "___" + url.fragment
                return href, True

        href = self._SUPPORT_URI_BASE + "/"
        if self._locale != DEFAULT_LOCALE:
            href += quote_plus(self._locale) + "/"
        href += "/".join(parts)
        if url.fragment:
            href += "#" + url.fragment
        # Note: we don't expect a query parameter.
        return href, False

    def _handle_a_tag(
        self, attrs: dict[str, str | None], details: dict[str, str]
    ) -> None:
        """
        Process an anchor tag.

        :param attrs: The tag's attributes, which may be modified.
        :param details: The tag details to save, which may be modified.
        """
        # Always remove these attributes, and maybe replace them below.
        # NOTE: Whilst, some "rel" attribute tokens would, in principle, be
        # valid to keep, we don't expect it to be used in the origin for
        # anything other than "noopener" or "norefferor" in the original
        # document.
        for attr_name in ("rel", "referrerpolicy", "target"):
            if attr_name in attrs:
                del attrs[attr_name]

        # Change href if it includes relative path
        href = attrs.get("href")
        if not href:
            return

        is_external = False
        is_internal = False
        if href.startswith("http:") or href.startswith("https:"):
            is_external = True
        elif href.startswith("mailto:"):
            # Do not allow mailto:
            del attrs["href"]
        elif href.startswith("#"):
            # Keep as is.
            is_internal = True
        elif href.startswith("../../"):
            href, is_internal = self._convert_relative_href(href)
            attrs["href"] = href
            if not is_internal:
                is_external = True
        else:
            raise self._error(f"Unexpected href: {href}")

        if is_external:
            attrs["target"] = "_blank"  # Implies rel="noopener".
            # Is noreferrer needed for external links within a chrome: document?
            attrs["rel"] = "noreferrer"
        if is_internal:
            self._internal_hrefs.append((self.getpos(), href))

        return

    def _handle_div_tag(
        self, attrs: dict[str, str | None], details: dict[str, str]
    ) -> None:
        """
        Process a div tag.

        :param attrs: The tag's attributes, which may be modified.
        :param details: The tag details to save, which may be modified.
        """
        if self._has_class(attrs, "heading-anchor"):
            # Convert the .heading-anchor id to include a prefix from its
            # ancestor .olm-page element.
            el_id = attrs.get("id")
            if not el_id:
                raise self._error("Heading is missing an id")
            page_id = None
            # Search for the nearest ancestor with a page-id.
            for ancestor in reversed(self._ancestor_details):
                page_id = ancestor.get("page-id")
                if page_id:
                    break
            if not page_id:
                raise self._error("Missing a page to use for the heading id")
            attrs["id"] = page_id + "___" + el_id
        elif self._has_class(attrs, "olm-page"):
            el_id = attrs.get("id")
            if not el_id:
                raise self._error("olm-page is missing an id")
            for other in self._ancestor_details:
                if "page-id" in other:
                    raise self._error("olm-page is below another")
            details["page-id"] = el_id

    def _save_id(self, tag: str, attrs: dict[str, str | None]) -> None:
        """
        Maybe save an `id` to the list of `id`s that can be referenced
        internally.
        """
        attr_id = attrs.get("id")
        if not attr_id or not self._in_body:
            # Ignore
            return
        if attr_id in self._all_ids:
            if tag == "input" and self._has_class(attrs, "toggler"):
                # Known issue that *some* <input class="toggler" /> will use
                # the same id as the heading element above it.
                # TODO: tor-browser-build#41818. Remove once this element is
                # removed.
                del attrs["id"]
                return
            raise self._error(f"Duplicate id: {attr_id}")
        self._all_ids.append(attr_id)

    def _handle_tag(
        self, tag: str, attr_pairs: list[tuple[str, str | None]], is_closed: bool
    ) -> None:
        """
        Handle a start tag,

        :param tag: The name of the tag.
        :param attr_pairs: The list of all attributes for this tag.
        :param is_closed: Whether the tag is self-closing.
        """
        details = {"tag": tag, "orig-tag": tag}

        attrs = {}
        for attr_name, attr_value in attr_pairs:
            if attr_name in attrs:
                raise self._error(f"{tag} has a duplicate attribute: {attr_name}")
            attrs[attr_name] = attr_value

        if not self._in_body:
            if tag == "html":
                self._handle_html_tag(attrs)
            elif tag == "link":
                self._handle_link_tag(attrs)
            elif tag == "body":
                self._handle_body_tag()
                self._in_body = True
        elif tag in self._FORBIDDEN_BODY_TAGS:
            raise self._error(f"Unexpected {tag} tag in body")
        elif tag == "img":
            self._handle_img_tag(attrs)
        elif tag == "a":
            self._handle_a_tag(attrs, details)
        elif tag == "div":
            self._handle_div_tag(attrs, details)

        # The tag may have changed.
        tag = details["tag"]
        self._save_id(tag, attrs)

        # NOTE: Technically, we would need to take the `xmlns` into account to
        # ensure that we are still in a HTML context, but we don't expect these
        # void tag names to appear in other contexts.
        is_void_tag = tag in self._VOID_HTML_TAGS
        is_open_tag = not is_void_tag and not is_closed

        if self._in_body:
            # Write the tag, which may differ from the original tag.
            self._add_start_tag_to_body(tag, attrs, is_void_tag)
            if not is_void_tag and not is_open_tag:
                # Close immediately to keep this empty.
                self._add_end_tag_to_body(tag)

        if is_open_tag:
            # Track this as an ancestor.
            self._ancestor_details.append(details)

    ## HTMLParser API

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self._handle_tag(tag, attrs, False)

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self._handle_tag(tag, attrs, True)

    def handle_endtag(self, tag: str) -> None:
        if not self._ancestor_details:
            raise self._error(f"Unmatched end tag: {tag}")
        details = self._ancestor_details.pop()
        if details["orig-tag"] != tag:
            raise self._error(f"Unmatched end tag: {tag}")

        if self._in_body:
            # Write the tag found in `details` to match the tag that was *written*
            # for the start tag, which may differ from `orig-tag`.
            self._add_end_tag_to_body(details["tag"])
        if tag == "body":
            self._in_body = False

    def handle_comment(self, _data: str) -> None:
        # ignore
        pass

    def handle_data(self, data: str) -> None:
        if self._in_body:
            self._add_to_body(html.escape(data, quote=False))
        elif self._in_context(["html", "head", "title"]):
            self._title += data

    def handle_decl(self, decl: str) -> None:
        if decl != "DOCTYPE html" or not self._in_context([]):
            raise self._error("Unexpected declaration")

    def handle_pi(self, _data: str) -> None:
        raise self._error("Unexpected processing instruction")

    def unknown_decl(self, _data: str) -> None:
        raise self._error("Unknown declaration")

    ## Public methods.

    def process(self) -> tuple[str, dict[str, str]]:
        """
        Process the HTML file.

        :returns: A 2-tuple of the filtered HTML content and a dictionary
          that maps from the name of an asset in the HTML content to its
          original file path.
        """
        with open(self._html_path, encoding="utf-8") as file:
            self.feed(file.read())

        # Make sure we are not in an invalid state.
        if self._ancestor_details or self._in_body:
            raise self._error("Document was not closed")
        if not self._visited_body:
            raise self._error("Missing a body element")
        if not self._lang or not self._dir:
            raise self._error("Missing lang or dir")
        if not self._title:
            raise self._error("Missing a title")

        # Make sure all our internal references actually point to an element.
        for pos, href in self._internal_hrefs:
            el_id = href[1:]  # Strip the starting '#'.
            if el_id not in self._all_ids:
                raise self._error(f"Missing an element with the id {el_id}", pos=pos)

        lang = html.escape(self._lang, quote=True)
        dir_val = html.escape(self._dir, quote=True)
        csp = html.escape(self._CSP, quote=True)
        js_chrome = html.escape(self._CHROME_JS, quote=True)
        title_content = html.escape(self._title, quote=False)

        html_output = f"""<!DOCTYPE html>
<html lang="{lang}" dir="{dir_val}">
<head>
  <meta http-equiv="Content-Security-Policy" content="{csp}" />
  <title>{title_content}</title>
  <script src="{js_chrome}"></script>
"""
        for href in self._style_hrefs:
            html_output += (
                f'  <link rel="stylesheet" href="{html.escape(href, quote=True)}" />\n'
            )
        html_output += "</head>\n"
        html_output += self._body_content
        html_output += "\n</html>\n"

        return html_output, self._asset_paths.copy()


def main(top_dir: str, out_dir: str, out_locales: str) -> None:
    out_dir = os.path.abspath(out_dir)
    out_locales = os.path.abspath(out_locales)
    top_dir = os.path.abspath(top_dir)

    if not os.path.isdir(out_dir):
        raise ValueError(f"Not a directory: {out_dir}")

    default_path = os.path.join(top_dir, ORIG_HTML_PATH)
    if not os.path.isfile(default_path):
        raise ValueError(f"Missing file: {default_path}")

    locale_regex = re.compile("^[a-z]{2}(-[A-Z]{2})?$")
    locale_html = {DEFAULT_LOCALE: default_path}
    for maybe_locale in os.listdir(top_dir):
        if not locale_regex.fullmatch(maybe_locale):
            continue
        maybe_path = os.path.join(top_dir, maybe_locale, ORIG_HTML_PATH)
        if os.path.isfile(maybe_path):
            locale_html[maybe_locale] = maybe_path

    all_locales = sorted(locale_html.keys())
    all_asset_paths: dict[str, str] = {}

    for locale, html_path in locale_html.items():
        parser = ManualParser(
            locale=locale,
            html_path=html_path,
            top_dir=top_dir,
            all_locales=all_locales,
        )
        content, asset_paths = parser.process()

        for asset_name, orig_path in asset_paths.items():
            if asset_name not in all_asset_paths:
                all_asset_paths[asset_name] = orig_path
            elif all_asset_paths[asset_name] != orig_path:
                raise ValueError(f"Duplicate asset names: {asset_name}")

        out_html_path = os.path.join(out_dir, HTML_NAME_TEMPLATE.replace("#", locale))
        with open(out_html_path, "w", encoding="utf-8") as file:
            file.write(content)

    asset_dir = os.path.join(out_dir, ASSETS_DIR_NAME)
    try:
        os.mkdir(asset_dir)
    except FileExistsError:
        pass

    for asset_name, orig_path in all_asset_paths.items():
        shutil.copyfile(orig_path, os.path.join(os.path.join(asset_dir, asset_name)))

    with open(out_locales, "w", encoding="utf-8") as file:
        file.write(",".join(all_locales))


if __name__ == "__main__":
    import argparse

    arg_parser = argparse.ArgumentParser(
        description="Filter the offline manual HTML files to be used in Tor Browser"
    )

    arg_parser.add_argument(
        "--in-dir",
        required=True,
        help="The 'public' directory to read the original HTML files from",
    )
    arg_parser.add_argument(
        "--out-dir",
        required=True,
        help="The directory to write the output HTML and assets to",
    )
    arg_parser.add_argument(
        "--out-locales",
        required=True,
        help="The file to write the list of locales to",
    )

    args = arg_parser.parse_args()
    main(args.in_dir, args.out_dir, args.out_locales)
