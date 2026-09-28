# Release checklist / 发布清单

Release tags match the podspec version exactly, without a `v` prefix. / 发布标签与 podspec 版本一致，不带 `v` 前缀。

1. Update the podspec version, dated CHANGELOG entry, release notes and both language installation examples together. Review migration notes and supported platforms. / 同步更新 podspec、带日期的变更记录、发布说明及双语安装示例，审查迁移说明与平台要求。
2. Run the checks in CONTRIBUTING, build DocC, and review sample values and links. / 运行贡献指南中的检查，构建 DocC，核对示例数值与链接。
3. Run `bundle install`, `bundle exec pod lib lint TQLocationConverter.podspec` and `bundle exec ruby Scripts/test-cocoapods.rb` with the documented toolchain. Resolve lint warnings instead of suppressing them. / 使用文档指定的工具链检查全部平台和三种链接方式，修复 lint 警告。
4. Review and merge the release preparation PR after all CI jobs pass. The merged commit must already contain the versioned installation docs. / 所有 CI 通过后审查合并发布准备 PR；合并提交中必须已包含版本化安装文档。
5. Create and push an annotated tag on that merged commit, for example `git tag -a 1.0.0 -m 'TQLocationConverter 1.0.0'`. Do not move published tags; fixes need a new version. / 在该合并提交上创建并推送带说明的 tag；不要移动已公开的标签，修复时使用新版本。
6. Wait for **Validate release** to pass on the tag. It installs both SwiftPM products from a fresh remote checkout, checks the resolved version and commit, and runs `pod spec lint` against the remote tag on all five Apple platforms. To retry a transient failure, run the workflow manually with the existing tag. / 等待 tag 的发布验证通过：全新消费项目安装远端 SwiftPM 包并核对版本及提交，五平台验证 CocoaPods 远端源码。临时失败可手动指定同一 tag 重跑工作流。
7. Publish a GitHub release for the verified tag with bilingual notes and migration guidance. / 为通过验证的 tag 发布 GitHub release，附双语说明与迁移指引。
8. Publish the Objective-C pod to trunk only if desired and a maintainer session is available; then verify installation from the public spec index and update the documentation. Until then document the `:git` / `:tag` integration. / 如需发布到 CocoaPods trunk，使用维护者会话发布后验证公共索引安装并更新文档；此前保留 Git 标签安装方式。
9. Optionally submit the package to Swift Package Index and publish generated DocC to GitHub Pages after enabling hosting. / 可选：提交 Swift Package Index，启用文档托管后发布 DocC。

For a local reproduction of tag validation, check out the intended tag and run `python3 Scripts/test-swiftpm-release.py 1.0.0` followed by `bundle exec pod spec lint TQLocationConverter.podspec`. The SwiftPM script requires the remote version to resolve to the current checkout's commit; generated consumers and isolated caches stay in `.build/release/`. / 本地复现时先检出目标 tag，再执行上述两条命令。SwiftPM 检查要求远端版本指向当前检出的提交，生成项目和独立缓存保存在 `.build/release/`。

Use semantic versioning. Changes to defaults, coordinate validity behavior, platform requirements or forward formulas may be breaking changes even if method names remain stable. / 使用语义版本；默认行为、有效范围、平台要求、正向模型的变更可能破坏兼容性。
