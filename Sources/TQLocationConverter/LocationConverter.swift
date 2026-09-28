import Foundation

/// Offline conversion between WGS-84, GCJ-02 and BD-09LL, without network or location access.
public enum LocationConverter {
  // Preserve the original project's forward model; these are not WGS-84 ellipsoid constants.
  private static let axis = 6_378_245.0
  private static let eccentricitySquared = 0.00669342162296594323
  private static let xPi = Double.pi * 3000 / 180
  static let inverseTolerance = 1e-9
  static let inverseIterationLimit = 24

  /// Converts a coordinate, checking validity and numerical convergence.
  ///
  /// The default region policy passes points outside the approximate mainland polygon through
  /// unchanged. Supply `.unrestricted` when applicability is already known. Automatic classification
  /// near a polygon edge is ambiguous because the offset can move a point across that edge.
  ///
  /// - Throws: ``ConversionError`` for invalid input, invalid output or inverse non-convergence.
  /// - Important: A small numerical residual is not a guarantee of real-world map accuracy.
  public static func convert(
    _ coordinate: Coordinate,
    from source: CoordinateSystem,
    to destination: CoordinateSystem,
    regionPolicy: RegionPolicy = .mainlandChina
  ) throws -> Coordinate {
    guard coordinate.isValid else { throw ConversionError.invalidCoordinate }
    guard source != destination else { return coordinate }
    if regionPolicy == .mainlandChina && !isInMainlandChina(coordinate) { return coordinate }

    let gcj: Coordinate
    switch source {
    case .wgs84: gcj = try checked(wgsToGCJ(coordinate))
    case .gcj02: gcj = coordinate
    case .bd09:
      gcj = try inverse(coordinate, initial: approximateBDToGCJ(coordinate), forward: gcjToBD)
    }
    switch destination {
    case .wgs84: return try inverse(gcj, initial: gcj, forward: wgsToGCJ)
    case .gcj02: return gcj
    case .bd09: return try checked(gcjToBD(gcj))
    }
  }

  /// Tests the legacy approximate mainland polygon. Invalid coordinates return `false`.
  /// Hainan is included; Hong Kong, Macao and Taiwan are outside the heuristic.
  /// Do not use this as a definitive geographic or provider coverage boundary.
  public static func isInMainlandChina(_ coordinate: Coordinate) -> Bool {
    coordinate.isValid && ChinaRegion.contains(coordinate)
  }

  private static func checked(_ coordinate: Coordinate) throws -> Coordinate {
    guard coordinate.isValid else { throw ConversionError.invalidResult }
    return coordinate
  }

  // Solve f(x) = target by subtracting the forward residual. The offset varies slowly in the
  // intended region. Bound iteration and verify the residual rather than silently returning a guess.
  static func inverse(
    _ target: Coordinate,
    initial: Coordinate,
    forward: (Coordinate) -> Coordinate
  ) throws -> Coordinate {
    var estimate = try checked(initial)
    for _ in 0..<inverseIterationLimit {
      let projected = try checked(forward(estimate))
      let latitudeError = projected.latitude - target.latitude
      let longitudeError = projected.longitude - target.longitude
      if max(abs(latitudeError), abs(longitudeError)) <= inverseTolerance { return estimate }
      estimate = try checked(
        Coordinate(
          latitude: estimate.latitude - latitudeError,
          longitude: estimate.longitude - longitudeError
        ))
    }
    throw ConversionError.nonConvergent
  }

  private static func wgsToGCJ(_ p: Coordinate) -> Coordinate {
    let x = p.longitude - 105
    let y = p.latitude - 35
    var latitudeOffset = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
    latitudeOffset += (20 * sin(6 * x * .pi) + 20 * sin(2 * x * .pi)) * 2 / 3
    latitudeOffset += (20 * sin(y * .pi) + 40 * sin(y / 3 * .pi)) * 2 / 3
    latitudeOffset += (160 * sin(y / 12 * .pi) + 320 * sin(y * .pi / 30)) * 2 / 3
    var longitudeOffset = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
    longitudeOffset += (20 * sin(6 * x * .pi) + 20 * sin(2 * x * .pi)) * 2 / 3
    longitudeOffset += (20 * sin(x * .pi) + 40 * sin(x / 3 * .pi)) * 2 / 3
    longitudeOffset += (150 * sin(x / 12 * .pi) + 300 * sin(x / 30 * .pi)) * 2 / 3
    let radians = p.latitude / 180 * .pi
    let sine = sin(radians)
    let magic = 1 - eccentricitySquared * sine * sine
    let root = sqrt(magic)
    latitudeOffset =
      latitudeOffset * 180 / ((axis * (1 - eccentricitySquared)) / (magic * root) * .pi)
    longitudeOffset = longitudeOffset * 180 / (axis / root * cos(radians) * .pi)
    return Coordinate(
      latitude: p.latitude + latitudeOffset, longitude: p.longitude + longitudeOffset)
  }

  private static func gcjToBD(_ p: Coordinate) -> Coordinate {
    let z =
      sqrt(p.longitude * p.longitude + p.latitude * p.latitude) + 0.00002 * sin(p.latitude * xPi)
    let theta = atan2(p.latitude, p.longitude) + 0.000003 * cos(p.longitude * xPi)
    return Coordinate(latitude: z * sin(theta) + 0.006, longitude: z * cos(theta) + 0.0065)
  }

  private static func approximateBDToGCJ(_ p: Coordinate) -> Coordinate {
    let x = p.longitude - 0.0065
    let y = p.latitude - 0.006
    let z = sqrt(x * x + y * y) - 0.00002 * sin(y * xPi)
    let theta = atan2(y, x) - 0.000003 * cos(x * xPi)
    return Coordinate(latitude: z * sin(theta), longitude: z * cos(theta))
  }
}
