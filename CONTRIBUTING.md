# 贡献指南

[English](CONTRIBUTING.en-US.md)

欢迎提交问题、文档修正和代码改进。小型修复可以直接开 PR；新增坐标系或修改默认语义，建议先用 issue 说明具体场景与依据。

## 本地开发

需要 Swift 6.0+。Apple 平台、Objective‑C 和 DocC 验证需要 Xcode；Swift 核心可在 Linux 上构建。不需要额外的第三方包。

```sh
swift test
swift test -c release
swift run -c release ConversionBenchmark
python3 Scripts/check-docs.py
python3 Scripts/check-repository.py
# macOS
bash Scripts/test-objc.sh
xcrun swift-format lint --strict --recursive Package.swift Sources Tests Benchmarks
```

格式化：`xcrun swift-format format --in-place --recursive Package.swift Sources Tests Benchmarks`。CI 在 macOS 运行两种语言的测试，在 Linux 检查 Swift 6.0 与 6.2。

### CocoaPods 集成验证

修改 Objective-C、podspec 或接入方式时，使用 Ruby 3.4、Bundler 和 Xcode 16.4 运行：

```sh
bundle install
bundle exec pod lib lint TQLocationConverter.podspec
bundle exec ruby Scripts/test-cocoapods.rb
```

`Gemfile.lock` 固定的是开发工具依赖，转换库没有第三方运行时依赖。Lint 构建并检查全部五个 Apple 平台；独立 macOS 消费项目通过静态库、静态 framework、动态 framework 三种方式安装 CocoaPods，并分别编译运行 Objective-C 与 Swift 调用代码。生成文件位于 `.build/cocoapods/`。单独验证一种方式可传入 `static-library`、`static-framework` 或 `dynamic-framework`。

CI 使用 Xcode 16.4 检查声明的最低部署版本；构建检查不代表在所有旧系统上执行过测试。较新的 Xcode 可能不再接受这些最低部署版本。例如，在 Xcode 27 上进行本地消费项目测试时，可使用 `TQ_TEST_MACOS_DEPLOYMENT_TARGET=12.0 bundle exec ruby Scripts/test-cocoapods.rb`；这只覆盖本次消费项目构建参数，不修改库的系统要求，也不替代最低版本的 CI 检查。完整 lint 还需要对应平台的模拟器 runtime。

仓库检查基于 Git 跟踪清单，会拦截 `.DS_Store`、构建缓存和 IDE 私人设置，即使文件是用 `git add -f` 加入的。

## 修改算法

1. 明确改变的是正向模型、逆变换求解还是地域策略。不要把往返误差当作真实精度。
2. 保留参考样本来源与固定提交。真实坐标应使用可公开的测试点，不要上传用户位置数据。
3. Swift 与 Objective‑C 同步修改；运行一致性测试，覆盖区域内外、边界、无效输入和回归样例。
4. 逆变换必须有次数上限与失败路径；不要静默返回未收敛的猜测。
5. 修改常数或多边形会影响兼容性。两种语言的多边形数据必须同步，并解释变更依据。
6. 更新中英文文档、迁移说明和 CHANGELOG 的 Unreleased 条目。

## 提交 PR

描述具体问题、改变后的行为、验证方法及兼容性影响。保持修改聚焦，避免生成缓存、IDE 私人设置或构建产物进入仓库。新增依赖需说明必要性和许可证。

报告问题时请提供工具链/系统版本、源与目标坐标系、地域策略、可公开复现的输入、预期值及其来源。中英文均可。

维护者发布步骤见[发布清单](Documentation/Releasing.md)。所有贡献按项目 MIT 许可证提供。
