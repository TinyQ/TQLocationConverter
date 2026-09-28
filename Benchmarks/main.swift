import Foundation
import TQLocationConverter

func forward(_ p: Coordinate) throws -> Coordinate {
  try LocationConverter.convert(p, from: .wgs84, to: .gcj02, regionPolicy: .unrestricted)
}
func contains(_ p: Coordinate, _ a: Coordinate, _ b: Coordinate) -> Bool {
  (min(a.latitude, b.latitude)...max(a.latitude, b.latitude)).contains(p.latitude)
    && (min(a.longitude, b.longitude)...max(a.longitude, b.longitude)).contains(p.longitude)
}
// Port of this project's original quadrant search at 2b47208; same bounds and stop conditions.
func legacyInverse(_ p: Coordinate) throws -> Coordinate {
  var minLat = p.latitude - 0.5
  var maxLat = p.latitude + 0.5
  var minLon = p.longitude - 0.5
  var maxLon = p.longitude + 0.5
  for iteration in 0...30 {
    let leftBottom = try forward(Coordinate(latitude: minLat, longitude: minLon))
    let rightBottom = try forward(Coordinate(latitude: minLat, longitude: maxLon))
    let leftUp = try forward(Coordinate(latitude: maxLat, longitude: minLon))
    let mid = Coordinate(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
    let projected = try forward(mid)
    if iteration == 30
      || abs(projected.latitude - p.latitude) + abs(projected.longitude - p.longitude) <= 1e-5
    {
      return mid
    }
    if contains(p, leftBottom, projected) {
      maxLat = mid.latitude
      maxLon = mid.longitude
    } else if contains(p, rightBottom, projected) {
      maxLat = mid.latitude
      minLon = mid.longitude
    } else if contains(p, leftUp, projected) {
      minLat = mid.latitude
      maxLon = mid.longitude
    } else {
      minLat = mid.latitude
      minLon = mid.longitude
    }
  }
  fatalError("Unreachable: loop returns on its final iteration")
}
func oneStepInverse(_ p: Coordinate) throws -> Coordinate {
  let projected = try forward(p)
  return Coordinate(
    latitude: 2 * p.latitude - projected.latitude, longitude: 2 * p.longitude - projected.longitude)
}
func meters(_ a: Coordinate, _ b: Coordinate) -> Double {
  let lat1 = a.latitude * .pi / 180
  let lat2 = b.latitude * .pi / 180
  let dLat = lat2 - lat1
  let dLon = (b.longitude - a.longitude) * .pi / 180
  let h = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2)
  return 6_371_008.8 * 2 * asin(sqrt(min(1, max(0, h))))
}
var originals: [Coordinate] = []
for lat in stride(from: 18.25, through: 53.25, by: 0.5) {
  for lon in stride(from: 73.25, through: 135.25, by: 0.5) {
    let p = Coordinate(latitude: lat, longitude: lon)
    if LocationConverter.isInMainlandChina(p) { originals.append(p) }
  }
}
// Add seeded non-grid points so periodic terms are not sampled at only one phase.
var state: UInt32 = 0x5451_434F
@MainActor func unit() -> Double {
  state = 1_664_525 &* state &+ 1_013_904_223
  return Double(state) / 4_294_967_296
}
for _ in 0..<10_000 {
  let point = Coordinate(latitude: 18 + 36 * unit(), longitude: 73 + 63 * unit())
  if LocationConverter.isInMainlandChina(point) { originals.append(point) }
}
let inputs = try originals.map(forward)
let methods: [(String, (Coordinate) throws -> Coordinate)] = [
  ("one-step approximation", oneStepInverse),
  ("legacy quadrant search", legacyInverse),
  (
    "residual iteration",
    { try LocationConverter.convert($0, from: .gcj02, to: .wgs84, regionPolicy: .unrestricted) }
  ),
]
print(
  "Deterministic mainland grid + seeded samples: \(inputs.count) coordinates. Units: meters and milliseconds."
)
print("Errors measure inversion of this library's forward model, not surveyed/provider accuracy.")
print("method,max_round_trip_m,max_forward_residual_m,median_ms_5_runs,checksum")
for (name, method) in methods {
  let results = try inputs.map(method)  // warm-up and accuracy check
  var maximum = 0.0
  var residual = 0.0
  var worst = 0
  var aboveOneMeter = 0
  for (i, result) in results.enumerated() {
    let error = meters(originals[i], result)
    if error > maximum {
      maximum = error
      worst = i
    }
    if error > 1 { aboveOneMeter += 1 }
    residual = max(residual, try meters(inputs[i], forward(result)))
  }
  var times: [Double] = []
  var checksum = 0.0
  for _ in 0..<5 {
    let start = DispatchTime.now().uptimeNanoseconds
    for input in inputs { checksum += try method(input).latitude }
    times.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1e6)
  }
  print(
    String(format: "%@,%.9f,%.9f,%.3f,%.6f", name, maximum, residual, times.sorted()[2], checksum))
  print(
    "  worst input WGS84: \(originals[worst]); GCJ02: \(inputs[worst]); recovered: \(results[worst]); >1m count: \(aboveOneMeter)"
  )
}
