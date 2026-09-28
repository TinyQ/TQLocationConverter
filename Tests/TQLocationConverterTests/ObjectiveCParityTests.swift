#if canImport(TQLocationConverterObjC)
  import CoreLocation
  import Foundation
  import Testing
  @testable import TQLocationConverter
  import TQLocationConverterObjC

  @Test func objectiveCAndSwiftAgree() throws {
    let systems: [(CoordinateSystem, TQCoordinateSystem)] = [
      (.wgs84, .WGS84), (.gcj02, .GCJ02), (.bd09, .BD09),
    ]
    let points =
      mainlandGrid() + ChinaRegion.vertices + [Coordinate(latitude: 51.5074, longitude: -0.1278)]
    for point in points {
      #expect(
        TQLocationConverter.isLocationOut(ofChina: point.clLocationCoordinate)
          == !LocationConverter.isInMainlandChina(point))
      for (source, objcSource) in systems {
        for (destination, objcDestination) in systems {
          for (policy, objcPolicy): (RegionPolicy, TQRegionPolicy) in [
            (.mainlandChina, .mainlandChina), (.unrestricted, .unrestricted),
          ] {
            let expected = try LocationConverter.convert(
              point, from: source, to: destination, regionPolicy: policy)
            var error: NSError?
            let result = TQLocationConverter.convert(
              point.clLocationCoordinate, from: objcSource, to: objcDestination,
              regionPolicy: objcPolicy, error: &error)
            #expect(error == nil)
            expectClose(Coordinate(result), expected, tolerance: 1e-11)
          }
        }
      }
    }
  }

  @Test func coreLocationBridgeDoesNotChangeCoordinates() {
    let raw = CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
    let point = Coordinate(raw)
    #expect(point.clLocationCoordinate.latitude == raw.latitude)
    #expect(point.clLocationCoordinate.longitude == raw.longitude)
  }
#endif
