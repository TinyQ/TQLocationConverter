# TQLocationConverter 1.0.0

## 简体中文

为早期 Objective-C 项目补充原生 Swift 实现、现代分发方式、数值算法修复与双语文档。

- **原生 Swift 6：**值类型、`Sendable`、显式坐标系与地域策略；提供独立的 SwiftPM 产品 `TQLocationConverter` 和 `TQLocationConverterObjC`。
- **全部六个方向：**WGS-84、GCJ-02、BD-09LL 相互转换，包含直接的 WGS-84 ⇄ BD-09LL。
- **修复逆变换：**替换旧 GCJ-02 逆变换中可能选错搜索象限的实现；GCJ-02 和 BD-09LL 求逆使用有次数上限的残差迭代，并显式报告无效输入、无效结果和不收敛。
- **完善接入与维护：**中英文使用、迁移、FAQ 与算法调研，DocC、测试、CI、可复现基准和发布验证；清理历史 `.DS_Store` 并通过 CI 防止缓存误提交。

### 安装

```swift
.package(url: "https://github.com/TinyQ/TQLocationConverter.git", from: "1.0.0")
```

Objective-C CocoaPods 使用 Git 标签安装；此版本尚未发布到 CocoaPods trunk：

```ruby
pod 'TQLocationConverter',
    :git => 'https://github.com/TinyQ/TQLocationConverter.git',
    :tag => '1.0.0'
```

### 兼容性与精度

最低要求：Swift 6.0、iOS 13、macOS 10.15、tvOS 13、watchOS 6、visionOS 1；Swift 核心支持 Linux。原有 Objective-C 方法签名保留，继续采用不自动判断地域的行为。逆变换数值结果可能改变；旧接口遇到无效输入或失败时返回无效坐标。新接口应明确选择地域策略。

算法采用社区近似公式。数值往返一致性不代表实际地图定位精度；多边形边界附近应由调用方明确转换适用性。

[中文使用与迁移指南](https://github.com/TinyQ/TQLocationConverter/blob/1.0.0/Documentation/Guide.zh-CN.md) · [算法调研](https://github.com/TinyQ/TQLocationConverter/blob/1.0.0/Documentation/Algorithms.zh-CN.md)

## English

This release adds native Swift, modern distribution, numerical fixes and bilingual documentation to the original Objective-C project.

- **Native Swift 6:** value types, `Sendable`, explicit coordinate systems and region policies, with separate `TQLocationConverter` and `TQLocationConverterObjC` SwiftPM products.
- **All six directions:** WGS-84, GCJ-02 and BD-09LL conversions, including direct WGS-84 ⇄ BD-09LL routes.
- **Inverse fixes:** replace the old GCJ-02 inverse that could select an incorrect search quadrant. GCJ-02 and BD-09LL inverses now use bounded residual iteration, reporting invalid input, invalid output and non-convergence.
- **Integration and maintenance:** bilingual usage, migration, FAQ and algorithm research; DocC, tests, CI, reproducible benchmarks and release validation. Historical `.DS_Store` is removed and tracked caches are rejected by CI.

### Installation

Use the SwiftPM version dependency or CocoaPods Git-tag snippet above. The CocoaPod has not been published to trunk; retain `:git` and `:tag`.

### Compatibility and accuracy

Requires Swift 6.0, iOS 13, macOS 10.15, tvOS 13, watchOS 6 or visionOS 1; the Swift core also supports Linux. Existing Objective-C selectors retain their unrestricted regional behavior. Inverse results can change numerically, and legacy methods return an invalid coordinate for invalid input or conversion failure. Choose the region policy explicitly when adopting the checked API.

These are community approximation formulas. Numerical round-trip consistency is not real-world map accuracy. Near polygon boundaries, the caller should establish whether conversion applies.

[English usage and migration guide](https://github.com/TinyQ/TQLocationConverter/blob/1.0.0/Documentation/Guide.en-US.md) · [Algorithm research](https://github.com/TinyQ/TQLocationConverter/blob/1.0.0/Documentation/Algorithms.en-US.md)
