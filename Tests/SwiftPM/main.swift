import Foundation
import TQLocationConverter
import TQLocationConverterObjC

let gps = Coordinate(latitude: 39.915, longitude: 116.404)
let gcj = try LocationConverter.convert(gps, from: .wgs84, to: .gcj02)
let baidu = try LocationConverter.convert(gps, from: .wgs84, to: .bd09)
let restored = try LocationConverter.convert(baidu, from: .bd09, to: .wgs84)
precondition(abs(restored.latitude - gps.latitude) < 1e-8)
precondition(abs(restored.longitude - gps.longitude) < 1e-8)
var error: NSError?
let objc = TQLocationConverter.convert(
  gps.clLocationCoordinate, from: .WGS84, to: .GCJ02,
  regionPolicy: .mainlandChina, error: &error)
precondition(error == nil)
precondition(abs(objc.latitude - gcj.latitude) < 1e-11)
precondition(abs(objc.longitude - gcj.longitude) < 1e-11)
print("Independent SwiftPM consumer passed: both products imported, converted and agreed.")
