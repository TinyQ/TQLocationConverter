#!/usr/bin/env python3
"""Check repository-local Markdown links; no external requests or third-party dependencies."""
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

root = Path(__file__).resolve().parents[1]
failures = []
count = 0
for path in sorted(root.rglob('*.md')):
    if any(part in {'.git', '.build', '.swiftpm'} for part in path.relative_to(root).parts):
        continue
    text = re.sub(r'```.*?```', '', path.read_text(), flags=re.S)
    for link in re.findall(r'\[[^\]]*\]\(([^)]+)\)', text):
        url = urlsplit(link.strip().split(' "', 1)[0])
        if url.scheme or url.netloc or not url.path:
            continue
        target = (path.parent / unquote(url.path)).resolve()
        count += 1
        if not target.is_file():
            failures.append(f'{path.relative_to(root)}: missing {url.path}')
            continue
        if url.fragment and target.suffix == '.md':
            headings = re.findall(r'^#{1,6}\s+(.+?)\s*#*$', target.read_text(), re.M)
            anchors = {re.sub(r'[^\w\-\s]', '', heading.lower()).strip().replace(' ', '-') for heading in headings}
            if unquote(url.fragment) not in anchors:
                failures.append(f'{path.relative_to(root)}: missing anchor {link}')
if failures:
    print('\n'.join(failures), file=sys.stderr)
    sys.exit(1)
print(f'Checked {count} local Markdown links and their heading anchors.')
