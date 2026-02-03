#!/usr/bin/env python3
import argparse
import csv
import re
import sys
import urllib.parse
from pathlib import Path

import requests
from git import Repo


GITLAB_LABELS = [
    "Apps::Product::TorBrowser",
    "esr-next",
    "Priority::Medium",
    "Apps::Impact::Unknown",
    "Apps::Type::Audit",
]
GITLAB_MILESTONE = "Browser 16.0"


def download_bugs(url):
    url += "&" if "?" in url else "?"
    url += "include_fields=id,product,component,summary"
    r = requests.get(url)
    r.raise_for_status()
    # {"bugs": [ {...}, ... ]}
    bugs = r.json().get("bugs", [])
    results = {}
    for bug in bugs:
        product = bug.get("product", "")
        component = bug.get("component", "")
        results[bug.get("id")] = {
            "id": bug.get("id"),
            "component": f"{product} :: {component}",
            "summary": bug.get("summary", ""),
        }
    return results


def extract_from_git(repo_path, ff_version, bugs):
    subj_regex = re.compile(
        r"^[\s*[bug –-]+\s*([1-9][0-9]*)[\]:\., –-]*(.*)", re.VERBOSE
    )
    # Keep these lowercase
    skip = ["no bug", "merge ", "revert "]

    repo = Repo(repo_path)
    seen_ids = set()
    results = {}
    for commit in repo.iter_commits(
        f"FIREFOX_NIGHTLY_{ff_version - 1}_END..FIREFOX_NIGHTLY_{ff_version}_END",
        reverse=True,
    ):
        subject = commit.message.splitlines()[0]
        subj_low = subject.lower()
        m = subj_regex.search(subj_low)
        if not m:
            if not any(subj_low.startswith(p) for p in skip):
                print(f"Could not match {subject}", file=sys.stderr)
            continue
        bug_id = int(m.group(1))
        if bug_id in bugs or bug_id in seen_ids:
            continue
        seen_ids.add(bug_id)
        summary = m.group(2).strip()
        results[bug_id] = {
            "id": bug_id,
            "component": "(git commit)",
            "summary": summary,
        }

    # Notice that seen_ids contains only the bugs we have seen in the
    # commit range but we did not find earlier.
    # So, we expect this number to be quite low and that it will be
    # possible to fetch all these bugs in a single pass.
    if seen_ids:
        url = "https://bugzilla.mozilla.org/rest/bug?id="
        url += ",".join([str(i) for i in seen_ids])
        results.update(download_bugs(url))
    bugs.update(results)


def make_hyperlink(url, label):
    label = label.replace('"', '""')
    return f'=HYPERLINK("{url}", "{label}")'


def url_encode(s):
    return urllib.parse.quote(s)


def generate_csv(bugs, audit_issue, query, output_path):
    bugs = sorted(bugs.values(), key=lambda x: (x["component"], x["id"]))

    with output_path.open("w") as f:
        writer = csv.writer(f, quoting=csv.QUOTE_ALL)
        writer.writerow(["Review", "", "Bugzilla Component", "Bugzilla Bug"])

        # Keep these lowercase!
        skip = [
            "[wpt-sync] sync pr",
            "assertion failure: ",
            "crash in ",
            "crash [@",
            "hit moz_crash",
            "update android nightly application-services",
            "update web-platform-tests",
        ]
        for bug in bugs:
            bug_id = bug["id"]
            component = bug["component"]
            summary = bug["summary"]
            summary_lower = summary.lower()
            short = (summary[:77] + "...") if len(summary) > 80 else summary

            if any(summary_lower.startswith(p) for p in skip):
                print(f"Skipped Bugzilla {bug_id}: {summary}", file=sys.stderr)
                continue

            bugzilla_url = (
                f"https://bugzilla.mozilla.org/show_bug.cgi?id={bug_id}"
            )
            new_title = url_encode(f"Review Mozilla {bug_id}: {short}")
            new_desc = (
                url_encode(f"### Bugzilla: {bugzilla_url}")
                + "%0A"
                + url_encode("/label ~" + (" ~".join(GITLAB_LABELS)))
                + "%0A"
                + url_encode(f'/milestone %"{GITLAB_MILESTONE}"')
                + "%0A"
                + url_encode(
                    f"/relate tpo/applications/tor-browser#{audit_issue}"
                )
                + "%0A%0A"
                + url_encode(
                    "<!-- briefly describe why this issue needs further review -->"
                )
            )
            new_issue_url = f"https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/new?issue[title]={new_title}&issue[description]={new_desc}"

            create_link = make_hyperlink(new_issue_url, "New Issue")
            bugzilla_link = make_hyperlink(
                bugzilla_url, f"Bugzilla {bug_id}: {summary}"
            )
            writer.writerow(["FALSE", create_link, component, bugzilla_link])

        writer.writerow([])
        writer.writerow([make_hyperlink(query, "Bugzilla query")])


def main():
    parser = argparse.ArgumentParser(
        description="Create a triage CSV for a Firefox version."
    )
    parser.add_argument(
        "-r",
        "--repo-path",
        help="Path to a tor-browser.git clone",
        type=Path,
        default=Path(__file__).parent / "torbrowser",
    )
    parser.add_argument(
        "-o",
        "--output-file",
        help="Path to the output file",
        type=Path,
    )
    parser.add_argument(
        "ff_version",
        help="Firefox rapid-release version (e.g. 150)",
        type=int,
    )
    parser.add_argument(
        "gitlab_audit_issue",
        help="Tor-Browser-Spec GitLab issue number",
        type=int,
    )
    known_args, remaining = parser.parse_known_args()
    parser.set_defaults(
        output_file=Path(f"triage-{known_args.ff_version}.csv")
    )
    args = parser.parse_args()

    if args.ff_version < 140:
        print("Wrong Firefox version (probably)!", file=sys.stderr)
        sys.exit(1)
    if args.gitlab_audit_issue < 40000:
        print("Wrong GitLab issue number (probably)!", file=sys.stderr)
        sys.exit(1)

    excluded_products = "Thunderbird,Calendar,Chat%20Core,MailNews%20Core"
    query = f"https://bugzilla.mozilla.org/rest/bug?f1=product&n1=1&o1=anyexact&v1={excluded_products}&f2=target_milestone&o2=substring&v2={args.ff_version}&limit=0"
    bugs = download_bugs(query)
    extract_from_git(args.repo_path, args.ff_version, bugs)

    generate_csv(
        bugs,
        args.gitlab_audit_issue,
        query,
        args.output_file,
    )


if __name__ == "__main__":
    main()
