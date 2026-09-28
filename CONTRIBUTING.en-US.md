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
python3 Scripts/check-repository.py
# macOS
bash Scripts/test-objc.sh
xcrun swift-format lint --strict --recursive Package.swift Sources Tests Benchmarks
```

Format with `xcrun swift-format format --in-place --recursive Package.swift Sources Tests Benchmarks`. CI tests both languages on macOS and Swift 6.0 and 6.2 on Linux.

### CocoaPods integration checks

For changes to Objective-C, the podspec or integration, use Ruby 3.4, Bundler and Xcode 16.4:

```sh
bundle install
bundle exec pod lib lint TQLocationConverter.podspec
bundle exec ruby Scripts/test-cocoapods.rb
```

`Gemfile.lock` pins development tools; the conversion libraries have no third-party runtime dependencies. Lint builds and checks all five Apple platforms. Independent macOS consumers install the pod as a static library, static framework and dynamic framework, then compile and run Objective-C and Swift callers in each mode. Generated files stay in `.build/cocoapods/`. To check one mode, pass `static-library`, `static-framework` or `dynamic-framework`.

CI uses Xcode 16.4 to check the declared minimum deployment targets; a build check does not mean tests ran on every older OS. Newer Xcode releases may no longer accept these deployment targets. For example, with Xcode 27, run local consumer checks with `TQ_TEST_MACOS_DEPLOYMENT_TARGET=12.0 bundle exec ruby Scripts/test-cocoapods.rb`. This overrides only the consumer build arguments, does not change the library requirements, and does not replace the minimum-target CI check. Full lint also needs the corresponding simulator runtimes.

The repository check inspects Git's tracked files and rejects `.DS_Store`, build caches and personal IDE settings, including files added using `git add -f`.

## Source layout

- `Sources/TQLocationConverter/`: native Swift implementation and DocC.
- `Sources/TQLocationConverterObjC/`: Objective-C implementation; `include/` holds public headers and the SwiftPM umbrella header.
- `Tests/`: automated tests and independent consumers.
- `Test/`: legacy iOS example; CI builds its app and test bundle.

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
