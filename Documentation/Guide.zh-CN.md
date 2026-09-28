# 使用指南

[English](Guide.en-US.md) · [返回首页](../README.md)

## 选择输入与输出

`Coordinate(latitude:longitude:)` 使用十进制度，并显式命名纬度、经度。很多 JavaScript 库及 GeoJSON 使用 `[经度, 纬度]`，请在导入时核对顺序。`Coordinate` 本身不记录坐标系，也不能根据数字自动判断坐标系。请随业务数据保存来源坐标系，转换一次后同步更新标记。

| 枚举 | 含义 |
| --- | --- |
| `.wgs84` | WGS‑84 经纬度 |
| `.gcj02` | GCJ‑02 经纬度 |
| `.bd09` | BD‑09LL 经纬度；不接受 BD‑09MC 米制坐标 |

三种类型之间的六个方向均可调用 `LocationConverter.convert`。源和目标相同则返回原值，但仍检查输入是否有效。

## 批量与 Core Location

```swift
import TQLocationConverter

let points = [Coordinate(latitude: 39.915, longitude: 116.404)]
let converted = try points.map {
    try LocationConverter.convert($0, from: .wgs84, to: .gcj02)
}
```

`map` 遇到第一个错误会抛出；要保留每一点的错误，可使用 `points.map { point in Result { try LocationConverter.convert(point, from: .wgs84, to: .gcj02) } }`。本库无可变共享状态，值类型可跨并发任务传递。

```swift
import CoreLocation
import TQLocationConverter

let raw = CLLocationCoordinate2D(latitude: 39.915, longitude: 116.404)
let converted = try LocationConverter.convert(Coordinate(raw), from: .wgs84, to: .gcj02)
let mapCoordinate = converted.clLocationCoordinate
```

库不会获取设备位置。是否申请定位权限由调用方获取位置的方式决定。

## 地域策略

| 策略 | 行为 |
| --- | --- |
| `.mainlandChina`，默认 | 在输入端检查一次旧项目的近似多边形，区域外原样返回；包含 GCJ‑02 ⇄ BD‑09LL |
| `.unrestricted` | 跳过地域启发式，直接执行公式；仍检查输入、输出与收敛 |

多边形只有 58 个不重复顶点，包含海南，默认排除港澳台。它并非精确边界；海岸、岛屿、边境附近可能误判。点恰好落在线段上按区域内处理。不同厂商的转换适用区域可能不同，不能用这个函数判断政治地理归属或代替 SDK 文档。

```swift
let result = try LocationConverter.convert(
    Coordinate(latitude: 39.915, longitude: 116.404),
    from: .gcj02, to: .wgs84,
    regionPolicy: .unrestricted
)
```

在边界附近使用自动策略会出现歧义：偏移后的点可能落在轮廓外，逆变换随后被跳过。若已知输入确实经过加偏，显式选择 `.unrestricted`；不要把更精细的多边形当作这个不连续问题的完整解决方案。多阶段转换只检查原始输入，不在中间的 GCJ‑02 阶段再次判断。

## 错误处理

Swift 抛出 `ConversionError`：

- `invalidCoordinate`：NaN、无穷大、纬度超出 ±90° 或经度超出 ±180°。
- `invalidResult`：公式计算出无效结果，例如强制转换极点附近坐标。
- `nonConvergent`：24 次检查内未达到每轴 `1e-9` 度的正向残差阈值。

```swift
 do {
    let result = try LocationConverter.convert(
        Coordinate(latitude: 39.915, longitude: 116.404),
        from: .wgs84, to: .bd09
    )
    print(result.latitude, result.longitude)
} catch {
    print("转换失败：\(error)")
}
```

构造 `Coordinate` 不会抛错，`isValid` 可提前检查；转换入口一定会校验。范围检查无法发现所有经纬度互换，也无法判断坐标系标注是否正确。

## Objective-C

**SwiftPM：**选择独立产品 `TQLocationConverterObjC`，使用 `@import TQLocationConverterObjC;`。原生 Swift 产品与 Objective‑C 产品相互独立，无需一起链接。

**手动集成：**将仓库根目录的 `TQLocationConverter.h` 和 `.m` 加入应用 target，并链接 Foundation、CoreLocation。无需 UIKit；建议启用 ARC。

**CocoaPods：**当前可用本地 checkout 验证：

```ruby
pod 'TQLocationConverter', :path => '../TQLocationConverter'
```

podspec 为未来 `1.0.0` 做了准备，源 tag 为 `1.0.0`；目前尚未创建该 tag 或发布到 trunk。不要在未发布时依赖 `pod 'TQLocationConverter', '~> 1.0'`。Swift 实现使用 SwiftPM 分发。

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

失败返回 `kCLLocationCoordinate2DInvalid`，并按需设置 `NSError`；成功会清空传入的错误指针。非法枚举值产生 `TQConversionErrorInvalidOption`。旧接口没有错误参数，失败同样返回无效坐标哨兵。

## 迁移旧版本

- 原有四个转换方法与 `isLocationOutOfChina:` 签名保留，并新增 WGS‑84 ⇄ 百度的组合方法。
- **旧转换方法仍不自动判断地域。** 换用新接口时需明确选取地域策略，不能假定默认行为相同。
- GCJ‑02 → WGS‑84 改为逐次残差修正；BD‑09LL → GCJ‑02 也会继续迭代。返回值可能与旧版本略有不同，不应使用浮点完全相等判断往返成功。
- 无效输入、无效输出或不收敛不再静默返回猜测值；旧接口返回无效坐标，新接口还提供错误信息。
- 多边形顶点数据保持原样，移除重复末顶点与可变数组；边界上的点明确按区域内处理。
- 现代包的最低要求为 Swift 6 / iOS 13 等，详见首页。依赖早期系统的项目需保留原来的固定提交或自行评估回移。

## FAQ

**能自动识别坐标系吗？** 不能。相同经纬度数字在三种坐标系中都可能有效。

**为什么显示位置仍有偏差？** 先核对经纬度顺序、源坐标系、目标地图、SDK 的自动转换配置与重复转换，再考虑原始定位误差和社区模型误差。对特定地图服务要求严格一致时，使用该厂商的转换 API/SDK 并按其文档验证。

**求逆阈值意味着真实精度吗？** 不意味着。它仅衡量对本库正向公式的数值还原。参考样本来自独立开源实现，并非实测控制点。

**支持哪些功能？** 本库只变换二维经纬度，不提供定位、地理编码、地图匹配、墨卡托投影或高程转换。

**有在线请求、埋点或密钥吗？** 没有。计算完全在本地完成，也不会读取或记录用户位置。
