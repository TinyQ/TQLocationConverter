# TQLocationConverter

[English](README.en-US.md) · **简体中文**

离线转换 **WGS‑84、GCJ‑02 和 BD‑09LL** 经纬度的轻量库，提供原生 Swift 和 Objective‑C 实现。无需地图 SDK、API Key、网络请求或定位权限。

- Swift Package Manager 接入；Swift 6、值类型与 `Sendable`。
- 三种坐标系之间的全部六个转换方向，包含 WGS‑84 ⇄ BD‑09LL。
- 显式坐标系、地域策略、输入校验和有迭代上限的高精度数值求逆。
- 保留原来的 Objective‑C 方法签名与手动两文件集成方式。
- 自动测试覆盖独立参考值、批量往返、边界、无效输入和两种语言的一致性。

> 本库使用社区流传的近似公式，不是地图厂商的官方转换服务。求逆残差小，表示能够还原本库的正向公式，不代表厘米级实际定位精度。接入地图前请确认数据提供方、SDK 配置和目标服务要求的坐标系。

## 安装

| 实现 | 接入方式 | 支持范围 |
| --- | --- | --- |
| Swift | Swift Package Manager，产品 `TQLocationConverter` | Swift 6.0+；iOS 13+、macOS 10.15+、tvOS 13+、watchOS 6+、visionOS 1+；Linux 核心 |
| Objective‑C | SwiftPM 产品 `TQLocationConverterObjC`、CocoaPods Git 标签、手动复制 | 上述 Apple 平台；不依赖 UIKit |

Xcode：**File → Add Package Dependencies**，输入：

```text
https://github.com/TinyQ/TQLocationConverter.git
```

选择 **Up to Next Major Version**，最低版本填 `1.0.1`。在 `Package.swift` 中使用语义版本依赖：

```swift
// 你的 Package.swift
.package(url: "https://github.com/TinyQ/TQLocationConverter.git", from: "1.0.1")
// 消费 target 的 dependencies 中添加：
.product(name: "TQLocationConverter", package: "TQLocationConverter")
```

本地依赖可使用 `.package(path: "../TQLocationConverter")`。Objective‑C 的 CocoaPods 和手动接入方法见[使用指南](Documentation/Guide.zh-CN.md#objective-c)。

## Swift 快速开始

```swift
import TQLocationConverter

let gps = Coordinate(latitude: 39.915, longitude: 116.404)
let gcj = try LocationConverter.convert(gps, from: .wgs84, to: .gcj02)
// latitude ≈ 39.9164042815, longitude ≈ 116.4102444992

let baidu = try LocationConverter.convert(gps, from: .wgs84, to: .bd09)
let restored = try LocationConverter.convert(baidu, from: .bd09, to: .wgs84)
```

Apple 平台可通过 `Coordinate(location.coordinate)` 与 `coordinate.clLocationCoordinate` 对接 Core Location。这两个桥接操作仅复制数值，不转换坐标系。

## Objective‑C 快速开始

```objc
#import "TQLocationConverter.h"

NSError *error = nil;
CLLocationCoordinate2D gps = CLLocationCoordinate2DMake(39.915, 116.404);
CLLocationCoordinate2D gcj = [TQLocationConverter
    convertCoordinate:gps
    from:TQCoordinateSystemWGS84
    to:TQCoordinateSystemGCJ02
    regionPolicy:TQRegionPolicyMainlandChina
    error:&error];
if (error) {
    NSLog(@"Conversion failed: %@", error.localizedDescription);
}
```

旧的 `transformFromWGSToGCJ:` 等方法继续可用。它们保持原来的**不自动判断地域**行为；新接口显式提供地域策略。详细行为变更见[迁移说明](Documentation/Guide.zh-CN.md#迁移旧版本)。

## 地域与精度

Swift 默认 `.mainlandChina`（Objective‑C 为 `TQRegionPolicyMainlandChina`）：先对**输入坐标检查一次**，位于项目粗略大陆多边形之外则原样返回；对所有转换方向生效。该轮廓包含海南，并将香港、澳门、台湾排除在默认转换范围之外。这是延续旧版本的适用范围启发式，不是精确行政边界，也不表示所有地图厂商在这些区域都采用相同规则。

已确认需要转换时可显式使用 `.unrestricted`。多边形边缘附近的坐标可能因偏移跨越边界，自动地域判断无法保证往返一致；此时应由调用方明确策略。BD‑09 指经纬度 **BD‑09LL**，不支持米制 BD‑09MC、投影转换或高度转换。

算法比较、基准结果和限制见[算法调研](Documentation/Algorithms.zh-CN.md)。

## 文档与开发

- [使用、错误处理、FAQ 与迁移指南](Documentation/Guide.zh-CN.md)
- [算法调研与可复现基准](Documentation/Algorithms.zh-CN.md)
- [贡献指南](CONTRIBUTING.md) · [变更记录](CHANGELOG.md)
- Xcode **Product → Build Documentation** 可生成 DocC API 文档。

```sh
swift test
swift run -c release ConversionBenchmark
# macOS 上验证 Objective-C 接口和手动集成
bash Scripts/test-objc.sh
python3 Scripts/check-docs.py
```

MIT 许可证，详见 [LICENSE](LICENSE)。感谢早期贡献者以及坐标转换社区。
