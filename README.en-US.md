# TQLocationConverter

**English** · [简体中文](README.md)

A lightweight, offline library for converting **WGS‑84, GCJ‑02 and BD‑09LL** latitude/longitude coordinates, with native Swift and Objective‑C implementations. No map SDK, API key, network requests or location permissions are required.

- Swift Package Manager support; Swift 6 value types and `Sendable`.
- All six conversion directions, including WGS‑84 ⇄ BD‑09LL.
- Explicit coordinate systems and region policies, input validation and bounded numerical inverses.
- Existing Objective‑C method signatures and two-file manual integration remain available.
- Tests cover independent reference values, round trips, boundaries, invalid input and language parity.

> This library implements community approximation formulas, not an official map-provider service. A small inverse residual means agreement with this library's forward formula, not centimeter-level real-world location accuracy. Confirm the source provider, SDK configuration and destination coordinate system before integrating with a map.

## Installation

| Implementation | Integration | Supported platforms |
| --- | --- | --- |
| Swift | Swift Package Manager product `TQLocationConverter` | Swift 6.0+; iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+, visionOS 1+; Linux core |
| Objective‑C | SwiftPM product `TQLocationConverterObjC`, local CocoaPods, manual copying | The Apple platforms above; no UIKit dependency |

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/TinyQ/TQLocationConverter.git
```

Select the `master` branch for the development version. To review an unmerged change, select its branch or add its checkout as a local package. No modern version tag has been published yet; prefer a semantic version dependency after the first release.

```swift
// In your Package.swift:
.package(url: "https://github.com/TinyQ/TQLocationConverter.git", branch: "master")
// In the consuming target's dependencies:
.product(name: "TQLocationConverter", package: "TQLocationConverter")
```

For a local checkout, use `.package(path: "../TQLocationConverter")`. See the [guide](Documentation/Guide.en-US.md#objective-c) for CocoaPods and manual Objective‑C integration.

## Swift quick start

```swift
import TQLocationConverter

let gps = Coordinate(latitude: 39.915, longitude: 116.404)
let gcj = try LocationConverter.convert(gps, from: .wgs84, to: .gcj02)
// latitude ≈ 39.9164042815, longitude ≈ 116.4102444992

let baidu = try LocationConverter.convert(gps, from: .wgs84, to: .bd09)
let restored = try LocationConverter.convert(baidu, from: .bd09, to: .wgs84)
```

On Apple platforms, bridge Core Location with `Coordinate(location.coordinate)` and `coordinate.clLocationCoordinate`. These bridges copy values without changing their coordinate system.

## Objective‑C quick start

```objc
#import "TQLocationConverter.h"

NSError *error = nil;
CLLocationCoordinate2D gps = CLLocationCoordinate2DMake(39.915, 116.404);
CLLocationCoordinate2D gcj = [TQLocationConverter
    convertCoordinate:gps
    from:TQCoordinateSystemWGS84
    to:TQCoordinateSystemGCJ02
    regionPolicy:TQRegionPolicyMainlandChina
    error:&error];
if (error) {
    NSLog(@"Conversion failed: %@", error.localizedDescription);
}
```

Legacy methods such as `transformFromWGSToGCJ:` remain available and preserve their **unrestricted** regional behavior. The new API makes the region policy explicit. See the [migration notes](Documentation/Guide.en-US.md#migration).

## Region policy and accuracy

Swift defaults to `.mainlandChina` (`TQRegionPolicyMainlandChina` in Objective‑C). It checks the **input coordinate once**, passing it through unchanged if it falls outside the project's approximate mainland polygon. This applies to every conversion direction. The heuristic includes Hainan and excludes Hong Kong, Macao and Taiwan from automatic conversion. It preserves the project's historical scope; it is not an authoritative boundary and does not describe every provider's rules in those areas.

Choose `.unrestricted` when conversion applicability is already known. An offset can move a point across a polygon edge, so automatic classification cannot guarantee round trips near boundaries; the caller must choose an explicit policy there. BD‑09 means geographic **BD‑09LL**. BD‑09MC, map projections and altitude transformations are not supported.

See the [algorithm research](Documentation/Algorithms.en-US.md) for comparisons, reproducible benchmarks and limitations.

## Documentation and development

- [Usage, errors, FAQ and migration](Documentation/Guide.en-US.md)
- [Algorithm research and benchmarks](Documentation/Algorithms.en-US.md)
- [Contributing](CONTRIBUTING.en-US.md) · [Changelog](CHANGELOG.md)
- Use Xcode **Product → Build Documentation** for DocC API documentation.

```sh
swift test
swift run -c release ConversionBenchmark
# Validate Objective-C APIs and manual integration on macOS:
bash Scripts/test-objc.sh
python3 Scripts/check-docs.py
```

Released under the [MIT License](LICENSE). Thanks to the early contributors and the coordinate conversion community.
