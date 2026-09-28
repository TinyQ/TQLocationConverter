# Contributing

[简体中文](CONTRIBUTING.md)

Issues, documentation fixes and code improvements are welcome. Small fixes can go straight to a PR. For new coordinate systems or default behavior changes, open an issue with the use case and evidence first.

## Local development

Use Swift 6.0+. Apple-platform, Objective‑C and DocC checks require Xcode; the Swift core builds on Linux. No third-party package dependencies are needed.

```sh
swift test
swift test -c release
swift run -c release ConversionBenchmark
python3 Scripts/check-docs.py
# macOS
bash Scripts/test-objc.sh
xcrun swift-format lint --strict --recursive Package.swift Sources Tests Benchmarks
```

Format with `xcrun swift-format format --in-place --recursive Package.swift Sources Tests Benchmarks`. CI tests both languages on macOS and Swift 6.0 and 6.2 on Linux.

## Algorithm changes

1. Identify whether the change affects the forward model, inverse solver or region policy. Round-trip error is not geographic accuracy.
2. Keep fixture provenance and pinned revisions. Use public test points, never private user location data.
3. Update Swift and Objective‑C together. Run parity tests and cover inside/outside regions, edges, invalid input and regressions.
4. Bound inverse iteration and provide a failure path; never silently return an unconverged guess.
5. Constants and polygon changes affect compatibility. Keep both language tables synchronized and explain the evidence.
6. Update both language guides, migration notes and the Unreleased changelog.

## Pull requests

Describe the concrete problem, resulting behavior, validation and compatibility impact. Keep changes focused and omit generated caches, personal IDE settings and build outputs. Explain any new dependency and its license.

For bug reports, include toolchain/OS versions, source and destination systems, region policy, public reproducible input, expected output and its provenance. English and Chinese are both welcome.

Maintainers should follow the [release checklist](Documentation/Releasing.md). Contributions are provided under the project's MIT license.
