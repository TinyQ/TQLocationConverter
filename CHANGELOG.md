# Changelog / 变更记录

## 1.0.1 — 2026-09-28

- Move Objective-C implementation and public headers into `Sources/TQLocationConverterObjC/`, alongside the native Swift target. Simplify the SwiftPM manifest and update CocoaPods, manual integration and the legacy example.
  Objective-C 实现与公开头文件迁入 `Sources/TQLocationConverterObjC/`，与 Swift target 并列；简化 SwiftPM 配置，同步 CocoaPods、手动接入和旧示例工程。
- Preserve public API, module/header names and coordinate algorithms. Projects referencing the old repository paths directly must update those paths; published `1.0.0` files stay available at that tag.
  公开接口、模块/头文件名和算法保持一致。直接引用旧仓库路径的项目需更新路径；已发布的 `1.0.0` 文件仍可从该标签获取。
- Add a CI build of the legacy iOS example and its test bundle to catch stale source references.
  CI 增加旧 iOS 示例与测试 bundle 的构建，检查源码引用是否有效。

## 1.0.0 — 2026-09-28

### Added / 新增

- Native Swift 6 library and SwiftPM products for Swift and Objective‑C; Linux-compatible Swift core.
  原生 Swift 6 实现，Swift 与 Objective‑C 独立的 SwiftPM 产品，兼容 Linux 的 Swift 核心。
- Explicit source/destination systems, region policies, checked errors and WGS‑84 ⇄ BD‑09LL routes.
  显式坐标系、地域策略、错误处理与 WGS‑84 ⇄ BD‑09LL 组合转换。
- Bilingual guides, algorithm research, DocC, contribution workflow, CI and reproducible benchmarks.
  双语文档、算法调研、DocC、贡献流程、CI 与可复现基准。
- CocoaPods validation for all five Apple platforms, independent Objective-C/Swift consumers in three linkage modes, locked development tooling and a CI check against tracked local metadata.
  CocoaPods 五平台验证、三种链接方式下独立的 Objective-C/Swift 消费项目、锁定的开发工具依赖及防止缓存误提交的 CI 检查。

### Changed / 调整

- Refine both GCJ‑02 and BD‑09LL inverses with bounded residual iteration.
  两种逆变换均采用有上限的残差迭代，数值结果可能与旧版略有不同。
- Replace Objective‑C's mutable polygon and UIKit dependency with immutable coordinate data.
  Objective‑C 去除可变多边形数组及 UIKit 依赖；线段上的点按区域内处理。
- Reject invalid coordinates/results and report non-convergence instead of returning guesses.
  校验输入与结果，报告不收敛。旧方法失败时返回无效坐标哨兵。
- Modern distribution targets Swift 6, iOS 13, macOS 10.15, tvOS 13, watchOS 6 and visionOS 1.
  现代分发包提高最低工具链和系统要求；旧 Objective‑C 方法签名与不自动判断地域的行为保留。

Distribution: SwiftPM version `1.0.0`, or the same Git tag for the Objective-C CocoaPod. This version is not published to CocoaPods trunk.
分发方式：SwiftPM `1.0.0` 版本依赖，或 Objective-C CocoaPod 的同名 Git 标签；此版本未发布到 CocoaPods trunk。

## Legacy / 历史

- 2021-06-28: Azure Pipelines configuration / Azure Pipelines 配置。
- 2016-10-17: Approximate mainland polygon and region tests / 大陆近似多边形与范围测试。
- 2014-09-16: Initial Objective‑C implementation / 初始 Objective‑C 实现。
