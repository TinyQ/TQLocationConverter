# Release checklist / 发布清单

The current changes prepare `1.0.0`; they do not publish it. / 当前改动准备 `1.0.0`，并不代表已经发布。

1. Review and merge the implementation PR after CI passes on macOS and Linux. Verify Apple deployment targets with Xcode. / CI 通过后审查合并，使用 Xcode 验证 Apple 平台。
2. Run the commands in CONTRIBUTING, build DocC, and review bilingual migration notes. Check sample numbers and links. / 运行贡献指南中的检查，构建 DocC，审阅双语迁移说明。
3. If publishing CocoaPods, run `pod lib lint TQLocationConverter.podspec --allow-warnings` locally and inspect every warning. A real `pod spec lint` must also resolve the eventual source tag. / 如发布 CocoaPods，验证本地包并审查警告；源 tag 创建后还需验证远端 spec。
4. Confirm `Package.swift`, podspec and supported platforms agree; change the podspec version and release notes together. / 核对包配置与系统要求，同步版本号及发行说明。
5. Move Unreleased entries to the dated version in CHANGELOG. Create the corresponding annotated Git tag, e.g. `1.0.0`, on the reviewed commit and publish a GitHub release. The podspec uses the same tag without a `v` prefix. / 更新变更记录，在已审查提交上创建同名 tag（不带 v 前缀）并发布 GitHub release。
6. Replace development-branch examples with `.package(url: ..., from: "1.0.0")` after the tag exists. Remove the unpublished-release notes from both READMEs and guides. / tag 存在后，将双语文档示例改为版本依赖，删除尚未发布的提示。
7. Publish the Objective‑C pod to trunk only if desired and credentials are available; then verify a clean consumer project with the published version. / 如需发布 CocoaPods，再使用维护者凭据发布并在全新消费项目验证。
8. Optionally submit the package to Swift Package Index and publish generated DocC to GitHub Pages after enabling hosting. / 可选：提交 Swift Package Index，启用文档托管后发布 DocC。

Use semantic versioning. Changes to defaults, coordinate validity behavior, platform requirements or forward formulas may be breaking changes even if method names remain stable. / 使用语义版本；默认行为、有效范围、平台要求、正向模型的变更可能破坏兼容性。
