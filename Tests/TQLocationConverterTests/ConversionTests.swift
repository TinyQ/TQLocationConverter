import Foundation
import Testing

@testable import TQLocationConverter

struct Fixture: Decodable, Sendable {
  let name: String
  let latitude: Double
  let longitude: Double
  let wgsToGCJ: [Double]  // upstream uses [longitude, latitude]
  let gcjToBD: [Double]
  var coordinate: Coordinate { Coordinate(latitude: latitude, longitude: longitude) }
}

func fixtures() throws -> [Fixture] {
  let url = try #require(
    Bundle.module.url(forResource: "forward", withExtension: "json", subdirectory: "Fixtures"))
  return try JSONDecoder().decode([Fixture].self, from: Data(contentsOf: url))
}

func expectClose(_ actual: Coordinate, _ expected: Coordinate, tolerance: Double = 1e-8) {
  #expect(abs(actual.latitude - expected.latitude) <= tolerance)
  #expect(abs(actual.longitude - expected.longitude) <= tolerance)
}

// Publicly reproducible deterministic coverage, not surveyed coordinates or provider accuracy claims.
func mainlandGrid() -> [Coordinate] {
  var points: [Coordinate] = []
  for lat in stride(from: 18.25, through: 53.25, by: 0.5) {
    for lon in stride(from: 73.25, through: 135.25, by: 0.5) {
      let point = Coordinate(latitude: lat, longitude: lon)
      if LocationConverter.isInMainlandChina(point) { points.append(point) }
    }
  }
  return points
}

@Test func matchesIndependentForwardFixtures() throws {
  for fixture in try fixtures() {
    #expect(LocationConverter.isInMainlandChina(fixture.coordinate), "\(fixture.name)")
    let gcj = try LocationConverter.convert(fixture.coordinate, from: .wgs84, to: .gcj02)
    expectClose(
      gcj, Coordinate(latitude: fixture.wgsToGCJ[1], longitude: fixture.wgsToGCJ[0]),
      tolerance: 1e-11)
    let bd = try LocationConverter.convert(fixture.coordinate, from: .gcj02, to: .bd09)
    expectClose(
      bd, Coordinate(latitude: fixture.gcjToBD[1], longitude: fixture.gcjToBD[0]), tolerance: 1e-11)
    // Refined inverses recover the upstream input, without matching its one-step inverse approximation.
    expectClose(try LocationConverter.convert(gcj, from: .gcj02, to: .wgs84), fixture.coordinate)
    expectClose(try LocationConverter.convert(bd, from: .bd09, to: .gcj02), fixture.coordinate)
  }
}

@Test func allPairsRoundTripAcrossMainlandGrid() throws {
  let points = mainlandGrid()
  #expect(points.count > 3000)
  for point in points {
    for source in CoordinateSystem.allCases {
      for destination in CoordinateSystem.allCases where source != destination {
        let result = try LocationConverter.convert(
          point, from: source, to: destination, regionPolicy: .unrestricted)
        let back = try LocationConverter.convert(
          result, from: destination, to: source, regionPolicy: .unrestricted)
        expectClose(back, point)
      }
    }
  }
}

@Test func inverseHandlesLongitude105Cusp() throws {
  for latitude in [20.0, 30, 40, 50] {
    for delta in [-1e-5, -1e-8, -1e-11, 0, 1e-11, 1e-8, 1e-5] {
      let point = Coordinate(latitude: latitude, longitude: 105 + delta)
      let gcj = try LocationConverter.convert(
        point, from: .wgs84, to: .gcj02, regionPolicy: .unrestricted)
      expectClose(
        try LocationConverter.convert(gcj, from: .gcj02, to: .wgs84, regionPolicy: .unrestricted),
        point)
    }
  }
}

@Test func allPairsIdentityAndOutsidePassThrough() throws {
  for point in [
    Coordinate(latitude: 51.5074, longitude: -0.1278),
    Coordinate(latitude: 22.3193, longitude: 114.1694),
    Coordinate(latitude: 22.1987, longitude: 113.5439),
    Coordinate(latitude: 25.033, longitude: 121.5654),
    Coordinate(latitude: 0, longitude: 0),
    Coordinate(latitude: 90, longitude: 180),
  ] {
    #expect(!LocationConverter.isInMainlandChina(point))
    for source in CoordinateSystem.allCases {
      for destination in CoordinateSystem.allCases {
        #expect(try LocationConverter.convert(point, from: source, to: destination) == point)
      }
    }
  }
  let point = Coordinate(latitude: 39.915, longitude: 116.404)
  for system in CoordinateSystem.allCases {
    #expect(try LocationConverter.convert(point, from: system, to: system) == point)
  }
}

@Test func composedRoutesMatchIndividualStages() throws {
  for fixture in try fixtures() {
    let gcj = try LocationConverter.convert(fixture.coordinate, from: .wgs84, to: .gcj02)
    let bd = try LocationConverter.convert(gcj, from: .gcj02, to: .bd09)
    #expect(try LocationConverter.convert(fixture.coordinate, from: .wgs84, to: .bd09) == bd)
    expectClose(try LocationConverter.convert(bd, from: .bd09, to: .wgs84), fixture.coordinate)
  }
}

@Test func invalidInputIsRejectedEvenForIdentity() {
  for point in [
    Coordinate(latitude: .nan, longitude: 0), Coordinate(latitude: .infinity, longitude: 0),
    Coordinate(latitude: 0, longitude: -.infinity), Coordinate(latitude: 91, longitude: 0),
    Coordinate(latitude: -91, longitude: 0), Coordinate(latitude: 0, longitude: 181),
    Coordinate(latitude: 0, longitude: -181),
  ] {
    #expect(!point.isValid)
    #expect(!LocationConverter.isInMainlandChina(point))
    for source in CoordinateSystem.allCases {
      for destination in CoordinateSystem.allCases {
        #expect(throws: ConversionError.invalidCoordinate) {
          try LocationConverter.convert(point, from: source, to: destination)
        }
      }
    }
  }
}

@Test func invalidOutputAndNonConvergenceAreReported() {
  #expect(throws: ConversionError.invalidResult) {
    try LocationConverter.convert(
      Coordinate(latitude: 90, longitude: 100), from: .wgs84, to: .gcj02,
      regionPolicy: .unrestricted)
  }
  // An intentionally non-invertible forward function exercises the finite iteration limit.
  #expect(throws: ConversionError.nonConvergent) {
    try LocationConverter.inverse(
      Coordinate(latitude: 1, longitude: 1), initial: Coordinate(latitude: 1, longitude: 1)
    ) { _ in
      Coordinate(latitude: 0, longitude: 0)
    }
  }
}

@Test func polygonIncludesVerticesAndMidpoints() throws {
  for (index, vertex) in ChinaRegion.vertices.enumerated() {
    #expect(LocationConverter.isInMainlandChina(vertex))
    let next = ChinaRegion.vertices[(index + 1) % ChinaRegion.vertices.count]
    let midpoint = Coordinate(
      latitude: (vertex.latitude + next.latitude) / 2,
      longitude: (vertex.longitude + next.longitude) / 2)
    #expect(LocationConverter.isInMainlandChina(midpoint))
    // Explicit applicability avoids automatic region ambiguity after an offset crosses an edge.
    let gcj = try LocationConverter.convert(
      midpoint, from: .wgs84, to: .gcj02, regionPolicy: .unrestricted)
    expectClose(
      try LocationConverter.convert(gcj, from: .gcj02, to: .wgs84, regionPolicy: .unrestricted),
      midpoint)
  }
}

@Test func legacyRegionRegressionPoints() {
  let rows: [(Double, Double, Bool)] = [
    (43.939193, 105.113281, false), (23.942372, 121.082134, false),
    (21.277982, 105.407565, false), (40.648513, -109.916021, false),
    (-23.452189, 124.835182, false), (52.369686, -0.855150, false),
    (40.6424438827, 114.3790442482, true), (32.7132247538, 119.3814515758, true),
    (19.3281880801, 109.9619378181, true), (38.5939174139, 76.1092626238, true),
  ]
  for (latitude, longitude, expected) in rows {
    #expect(
      LocationConverter.isInMainlandChina(Coordinate(latitude: latitude, longitude: longitude))
        == expected)
  }
}

@Test func parallelCallsHaveNoSharedMutableState() async throws {
  let point = Coordinate(latitude: 39.915, longitude: 116.404)
  let expected = try LocationConverter.convert(point, from: .wgs84, to: .bd09)
  try await withThrowingTaskGroup(of: Coordinate.self) { group in
    for _ in 0..<100 {
      group.addTask { try LocationConverter.convert(point, from: .wgs84, to: .bd09) }
    }
    for try await result in group { #expect(result == expected) }
  }
}

@Test func legacyQuadrantSearchRegression() throws {
  // Original 2b47208 returns latitude 35.251493380238543 (~166 m away).
  let gcj = Coordinate(latitude: 35.249540255704204, longitude: 114.255859407090739)
  let result = try LocationConverter.convert(gcj, from: .gcj02, to: .wgs84)
  expectClose(result, Coordinate(latitude: 35.25, longitude: 114.25))
}

@Test func seededSamplesCoverDifferentTrigonometricPhases() throws {
  var state: UInt32 = 0x5451_434F
  func unit() -> Double {
    state = 1_664_525 &* state &+ 1_013_904_223
    return Double(state) / 4_294_967_296
  }
  for _ in 0..<10_000 {
    let point = Coordinate(latitude: 18 + 36 * unit(), longitude: 73 + 63 * unit())
    guard LocationConverter.isInMainlandChina(point) else { continue }
    let bd = try LocationConverter.convert(
      point, from: .wgs84, to: .bd09, regionPolicy: .unrestricted)
    expectClose(
      try LocationConverter.convert(bd, from: .bd09, to: .wgs84, regionPolicy: .unrestricted), point
    )
  }
}

@Test func legacyQuadrantSearchSeededRegression() throws {
  let gcj = Coordinate(latitude: 36.886001243157956, longitude: 101.8358991708382)
  let result = try LocationConverter.convert(gcj, from: .gcj02, to: .wgs84)
  expectClose(result, Coordinate(latitude: 36.88599809445441, longitude: 101.83408280438744))
}
