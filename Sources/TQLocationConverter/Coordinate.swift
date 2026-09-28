import Foundation

/// A latitude/longitude pair in decimal degrees. The coordinate system is supplied at conversion time.
public struct Coordinate: Hashable, Sendable {
  /// Latitude in degrees, in the range -90...90.
  public let latitude: Double
  /// Longitude in degrees, in the range -180...180.
  public let longitude: Double

  /// Creates a coordinate. Conversion validates the values and throws for invalid input.
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }

  /// Whether both components are finite and within geographic coordinate ranges.
  public var isValid: Bool {
    latitude.isFinite && longitude.isFinite
      && (-90...90).contains(latitude) && (-180...180).contains(longitude)
  }
}

/// Supported geographic coordinate systems. BD-09 means BD-09LL, not BD-09MC.
public enum CoordinateSystem: String, CaseIterable, Sendable {
  case wgs84
  case gcj02
  case bd09
}

/// Controls where conversion is applied. This is an application heuristic, not a legal boundary.
public enum RegionPolicy: Equatable, Sendable {
  /// Convert input points inside the project's approximate mainland polygon; pass others through.
  /// The check happens once, before any conversion stages, including GCJ-02 ↔ BD-09.
  case mainlandChina
  /// Always apply the formulas. Use when the source provider has already established applicability.
  /// Near polygon boundaries this avoids ambiguous automatic region classification.
  case unrestricted
}

/// Failures reported by the checked conversion API.
public enum ConversionError: Error, Equatable, Sendable {
  /// Input contains NaN, infinity, or an out-of-range component.
  case invalidCoordinate
  /// The formula produced a nonfinite or out-of-range coordinate (for example, near a pole).
  case invalidResult
  /// The numerical inverse did not meet its residual tolerance within the iteration limit.
  case nonConvergent
}

#if canImport(CoreLocation)
  import CoreLocation

  extension Coordinate {
    /// Copies a Core Location coordinate without changing its coordinate system.
    public init(_ coordinate: CLLocationCoordinate2D) {
      self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    /// Exports the pair to Core Location without changing its coordinate system.
    public var clLocationCoordinate: CLLocationCoordinate2D {
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  }
#endif
