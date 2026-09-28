# Changelog / 变更记录

## Unreleased — preparing 1.0.0 / 准备发布 1.0.0

### Added / 新增

- Native Swift 6 library and SwiftPM products for Swift and Objective‑C; Linux-compatible Swift core.
  原生 Swift 6 实现，Swift 与 Objective‑C 独立的 SwiftPM 产品，兼容 Linux 的 Swift 核心。
- Explicit source/destination systems, region policies, checked errors and WGS‑84 ⇄ BD‑09LL routes.
  显式坐标系、地域策略、错误处理与 WGS‑84 ⇄ BD‑09LL 组合转换。
- Bilingual guides, algorithm research, DocC, contribution workflow, CI and reproducible benchmarks.
  双语文档、算法调研、DocC、贡献流程、CI 与可复现基准。

### Changed / 调整

- Refine both GCJ‑02 and BD‑09LL inverses with bounded residual iteration.
  两种逆变换均采用有上限的残差迭代，数值结果可能与旧版略有不同。
- Replace Objective‑C's mutable polygon and UIKit dependency with immutable coordinate data.
  Objective‑C 去除可变多边形数组及 UIKit 依赖；线段上的点按区域内处理。
- Reject invalid coordinates/results and report non-convergence instead of returning guesses.
  校验输入与结果，报告不收敛。旧方法失败时返回无效坐标哨兵。
- Modern distribution targets Swift 6, iOS 13, macOS 10.15, tvOS 13, watchOS 6 and visionOS 1.
  现代分发包提高最低工具链和系统要求；旧 Objective‑C 方法签名与不自动判断地域的行为保留。

No new release tag or CocoaPods trunk publication has been made. The podspec version is a release candidate configuration.
尚未创建新版本 tag 或发布 CocoaPods；podspec 版本仅用于准备发布。

## Legacy / 历史

- 2021-06-28: Azure Pipelines configuration / Azure Pipelines 配置。
- 2016-10-17: Approximate mainland polygon and region tests / 大陆近似多边形与范围测试。
- 2014-09-16: Initial Objective‑C implementation / 初始 Objective‑C 实现。
