# Usage guide

[简体中文](Guide.zh-CN.md) · [Home](../README.en-US.md)

## Input and output

`Coordinate(latitude:longitude:)` uses decimal degrees and explicitly names latitude first. Many JavaScript libraries and GeoJSON use `[longitude, latitude]`; check the order when importing. A `Coordinate` does not store or infer its coordinate system. Preserve that metadata with your application data and update it after converting once.

| Case | Meaning |
| --- | --- |
| `.wgs84` | WGS‑84 geographic coordinates |
| `.gcj02` | GCJ‑02 geographic coordinates |
| `.bd09` | BD‑09LL geographic coordinates, not BD‑09MC meters |

`LocationConverter.convert` supports all six directions. Identical source and destination systems return the original pair after input validation.

## Batch conversion and Core Location

```swift
import TQLocationConverter

let points = [Coordinate(latitude: 39.915, longitude: 116.404)]
let converted = try points.map {
    try LocationConverter.convert($0, from: .wgs84, to: .gcj02)
}
```

`map` throws on the first failure. To preserve per-point errors, use `points.map { point in Result { try LocationConverter.convert(point, from: .wgs84, to: .gcj02) } }`. The library has no shared mutable state; its value types can cross concurrency boundaries.

```swift
import CoreLocation
import TQLocationConverter

let raw = CLLocationCoordinate2D(latitude: 39.915, longitude: 116.404)
let converted = try LocationConverter.convert(Coordinate(raw), from: .wgs84, to: .gcj02)
let mapCoordinate = converted.clLocationCoordinate
```

The library does not acquire device location. Any permission requirement comes from how your application obtains coordinates.

## Region policies

| Policy | Behavior |
| --- | --- |
| `.mainlandChina`, default | Check the input once against the historical approximate polygon; pass outside points through, including GCJ‑02 ⇄ BD‑09LL |
| `.unrestricted` | Apply the formulas without a region heuristic; validity and convergence checks still apply |

The polygon has 58 distinct vertices, includes Hainan and excludes Hong Kong, Macao and Taiwan from default conversion. It is approximate: coastlines, islands and border points can be misclassified. Points on polygon segments count as inside. Provider coverage rules can differ; this is not an authoritative geographic boundary or a substitute for SDK documentation.

```swift
let result = try LocationConverter.convert(
    Coordinate(latitude: 39.915, longitude: 116.404),
    from: .gcj02, to: .wgs84,
    regionPolicy: .unrestricted
)
```

Automatic classification is ambiguous near an edge: an offset can move a point outside the polygon, causing its inverse conversion to be skipped. Choose `.unrestricted` when you know the input has been offset. A more detailed polygon alone cannot resolve this discontinuity. Composed routes check only the original input, never the intermediate GCJ‑02 point.

## Errors

Swift throws `ConversionError`:

- `invalidCoordinate`: NaN, infinity, latitude outside ±90°, or longitude outside ±180°.
- `invalidResult`: invalid formula output, for example when forcing a transformation near a pole.
- `nonConvergent`: the per-axis forward residual did not reach `1e-9` degrees within 24 checks.

```swift
 do {
    let result = try LocationConverter.convert(
        Coordinate(latitude: 39.915, longitude: 116.404),
        from: .wgs84, to: .bd09
    )
    print(result.latitude, result.longitude)
} catch {
    print("Conversion failed: \(error)")
}
```

Constructing a `Coordinate` does not throw. Check `isValid` early if useful; conversion always validates. Range checks cannot detect every swapped pair or a mislabeled coordinate system.

## Objective-C

**SwiftPM:** select the separate product `TQLocationConverterObjC` and use `@import TQLocationConverterObjC;`. The Swift and Objective‑C products are independent; you do not need to link both.

**Manual:** copy [TQLocationConverter.h](../Sources/TQLocationConverterObjC/include/TQLocationConverter.h) and [TQLocationConverter.m](../Sources/TQLocationConverterObjC/TQLocationConverter.m) into your application target and link Foundation and CoreLocation. The two files can live together in your app; the SwiftPM umbrella header is not needed. UIKit is not needed; ARC is recommended.

**CocoaPods:** install the Objective-C implementation from its Git tag:

```ruby
pod 'TQLocationConverter',
    :git => 'https://github.com/TinyQ/TQLocationConverter.git',
    :tag => '1.0.1'
```

Run `pod install` and open the generated `.xcworkspace`. For local development, use `pod 'TQLocationConverter', :path => '../TQLocationConverter'`. This version is distributed through its Git tag and has not been published to CocoaPods trunk, so keep both `:git` and `:tag`. The native Swift implementation is distributed through SwiftPM.

```objc
NSError *error = nil;
CLLocationCoordinate2D result = [TQLocationConverter
    convertCoordinate:CLLocationCoordinate2DMake(39.915, 116.404)
    from:TQCoordinateSystemWGS84 to:TQCoordinateSystemBD09
    regionPolicy:TQRegionPolicyMainlandChina error:&error];
if (!CLLocationCoordinate2DIsValid(result)) {
    NSLog(@"%@", error);
}
```

Failure returns `kCLLocationCoordinate2DInvalid` and optionally sets `NSError`. Success clears a supplied error pointer. Invalid enum values report `TQConversionErrorInvalidOption`. Legacy methods have no error parameter and return the invalid sentinel on failure.

## Migration

- **1.0.1 directory change:** Objective-C sources move into `Sources/TQLocationConverterObjC/`, with public headers in its `include/` directory. Projects referencing repository files directly must update those paths. SwiftPM/CocoaPods product names, header names and call sites stay the same. The `1.0.0` tag retains the original root layout.

- The four existing conversion methods and `isLocationOutOfChina:` retain their signatures; direct WGS‑84 ⇄ Baidu methods are added.
- **Legacy conversions still do not check the region automatically.** Choose a policy explicitly when adopting the new API.
- GCJ‑02 → WGS‑84 uses residual iteration; BD‑09LL → GCJ‑02 is refined too. Results can differ slightly from old releases. Use an error tolerance instead of floating-point equality for round trips.
- Invalid input, invalid output and non-convergence no longer silently return guesses. Legacy methods return an invalid coordinate; the checked API also reports an error.
- The polygon coordinates are retained, with its duplicated closing vertex and mutable array removed. Points on an edge now explicitly count as inside.
- The modern package requires Swift 6 / iOS 13 and the platform versions listed on the home page. Projects targeting older systems need their existing pinned revision or an independently evaluated backport.

## FAQ

**Can it detect the coordinate system?** No. The same numeric pair can be valid in all three systems.

**Why is a location still offset?** Check axis order, source system, destination map, SDK automatic conversion and accidental repeated conversions. Then consider source location error and approximation error. For strict agreement with a particular map service, use and validate against that provider's official conversion API/SDK.

**Does the inverse tolerance guarantee geographic accuracy?** No. It measures inversion of this library's forward formulas. Independent open-source fixtures are not surveyed control points.

**What is supported?** Two-dimensional geographic coordinates only. No location acquisition, geocoding, map matching, Mercator projection or altitude conversion.

**Any network calls, telemetry or API keys?** No. Computation stays local and does not read or log user location.
