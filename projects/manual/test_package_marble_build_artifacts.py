import os
import re
import shutil
import tempfile
import textwrap
import unittest

from package_marble_build_artifacts import ManualParser, main

EXPECT_CSP_META = '<meta http-equiv="Content-Security-Policy" content="default-src &#x27;none&#x27;; style-src chrome:; img-src chrome:; script-src chrome:" />'
EXPECT_SCRIPT = (
    '<script src="chrome://browser/content/aboutmanual/aboutManual.js"></script>'
)
EXPECT_CHROME_ASSETS = "chrome://browser/content/aboutmanual/assets"


class TestSingleHTML(unittest.TestCase):
    top_dir: str | None = None
    html_path: str | None = None
    all_locales = ["en", "ar"]

    # Set the TestCase.maxDiff to a larger number to see the full HTML.
    maxDiff = 2000

    @classmethod
    def setUpClass(cls) -> None:
        cls.top_dir = tempfile.mkdtemp()
        try:
            os.chdir(cls.top_dir)
            html_dir = os.path.join(cls.top_dir, "html/html")
            assets1_dir = os.path.join(cls.top_dir, "html/assets1")
            assets2_sub_dir = os.path.join(cls.top_dir, "assets2/sub")
            os.makedirs(html_dir)
            os.makedirs(assets1_dir)
            os.makedirs(assets2_sub_dir)
            cls.html_path = os.path.join(html_dir, "test.html")

            for filename in (
                "html/html/neighbour1.svg",
                "html/html/neighbour2.svg",
                "html/html/neighbour1.css",
                "html/html/neighbour2.css",
                "html/assets1/image1.png",
                "html/assets1/style1.css",
                "assets2/image2.png",
                "assets2/style2.css",
                "assets2/sub/image2.png",
                "assets2/sub/style2.css",
                "html/assets1/image@2x.png",
                "html/assets1/🦭.svg",
                "html/assets1/~.svg",
            ):
                # Create an empty file.
                open(os.path.join(cls.top_dir, filename), "w", encoding="utf-8").close()
        except:
            shutil.rmtree(cls.top_dir)
            raise

    @classmethod
    def tearDownClass(cls) -> None:
        assert cls.top_dir is not None
        shutil.rmtree(cls.top_dir)

    @staticmethod
    def dedent(in_str: str) -> str:
        out_str = textwrap.dedent(in_str)
        if out_str.startswith("\n"):
            out_str = out_str[1:]
        return out_str

    def assert_html_out(
        self, in_html: str, locale: str, expect_html: str, expect_assets: dict[str, str]
    ) -> None:
        assert self.html_path is not None
        assert self.top_dir is not None

        with open(self.html_path, "w", encoding="utf-8") as file:
            file.write(self.dedent(in_html))
        expect_html = self.dedent(expect_html)

        expect_assets = {
            key: os.path.join(self.top_dir, val) for key, val in expect_assets.items()
        }

        parser = ManualParser(
            locale=locale,
            html_path=self.html_path,
            top_dir=self.top_dir,
            all_locales=self.all_locales,
        )
        out_html, out_assets = parser.process()
        self.assertEqual(out_html, expect_html, "HTML should match")
        self.assertEqual(out_assets, expect_assets)

    def assert_body_out(
        self,
        in_body: str,
        expect_body: str,
        expect_assets: dict[str, str],
        locale: str = "ar",
    ) -> None:
        indent = "            "
        in_body = textwrap.indent(self.dedent(in_body), prefix=indent)
        expect_body = textwrap.indent(self.dedent(expect_body), prefix=indent)
        in_html = f"""
            <html lang="{locale}" dir="rtl">
            <head>
              <title>Test</title>
            </head>\n{in_body}{indent}</html>
        """
        expect_html = f"""
            <!DOCTYPE html>
            <html lang="{locale}" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>Test</title>
              {EXPECT_SCRIPT}
            </head>\n{expect_body}{indent}</html>
        """
        self.assert_html_out(in_html, locale, expect_html, expect_assets)

    def assert_html_raises(
        self, in_html: str, locale: str, expect_err_str: str
    ) -> None:
        assert self.html_path is not None
        assert self.top_dir is not None

        with open(self.html_path, "w", encoding="utf-8") as file:
            file.write(self.dedent(in_html))
        parser = ManualParser(
            locale=locale,
            html_path=self.html_path,
            top_dir=self.top_dir,
            all_locales=self.all_locales,
        )
        with self.assertRaisesRegex(
            ValueError,
            r"^[^:]+.html: \([0-9]+, [0-9]+\): " + re.escape(expect_err_str) + "$",
        ):
            parser.process()

    def assert_body_raises(self, in_body: str, expect_err_str: str) -> None:
        indent = "            "
        in_body = textwrap.indent(self.dedent(in_body), prefix=indent)
        in_html = f"""
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
            </head>\n{in_body}{indent}</html>
        """
        self.assert_html_raises(in_html, "ar", expect_err_str)

    def test_empty_body(self) -> None:
        self.assert_body_out("<body></body>\n", "<body></body>\n", {})

    def test_html_tag(self) -> None:
        self.assert_html_out(
            """
            <html lang="en" dir="rtl">
            <head>
              <title>Test</title>
            </head>
            <body>
            </body>
            </html>
            """,
            "en",
            f"""
            <!DOCTYPE html>
            <html lang="en" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>Test</title>
              {EXPECT_SCRIPT}
            </head>
            <body>
            </body>
            </html>
            """,
            {},
        )
        # Invalid.
        self.assert_html_raises(
            """
            <div>
              <html>
              </html>
            </div>
            """,
            "ar",
            "html has a parent",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            </html>
            <html lang="en" dir="ltr">
            </html>
            """,
            "ar",
            "More than one html tag",
        )
        self.assert_html_raises(
            """
            <html dir="rtl">
            </html>
            """,
            "ar",
            "html is missing a lang attribute",
        )
        self.assert_html_raises(
            """
            <html lang="ar">
            </html>
            """,
            "ar",
            "html is missing a dir attribute",
        )
        self.assert_html_raises(
            """
            <html lang="en" dir="rtl">
            </html>
            """,
            "ar",
            "Unexpected lang attribute: en",
        )
        self.assert_html_raises(
            """
            <html lang="en" dir="LTR">
            </html>
            """,
            "en",
            "Unexpected dir attribute: LTR",
        )
        self.assert_html_raises(
            """
            <html lang="en" dir="auto">
            </html>
            """,
            "en",
            "Unexpected dir attribute: auto",
        )

    def test_head_ignored(self) -> None:
        # Most of the tags and attributes in the head are ignored.
        self.assert_html_out(
            """
            <html lang="ar" dir="rtl" other="blah">
            <head attr="ignored">
                <meta charset="utf-8">
                <meta content="width=device-width, initial-scale=1.0" name="viewport" />
                <meta http-equiv="Content-Security-Policy" content="default-src 'self'">
                <link rel="stylesheet" href="../assets1/style1.css" other="blah">
                <link rel="other" href="https://example.org">
                <title some-attr="blah">دليل استخدام متصفح تور</title>
                <script src="https://example.org"></script>
                <script src="../script.js"></script>
                <script>
                  const val = "hello";
                </script>
                <div>oops</div>
                <style>
                  body {
                    display: none;
                  }
                </style>
            </head>
            <div>oops</div>
            <body>
            </body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>دليل استخدام متصفح تور</title>
              {EXPECT_SCRIPT}
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__assets1__style1.css" />
            </head>
            <body>
            </body>
            </html>
            """,
            {"html__assets1__style1.css": "html/assets1/style1.css"},
        )

    def test_title(self) -> None:
        # NOTE: Expected to fail in python 3.13.5, 3.12.11, 3.11.12, 3.10.18,
        # 3.9.22 and earlier, due to a bug in html.parser, which fails to treat
        # the "<div>" as text content. This should not cause any issues in
        # practice, since the title is not expected include a raw <.
        # It is tested here for robustness.
        self.assert_html_out(
            """
            <html lang="ar" dir="rtl">
            <head>
              <title>title content <div> 'more"</title>
            </head>
            <body>
            </body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>title content &lt;div&gt; 'more"</title>
              {EXPECT_SCRIPT}
            </head>
            <body>
            </body>
            </html>
            """,
            {},
        )
        # <title> elements outside the <head> are ignored.
        self.assert_html_out(
            """
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
            </head>
            <title>Some other title</title>
            <body>
              <title>Body title</title>
            </body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>Test</title>
              {EXPECT_SCRIPT}
            </head>
            <body>
              <title>Body title</title>
            </body>
            </html>
            """,
            {},
        )

    def test_stylesheets(self) -> None:
        self.assert_html_out(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="../assets1/style1.css">
              <link rel="stylesheet" href="../../assets2/sub/style2.css?query=ignored">
              <link rel="stylesheet" href="/assets2/style2.css#anchor-ignored">
              <link rel="stylesheet" href="neighbour1.css">
              <link rel="stylesheet" href="./neighbour2.css">
              <title>دليل استخدام متصفح تور</title>
            </head>
            <body>
            </body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>دليل استخدام متصفح تور</title>
              {EXPECT_SCRIPT}
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__assets1__style1.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/assets2__sub__style2.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/assets2__style2.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__html__neighbour1.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__html__neighbour2.css" />
            </head>
            <body>
            </body>
            </html>
            """,
            {
                "html__assets1__style1.css": "html/assets1/style1.css",
                "assets2__sub__style2.css": "assets2/sub/style2.css",
                "assets2__style2.css": "assets2/style2.css",
                "html__html__neighbour1.css": "html/html/neighbour1.css",
                "html__html__neighbour2.css": "html/html/neighbour2.css",
            },
        )

        # Stylesheets and img references are treated the same.
        self.assert_html_out(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="../assets1/style1.css">
              <link rel="stylesheet" href="/assets2/sub/style2.css">
              <link rel="stylesheet" href="neighbour2.css">
              <title>دليل استخدام متصفح تور</title>
            </head>
            <body>
              <img src="../assets1/image1.png">
              <img src="/assets2/image2.png">
              <img src="neighbour2.svg">
            </body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>دليل استخدام متصفح تور</title>
              {EXPECT_SCRIPT}
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__assets1__style1.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/assets2__sub__style2.css" />
              <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/html__html__neighbour2.css" />
            </head>
            <body>
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1__image1.png" />
              <img src="{EXPECT_CHROME_ASSETS}/assets2__image2.png" />
              <img src="{EXPECT_CHROME_ASSETS}/html__html__neighbour2.svg" />
            </body>
            </html>
            """,
            {
                "html__assets1__style1.css": "html/assets1/style1.css",
                "assets2__sub__style2.css": "assets2/sub/style2.css",
                "html__html__neighbour2.css": "html/html/neighbour2.css",
                "html__assets1__image1.png": "html/assets1/image1.png",
                "assets2__image2.png": "assets2/image2.png",
                "html__html__neighbour2.svg": "html/html/neighbour2.svg",
            },
        )

        # Invalid stylesheets.
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="https://example.org">
            </head>
            </html>
            """,
            "ar",
            "Unexpected asset path with a scheme: https",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="./style.css">
            </head>
            </html>
            """,
            "ar",
            f"References a non-existent asset: {self.top_dir}/html/html/style.css",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="style.css">
            </head>
            </html>
            """,
            "ar",
            f"References a non-existent asset: {self.top_dir}/html/html/style.css",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="/style.css">
            </head>
            </html>
            """,
            "ar",
            f"References a non-existent asset: {self.top_dir}/style.css",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="../../../style.css">
            </head>
            </html>
            """,
            "ar",
            f"References an asset outside {self.top_dir}",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="/../style.css">
            </head>
            </html>
            """,
            "ar",
            f"References an asset outside {self.top_dir}",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href="../none.css">
            </head>
            </html>
            """,
            "ar",
            f"References a non-existent asset: {self.top_dir}/html/none.css",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet">
            </head>
            </html>
            """,
            "ar",
            "stylesheet link missing an href",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <link rel="stylesheet" href>
            </head>
            </html>
            """,
            "ar",
            "stylesheet link missing an href",
        )

    def test_tag_tracking(self) -> None:
        # Convert a self-closing non-void tag into a pair of tags with no content.
        self.assert_body_out(
            """
            <body>
              <div class="ok" />
            </body>
            """,
            """
            <body>
              <div class="ok"></div>
            </body>
            """,
            {},
        )
        # Convert a void tag into a self-closing tag.
        self.assert_body_out(
            """
            <body>
              <img class="ok">
              <br>
              <hr>
              <hr />
            </body>
            """,
            """
            <body>
              <img class="ok" />
              <br />
              <hr />
              <hr />
            </body>
            """,
            {},
        )

        # Trying to close a void tag.
        # Missing the </div>.
        self.assert_body_raises(
            """
            <body>
              <img></img>
            </body>
            """,
            "Unmatched end tag: img",
        )
        # Missing the </div>.
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
              <div>
            </head>
            <body>
            </body>
            </html>
            """,
            "ar",
            "Unmatched end tag: head",
        )
        # Closing tag with no starting tag.
        self.assert_body_raises(
            """
            <body>
              </div >
            </body>
            """,
            "Unmatched end tag: div",
        )
        # Missing the </div>
        self.assert_body_raises(
            """
            <body>
              <div>
            </body>
            """,
            "Unmatched end tag: body",
        )
        # Missing the closing </html>
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
            </head>
            <body>
            </body>
            """,
            "ar",
            "Document was not closed",
        )
        # Closing an unmatched tag in the outer scope.
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
            </head>
            <body>
            </body>
            </html>
            </div>
            """,
            "ar",
            "Unmatched end tag: div",
        )

        # Duplicate attributes.
        self.assert_body_raises(
            """
            <body class="ok" class="other"></body>
            """,
            "body has a duplicate attribute: class",
        )

    def test_misc_data(self) -> None:
        # Comments are ignored.
        self.assert_body_out(
            """
            <body>
              <div>a<!-- hello -->b<! hello ></div></ bogus comment>
            </body>
            """,
            """
            <body>
              <div>ab</div>
            </body>
            """,
            {},
        )
        # Attributes and content are escaped.
        self.assert_body_out(
            """
            <body>
              <div empty-attr attr2="'hello" attr='"<div>inject'>x < "6"</div attr2="hello">
            </body>
            """,
            """
            <body>
              <div empty-attr attr2="&#x27;hello" attr="&quot;&lt;div&gt;inject">x &lt; "6"</div>
            </body>
            """,
            {},
        )

        # CDATA.
        self.assert_body_raises(
            """
            <body>
              <div>
                <![CDATA[<img class="ok">]]>
              </div>
            </body>
            """,
            "Unknown declaration",
        )

        # A doctype html at the start is ok.
        self.assert_html_out(
            """
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              <title>Test</title>
            </head>
            <body></body>
            </html>
            """,
            "ar",
            f"""
            <!DOCTYPE html>
            <html lang="ar" dir="rtl">
            <head>
              {EXPECT_CSP_META}
              <title>Test</title>
              {EXPECT_SCRIPT}
            </head>
            <body></body>
            </html>
            """,
            {},
        )
        # Other declarations are not ok.
        self.assert_html_raises(
            """
            <!DOCTYPE other>
            <html></html>
            """,
            "ar",
            "Unexpected declaration",
        )
        # Declaration further down.
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
            <!DOCTYPE html>
            </html>
            """,
            "ar",
            "Unexpected declaration",
        )
        # Processing instruction.
        self.assert_body_raises(
            """
            <body>
              <?xml-stylesheet href="style.css"?>
            </body>
            """,
            "Unexpected processing instruction",
        )

    def test_body_tag(self) -> None:
        # Attributes are preserved.
        self.assert_body_out(
            """
            <body class="my-class" attr="blah">
              <div></div>
            </body>
            """,
            """
            <body class="my-class" attr="blah">
              <div></div>
            </body>
            """,
            {},
        )
        # Invalid.
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
              <div>
                <body>
                </body>
              </div>
            </html>
            """,
            "ar",
            "Wrong context for the body tag",
        )
        self.assert_html_raises(
            """
            <html lang="ar" dir="rtl">
              <body>
              </body>
              <div></div>
              <body></body>
            </html>
            """,
            "ar",
            "More than one body tag",
        )
        self.assert_body_raises(
            """
            <body>
              <div>
                <body></body>
              </div>
            </body>
            """,
            "Unexpected body tag in body",
        )
        self.assert_body_raises(
            """
            <body>
              <main>
                <script src="inject">
                </script>
              </main>
            </body>
            """,
            "Unexpected script tag in body",
        )
        self.assert_body_raises(
            """
            <body>
              <main>
                <SCRIpT>const val = "inject";</SCRIpT>
              </main>
            </body>
            """,
            "Unexpected script tag in body",
        )
        self.assert_body_raises(
            """
            <body>
              <meta http-equiv="Content-Security-Policy" content="default-src 'self'">
            </body>
            """,
            "Unexpected meta tag in body",
        )
        self.assert_body_raises(
            """
            <body>
              <link href="inject">
            </body>
            """,
            "Unexpected link tag in body",
        )
        self.assert_body_raises(
            "<body><noscript></noscript></body>", "Unexpected noscript tag in body"
        )
        self.assert_body_raises(
            "<body><html>content</html></body>", "Unexpected html tag in body"
        )
        self.assert_body_raises(
            "<body><head></head></body>", "Unexpected head tag in body"
        )

    def test_img_tag(self) -> None:
        self.assert_body_out(
            """
            <body>
              <img src="../assets1/image1.png">
            </body>
            """,
            f"""
            <body>
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1__image1.png" />
            </body>
            """,
            {"html__assets1__image1.png": "html/assets1/image1.png"},
        )
        # Multiple and duplicates.
        self.assert_body_out(
            """
            <body>
              <img src="../assets1/image1.png">

              <div>
                <img src="../assets1/image1.png">
                <p>
                  <img src="../../assets2/image2.png" alt="hello"/>
                  <img src="./neighbour1.svg">
                </p>
                <img src="../../assets2/sub/image2.png"
                ><br>
                <img src="/assets2/sub/image2.png">
                <img src="neighbour1.svg">
                <img src="./neighbour2.svg">
              </div>
            </body>
            """,
            f"""
            <body>
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1__image1.png" />

              <div>
                <img src="{EXPECT_CHROME_ASSETS}/html__assets1__image1.png" />
                <p>
                  <img src="{EXPECT_CHROME_ASSETS}/assets2__image2.png" alt="hello" />
                  <img src="{EXPECT_CHROME_ASSETS}/html__html__neighbour1.svg" />
                </p>
                <img src="{EXPECT_CHROME_ASSETS}/assets2__sub__image2.png" /><br />
                <img src="{EXPECT_CHROME_ASSETS}/assets2__sub__image2.png" />
                <img src="{EXPECT_CHROME_ASSETS}/html__html__neighbour1.svg" />
                <img src="{EXPECT_CHROME_ASSETS}/html__html__neighbour2.svg" />
              </div>
            </body>
            """,
            {
                "html__assets1__image1.png": "html/assets1/image1.png",
                "assets2__image2.png": "assets2/image2.png",
                "assets2__sub__image2.png": "assets2/sub/image2.png",
                "html__html__neighbour1.svg": "html/html/neighbour1.svg",
                "html__html__neighbour2.svg": "html/html/neighbour2.svg",
            },
        )

        # Invalid.
        self.assert_body_raises(
            """
            <body>
              <img src="https://example.org">
            </body>
            """,
            "Unexpected asset path with a scheme: https",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="./image.png">
            </body>
            """,
            f"References a non-existent asset: {self.top_dir}/html/html/image.png",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="image.png">
            </body>
            """,
            f"References a non-existent asset: {self.top_dir}/html/html/image.png",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="/image.png">
            </body>
            """,
            f"References a non-existent asset: {self.top_dir}/image.png",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="../../../image.css">
            </body>
            """,
            f"References an asset outside {self.top_dir}",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="/../image.css">
            </body>
            """,
            f"References an asset outside {self.top_dir}",
        )
        self.assert_body_raises(
            """
            <body>
              <img src="../none.png">
            </body>
            """,
            f"References a non-existent asset: {self.top_dir}/html/none.png",
        )
        self.assert_body_raises(
            """
            <body>
              <img srcset="../assets1/image1.png 2x, ../assets1/image1.png" />
            </body>
            """,
            "Unhandled srcset attribute",
        )

        # Special characters are substituted to safe characters.
        self.assert_body_out(
            """
            <body>
              <img src="../assets1/🦭.svg">
            </body>
            """,
            f"""
            <body>
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1___.svg" />
            </body>
            """,
            {"html__assets1___.svg": "html/assets1/🦭.svg"},
        )
        self.assert_body_out(
            """
            <body>
              <img src="../assets1/~.svg">
              <img src="../assets1/image@2x.png">
            </body>
            """,
            f"""
            <body>
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1___.svg" />
              <img src="{EXPECT_CHROME_ASSETS}/html__assets1__image_2x.png" />
            </body>
            """,
            {
                "html__assets1___.svg": "html/assets1/~.svg",
                "html__assets1__image_2x.png": "html/assets1/image@2x.png",
            },
        )
        # Conflicting names.
        self.assert_body_raises(
            """
            <body>
              <img src="../assets1/~.svg">
              <img src="../assets1/🦭.svg">
            </body>
            """,
            "More than one asset with the same name: html__assets1___.svg",
        )

    def test_a_tag(self) -> None:
        # Internal or no href.
        self.assert_body_out(
            """
            <body>
              <div>
                <a href="#index">index</a>
                <a href="#index" rel="author" class="ok">in<span>d</span>ex</a>
                <a rel="author noreferrer">none</a>
              </div>
              <div id="index"></div>
            </body>
            """,
            """
            <body>
              <div>
                <a href="#index">index</a>
                <a href="#index" class="ok">in<span>d</span>ex</a>
                <a>none</a>
              </div>
              <div id="index"></div>
            </body>
            """,
            {},
        )

        # External.
        self.assert_body_out(
            """
            <body>
              <a href="https://example.org">example</a>
              <a href="https://example.org?query=ok" rel="noopener" class="hello">example2</a>
              <a href="https://example.net" referrerpolicy="no-referrer" target="self">example3</a>
            </body>
            """,
            """
            <body>
              <a href="https://example.org" target="_blank" rel="noreferrer">example</a>
              <a href="https://example.org?query=ok" class="hello" target="_blank" rel="noreferrer">example2</a>
              <a href="https://example.net" target="_blank" rel="noreferrer">example3</a>
            </body>
            """,
            {},
        )

        # Relative: tor-browser.
        self.assert_body_out(
            """
            <body>
              <a href="../../tor-browser/sub-page/">other section</a>
              <a href="../../tor-browser/sub-page" rel="author prev">other section2</a>
              <div>
                <a href="../../tor-browser/sub-page#anchor">other section3</a>
                <a href="../../tor-browser/sub-page/further#anchor" class="ok">other section4</a>
              </div>
              <div id="sub-page">
                <span id="sub-page___anchor"></span>
                <div id="sub-page__further">
                  <span id="sub-page__further___anchor"></span>
                </div>
              </div>
            </body>
            """,
            """
            <body>
              <a href="#sub-page">other section</a>
              <a href="#sub-page">other section2</a>
              <div>
                <a href="#sub-page___anchor">other section3</a>
                <a href="#sub-page__further___anchor" class="ok">other section4</a>
              </div>
              <div id="sub-page">
                <span id="sub-page___anchor"></span>
                <div id="sub-page__further">
                  <span id="sub-page__further___anchor"></span>
                </div>
              </div>
            </body>
            """,
            {},
        )
        # A plain "tor-browser/" will point to "#index" as a special case.
        self.assert_body_out(
            """
            <body>
              <a href="../../tor-browser/">top</a>
              <div id="index"></div>
            </body>
            """,
            """
            <body>
              <a href="#index">top</a>
              <div id="index"></div>
            </body>
            """,
            {},
        )
        # Relative: outside tor-browser and get-in-touch.
        self.assert_body_out(
            """
            <body>
              <a href="../../tor-vpn/sub-page">Tor VPN</a>
              <a href="../../tor-vpn/sub-page?query=ok#anchor">Tor VPN</a>
            </body>
            """,
            """
            <body>
              <a href="https://support.torproject.org/ar/tor-vpn/sub-page" target="_blank" rel="noreferrer">Tor VPN</a>
              <a href="https://support.torproject.org/ar/tor-vpn/sub-page#anchor" target="_blank" rel="noreferrer">Tor VPN</a>
            </body>
            """,
            {},
            locale="ar",
        )
        # For the "en" locale, we do not include /en/ in the support URL.
        self.assert_body_out(
            """
            <body>
              <a href="../../tor-vpn/sub-page">Tor VPN</a>
              <a href="../../tor-vpn/sub-page?query=ok#anchor">Tor VPN</a>
            </body>
            """,
            """
            <body>
              <a href="https://support.torproject.org/tor-vpn/sub-page" target="_blank" rel="noreferrer">Tor VPN</a>
              <a href="https://support.torproject.org/tor-vpn/sub-page#anchor" target="_blank" rel="noreferrer">Tor VPN</a>
            </body>
            """,
            {},
            locale="en",
        )
        # Relative: get-in-touch.
        # Only "bug-or-feedback" or "user-support" is expected.
        self.assert_body_out(
            """
            <body>
              <a href="../../get-in-touch/bug-or-feedback" class="hello">bug</a>
              <a href="../../get-in-touch/user-support#anchor">support</a>
              <a href="../../get-in-touch/other">get in touch other</a>
              <a href="../../get-in-touch">get in touch top</a>
              <div id="get-in-touch__bug-or-feedback"></div>
              <div id="get-in-touch__user-support___anchor"></div>
            </body>
            """,
            """
            <body>
              <a href="#get-in-touch__bug-or-feedback" class="hello">bug</a>
              <a href="#get-in-touch__user-support___anchor">support</a>
              <a href="https://support.torproject.org/ar/get-in-touch/other" target="_blank" rel="noreferrer">get in touch other</a>
              <a href="https://support.torproject.org/ar/get-in-touch" target="_blank" rel="noreferrer">get in touch top</a>
              <div id="get-in-touch__bug-or-feedback"></div>
              <div id="get-in-touch__user-support___anchor"></div>
            </body>
            """,
            {},
            locale="ar",
        )

        # mailto href is removed.
        self.assert_body_out(
            """
            <body>
              <a href="mailto:me@email.org" class="ok">email</a>
            </body>
            """,
            """
            <body>
              <a class="ok">email</a>
            </body>
            """,
            {},
        )

        # Missing internal id.
        self.assert_body_raises(
            """
            <body>
              <a href="#top"></a>
            </body>
            """,
            "Missing an element with the id top",
        )

        # Missing internal id.
        self.assert_body_raises(
            """
            <body>
              <a href="../../tor-browser/sub-page"></a>
            </body>
            """,
            "Missing an element with the id sub-page",
        )

        # Unhandled hrefs.
        self.assert_body_raises(
            """
            <body>
              <a href="../page"></a>
            </body>
            """,
            "Unexpected href: ../page",
        )
        self.assert_body_raises(
            """
            <body>
              <a href="chrome://page"></a>
            </body>
            """,
            "Unexpected href: chrome://page",
        )
        self.assert_body_raises(
            """
            <body>
              <a href="../../../page"></a>
            </body>
            """,
            "Unexpected path: ../../../page",
        )
        self.assert_body_raises(
            """
            <body>
              <a href="../../page/./"></a>
            </body>
            """,
            "Unexpected path: ../../page/./",
        )
        self.assert_body_raises(
            """
            <body>
              <a href="../../page/../other"></a>
            </body>
            """,
            "Unexpected path: ../../page/../other",
        )

    def test_ids(self) -> None:
        # The "id" of the heading-anchor adopts a prefix from the nearest
        # olm-page.
        self.assert_body_out(
            """
            <body>
              <div class="other olm-page" id="somesection">
                <main>
                  <div id="somename" class="heading-anchor other"></div>
                  <h2>Some heading</h2>
                </main>
              </div>
            </body>
            """,
            """
            <body>
              <div class="other olm-page" id="somesection">
                <main>
                  <div id="somesection___somename" class="heading-anchor other"></div>
                  <h2>Some heading</h2>
                </main>
              </div>
            </body>
            """,
            {},
        )

        # Multiple.
        self.assert_body_out(
            """
            <body>
              <div class="other olm-page" id="somesection">
                <main>
                  <div id="somename" class="heading-anchor other"></div>
                  <h2>Some heading</h2>
                </main>
              </div>
              <div>
                <div class="olm-page" id="somesection__2">
                  <main>
                    <div>
                      <div id="somename2" class="heading-anchor"></div>
                      <h2>Some heading</h2>
                    </div>
                  </main>
                </div>
              </div>
            </body>
            """,
            """
            <body>
              <div class="other olm-page" id="somesection">
                <main>
                  <div id="somesection___somename" class="heading-anchor other"></div>
                  <h2>Some heading</h2>
                </main>
              </div>
              <div>
                <div class="olm-page" id="somesection__2">
                  <main>
                    <div>
                      <div id="somesection__2___somename2" class="heading-anchor"></div>
                      <h2>Some heading</h2>
                    </div>
                  </main>
                </div>
              </div>
            </body>
            """,
            {},
        )

        # Duplicate ids.
        self.assert_body_raises(
            """
            <body>
              <div id="first"></div>
              <div id="first"></div>
            </body>
            """,
            "Duplicate id: first",
        )
        self.assert_body_raises(
            """
            <body>
              <div id="somesection___somename"></div>
              <div class="olm-page" id="somesection">
                <div id="somename" class="heading-anchor"></div>
              </div>
            </body>
            """,
            "Duplicate id: somesection___somename",
        )

        # Ignore duplicate ids on a toggler element.
        # TODO: tor-browser-build#41818. Remove this part of the test.
        self.assert_body_out(
            """
            <body>
              <div id="first"></div>
              <input id="first" class="toggler">
            </body>
            """,
            """
            <body>
              <div id="first"></div>
              <input class="toggler" />
            </body>
            """,
            {},
        )

        # Nested olm-page.
        self.assert_body_raises(
            """
            <body>
              <div class="olm-page" id="outer">
                <main>
                  <div class="olm-page" id="outer__sub"></div>
                </main>
              </div>
            </body>
            """,
            "olm-page is below another",
        )

        # olm-page with no id.
        self.assert_body_raises(
            """
            <body>
              <div class="olm-page"></div>
            </body>
            """,
            "olm-page is missing an id",
        )

        # Missing olm-page.
        self.assert_body_raises(
            """
            <body>
              <div class="olm-page" id="ok"></div>
              <div class="heading-anchor" id="ok2"></div>
            </body>
            """,
            "Missing a page to use for the heading id",
        )

        # heading-anchor with no id.
        self.assert_body_raises(
            """
            <body>
              <div class="olm-page" id="ok">
                <div class="heading-anchor"></div>
              </div>
            </body>
            """,
            "Heading is missing an id",
        )


class TestMain(unittest.TestCase):
    # Set the TestCase.maxDiff to a larger number to see the full HTML.
    maxDiff = 2000

    def setUp(self) -> None:
        self.root_dir = tempfile.mkdtemp()
        try:
            os.chdir(self.root_dir)
            self.public_dir = os.path.join(self.root_dir, "public")
            self.out_dir = os.path.join(self.root_dir, "output")
            self.out_locales = os.path.join(self.root_dir, "locales/available")
            os.mkdir(self.public_dir)
            os.mkdir(self.out_dir)
            os.mkdir(os.path.dirname(self.out_locales))
        except:
            shutil.rmtree(self.root_dir)
            raise

    def tearDown(self) -> None:
        shutil.rmtree(self.root_dir)

    def assert_out_content(self, path: str, expect_content: str) -> None:
        with open(os.path.join(self.out_dir, path), encoding="utf-8") as file:
            self.assertEqual(file.read(), expect_content)

    def test_locales(self) -> None:
        base = "offline/tor-browser/index.html"
        for locale, rel_path in (
            ("en", base),
            ("ar", f"ar/{base}"),
            ("zh-CN", f"zh-CN/{base}"),
            # Locales with the wrong lang tags should be ignored.
            ("inv", f"inv/{base}"),
            ("in-VAL", f"in-VAL/{base}"),
            (",", f",/{base}"),
        ):
            path = os.path.join(self.public_dir, rel_path)
            os.makedirs(os.path.dirname(path))
            with open(path, "w", encoding="utf-8") as file:
                file.write(
                    "<!DOCTYPE html>"
                    f'<html lang={locale} dir="rtl">'
                    f"<head><title>{locale} manual</title></head><body>"
                    '<a href="../../other">content</a>'
                    '<a href="../../tor-browser/sub-page"></a><div id="sub-page"></div>'
                    "</body></html>"
                )
        # Directories with the correct code, but no index.html file in the
        # expected place are ignored.
        os.makedirs(os.path.join(self.public_dir, "js"))
        os.makedirs(os.path.join(self.public_dir, "de/offline/tor-browser"))
        # File in wrong place:
        open(
            os.path.join(self.public_dir, "de/offline/index.html"),
            "w",
            encoding="utf-8",
        ).close()
        # Not a file:
        os.makedirs(os.path.join(self.public_dir, f"bb/{base}"))

        main(self.public_dir, self.out_dir, self.out_locales)

        self.assertCountEqual(
            os.listdir(self.out_dir),
            [
                "assets",
                "aboutManual-en.html",
                "aboutManual-ar.html",
                "aboutManual-zh-CN.html",
            ],
        )
        self.assertEqual(os.listdir(os.path.join(self.out_dir, "assets")), [])

        with open(self.out_locales, encoding="utf-8") as file:
            self.assertEqual(file.read(), "ar,en,zh-CN", "list matches")

        for locale, is_default in (("en", True), ("ar", False), ("zh-CN", False)):
            filename = f"aboutManual-{locale}.html"
            support_page = (
                "https://support.torproject.org/other"
                if is_default
                else f"https://support.torproject.org/{locale}/other"
            )
            self.assert_out_content(
                filename,
                "<!DOCTYPE html>\n"
                f'<html lang="{locale}" dir="rtl">\n<head>\n'
                f"  {EXPECT_CSP_META}\n"
                f"  <title>{locale} manual</title>\n"
                f"  {EXPECT_SCRIPT}\n"
                "</head>\n<body>"
                f'<a href="{support_page}" target="_blank" rel="noreferrer">content</a>'
                '<a href="#sub-page"></a><div id="sub-page"></div>'
                "</body>\n</html>\n",
            )

        # Missing default locale's HTML.
        default_html = os.path.join(self.public_dir, base)
        os.unlink(default_html)
        with self.assertRaisesRegex(
            ValueError, rf"Missing file: {re.escape(default_html)}"
        ):
            main(self.public_dir, self.out_dir, self.out_locales)

    def test_assets(self) -> None:
        def write_html(
            path: str, locale: str, style1: str, style2: str, image1: str, image2: str
        ) -> None:
            path = os.path.join(self.public_dir, path)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as file:
                file.write(
                    "<!DOCTYPE html>\n"
                    f'<html lang={locale} dir="rtl">\n'
                    "<head>"
                    f'<link rel="stylesheet" href={style1}>'
                    "<title>Test</title>"
                    f'<link rel="stylesheet" href={style2}>'
                    "</head><body>"
                    f'<img src="{image1}"><img src="{image2}">'
                    "</body></html>"
                )

        for rel_path, content in (
            ("offline/ltr.min.css", "0"),
            ("offline/rtl.min.css", "1"),
            ("static/style.css", "2"),
            ("offline/image.png", "3"),
            ("ar/offline/image.png", "4"),
            ("sub/page/image@2x.png", "5"),
            ("sub/page/image~2x.png", "6"),
        ):
            orig_path = os.path.join(self.public_dir, rel_path)
            os.makedirs(os.path.dirname(orig_path), exist_ok=True)
            with open(orig_path, "w", encoding="utf-8") as file:
                file.write(content)

        write_html(
            "offline/tor-browser/index.html",
            "en",
            "../ltr.min.css",
            "../../static/style.css",
            "../image.png",
            "../../sub/page/image@2x.png",
        )
        write_html(
            "ar/offline/tor-browser/index.html",
            "ar",
            "../../../offline/rtl.min.css",
            "../../../static/style.css",
            "../image.png",
            "../../../sub/page/image@2x.png",
        )

        main(self.public_dir, self.out_dir, self.out_locales)

        self.assertCountEqual(
            os.listdir(self.out_dir),
            ["assets", "aboutManual-en.html", "aboutManual-ar.html"],
        )
        self.assertCountEqual(
            os.listdir(os.path.join(self.out_dir, "assets")),
            [
                "offline__ltr.min.css",
                "offline__rtl.min.css",
                "static__style.css",
                "offline__image.png",
                "ar__offline__image.png",
                "sub__page__image_2x.png",
            ],
        )

        self.assert_out_content(
            "aboutManual-en.html",
            "<!DOCTYPE html>\n"
            '<html lang="en" dir="rtl">\n'
            "<head>\n"
            f"  {EXPECT_CSP_META}\n"
            "  <title>Test</title>\n"
            f"  {EXPECT_SCRIPT}\n"
            f'  <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/offline__ltr.min.css" />\n'
            f'  <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/static__style.css" />\n'
            "</head>\n<body>"
            f'<img src="{EXPECT_CHROME_ASSETS}/offline__image.png" />'
            f'<img src="{EXPECT_CHROME_ASSETS}/sub__page__image_2x.png" />'
            "</body>\n</html>\n",
        )

        self.assert_out_content(
            "aboutManual-ar.html",
            "<!DOCTYPE html>\n"
            '<html lang="ar" dir="rtl">\n'
            "<head>\n"
            f"  {EXPECT_CSP_META}\n"
            "  <title>Test</title>\n"
            f"  {EXPECT_SCRIPT}\n"
            f'  <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/offline__rtl.min.css" />\n'
            f'  <link rel="stylesheet" href="{EXPECT_CHROME_ASSETS}/static__style.css" />\n'
            "</head>\n<body>"
            f'<img src="{EXPECT_CHROME_ASSETS}/ar__offline__image.png" />'
            f'<img src="{EXPECT_CHROME_ASSETS}/sub__page__image_2x.png" />'
            "</body>\n</html>\n",
        )

        # Make sure the new assets were copied over.
        self.assert_out_content("assets/offline__ltr.min.css", "0")
        self.assert_out_content("assets/offline__rtl.min.css", "1")
        self.assert_out_content("assets/static__style.css", "2")
        self.assert_out_content("assets/offline__image.png", "3")
        self.assert_out_content("assets/ar__offline__image.png", "4")
        self.assert_out_content("assets/sub__page__image_2x.png", "5")

        # Duplicate asset names, from different files.
        write_html(
            "offline/tor-browser/index.html",
            "en",
            "../ltr.min.css",
            "../../static/style.css",
            "../image.png",
            "../../sub/page/image~2x.png",
        )
        with self.assertRaisesRegex(
            ValueError, r"^Duplicate asset names: sub__page__image_2x.png$"
        ):
            main(self.public_dir, self.out_dir, self.out_locales)

        # Wrong relative path.
        write_html(
            "ar/offline/tor-browser/index.html",
            "ar",
            "../../../offline/rtl.min.css",
            # Wrong relative path for the "ar" directory:
            "../static/style.css",
            "../image.png",
            "../../../sub/page/image~2x.png",
        )
        with self.assertRaisesRegex(
            ValueError,
            r"^.*: References a non-existent asset: .*/ar/offline/static/style\.css$",
        ):
            main(self.public_dir, self.out_dir, self.out_locales)
