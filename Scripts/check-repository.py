#!/usr/bin/env python3
"""Reject tracked local metadata and generated files, even when added with git add -f."""
from pathlib import Path, PurePosixPath
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0')
forbidden_parts = {
    '.DS_Store', 'Thumbs.db', 'desktop.ini', '__MACOSX', '.AppleDouble',
    '.Spotlight-V100', '.Trashes', '.build', '.swiftpm', 'DerivedData',
    'xcuserdata', '__pycache__', '.bundle',
}
forbidden_suffixes = {'.pyc', '.pyo', '.swp', '.swo', '.xcuserstate'}
failures = []
for path in filter(None, paths):
    parts = PurePosixPath(path).parts
    if (forbidden_parts.intersection(parts)
            or any(part.startswith('._') or part.endswith('.doccarchive') for part in parts)
            or PurePosixPath(path).suffix in forbidden_suffixes
            or ('vendor', 'bundle') in zip(parts, parts[1:])):
        failures.append(path)
if failures:
    print('Remove these generated or personal files from Git:', file=sys.stderr)
    print('\n'.join(failures), file=sys.stderr)
    sys.exit(1)
print('Tracked files contain no known local metadata or generated caches.')
