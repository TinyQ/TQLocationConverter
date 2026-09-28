# 快速开始

明确输入与输出坐标系，再调用转换接口。

```swift
import TQLocationConverter

let gps = Coordinate(latitude: 39.915, longitude: 116.404)
let gcj = try LocationConverter.convert(gps, from: .wgs84, to: .gcj02)
```

默认 `.mainlandChina` 对输入进行一次近似多边形判断，区域外原样返回，对所有转换方向生效。
若已通过数据提供方确认需要转换，尤其在边界附近，请使用 `.unrestricted`。

无效输入抛出 ``ConversionError/invalidCoordinate``；公式产生无效结果或逆变换不收敛也会报告错误。
即使源和目标坐标系相同，也会检查输入。

Apple 平台可使用 `Coordinate(location.coordinate)` 和 `coordinate.clLocationCoordinate`
桥接 Core Location；桥接不会改变坐标系。批量转换可用 `map`，需要保留逐点错误时使用 `Result`。

仓库双语指南还包含 Objective-C 接入、迁移与可复现算法比较。BD-09 仅指经纬度 BD-09LL，
不接受 BD-09MC 米制坐标。求逆残差不代表真实地图精度。
