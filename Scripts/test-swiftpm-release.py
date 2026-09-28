#!/usr/bin/env python3
"""Resolve a remote version in a fresh consumer and verify both products and commit identity."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import urlparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('version', help='Semantic version without a v prefix')
parser.add_argument('--repository', default='https://github.com/TinyQ/TQLocationConverter.git',
                    help='Git URL; a local mirror can be used to rehearse a release')
args = parser.parse_args()
if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?', args.version):
    parser.error('Expected a semantic version such as 1.0.0 or 1.1.0-rc.1')

root = Path(__file__).resolve().parents[1]
expected_commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
parent = root / '.build' / 'release'
parent.mkdir(parents=True, exist_ok=True)
consumer = Path(tempfile.mkdtemp(prefix=args.version + '-', dir=parent))
identity = Path(urlparse(args.repository).path).name.removesuffix('.git').lower()
manifest = '''// swift-tools-version: 6.0
import PackageDescription
let package = Package(
  name: "ReleaseConsumer",
  platforms: [.macOS(.v10_15)],
  dependencies: [.package(url: REPOSITORY, exact: VERSION)],
  targets: [.executableTarget(name: "ReleaseConsumer", dependencies: [
    .product(name: "TQLocationConverter", package: IDENTITY),
    .product(name: "TQLocationConverterObjC", package: IDENTITY),
  ])]
)
'''
for key, value in [('REPOSITORY', args.repository), ('VERSION', args.version), ('IDENTITY', identity)]:
    manifest = manifest.replace(key, json.dumps(value))
(consumer / 'Package.swift').write_text(manifest)
sources = consumer / 'Sources' / 'ReleaseConsumer'
sources.mkdir(parents=True)
shutil.copyfile(root / 'Tests' / 'SwiftPM' / 'main.swift', sources / 'main.swift')
command = ['swift', 'run', '--package-path', str(consumer),
           '--cache-path', str(consumer / '.cache'), '--config-path', str(consumer / '.config'),
           '--security-path', str(consumer / '.security'), '-c', 'release', 'ReleaseConsumer']
subprocess.run(command, check=True)
resolved = json.loads((consumer / 'Package.resolved').read_text())
pin = next(pin for pin in resolved['pins'] if pin['identity'] == identity)
if pin['state'].get('version') != args.version or pin['state']['revision'] != expected_commit:
    raise SystemExit(f'Resolved dependency does not match version {args.version} at {expected_commit}: {pin}')
print(f'Remote SwiftPM {args.version} passed at {expected_commit}; consumer: {consumer}')
