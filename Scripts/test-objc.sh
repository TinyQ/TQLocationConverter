#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/objc-smoke
xcrun clang -fobjc-arc -fmodules -Wall -Wextra -Werror \
  -fmodules-cache-path=.build/objc-smoke/modules -mmacosx-version-min=10.15 -I . \
  -framework Foundation -framework CoreLocation \
  TQLocationConverter.m Tests/ObjectiveC/main.m -o .build/objc-smoke/tests
.build/objc-smoke/tests
