# Getting started

Convert a known coordinate and choose an explicit source and destination.

```swift
import TQLocationConverter

let gps = Coordinate(latitude: 39.915, longitude: 116.404)
let gcj = try LocationConverter.convert(gps, from: .wgs84, to: .gcj02)
```

The default `.mainlandChina` policy checks the input against an approximate polygon, passing
outside points through unchanged for every conversion direction. Choose `.unrestricted` when
your provider has already established applicability, especially near a polygon edge.

Invalid input throws ``ConversionError/invalidCoordinate``. Formula failures and numerical
non-convergence are also reported. Identity conversions validate the input too.

On Apple platforms, `Coordinate(location.coordinate)` and `coordinate.clLocationCoordinate`
bridge Core Location without changing coordinate systems. For batch input, use `map`; use
`Result` to retain individual errors.

See the repository's bilingual guides for Objective-C integration, migration and reproducible
algorithm comparisons. BD-09 means BD-09LL geographic coordinates, not BD-09MC meters.
