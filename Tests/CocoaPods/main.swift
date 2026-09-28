import CoreLocation
import Foundation
import TQLocationConverter

let gps = CLLocationCoordinate2D(latitude: 39.915, longitude: 116.404)
var error: NSError?
let converted = TQLocationConverter.convert(
  gps, from: .WGS84, to: .BD09, regionPolicy: .mainlandChina, error: &error)
precondition(error == nil && CLLocationCoordinate2DIsValid(converted))
let restored = TQLocationConverter.convert(
  converted, from: .BD09, to: .WGS84, regionPolicy: .mainlandChina, error: &error)
precondition(error == nil)
precondition(abs(restored.latitude - gps.latitude) < 1e-8)
precondition(abs(restored.longitude - gps.longitude) < 1e-8)

let invalid = TQLocationConverter.convert(
  CLLocationCoordinate2D(latitude: .nan, longitude: 0),
  from: .WGS84, to: .GCJ02, regionPolicy: .mainlandChina, error: &error)
precondition(!CLLocationCoordinate2DIsValid(invalid))
precondition(error?.domain == TQLocationConverterErrorDomain)
precondition(error?.code == TQConversionError.invalidCoordinate.rawValue)
print("CocoaPods Swift import, round trip and NSError bridging passed.")
