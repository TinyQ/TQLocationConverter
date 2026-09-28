# TQLocationConverter 1.0.1

## 简体中文

整理 Objective-C 源码目录，让仓库根目录保持清晰。

- Objective-C 实现迁入 `Sources/TQLocationConverterObjC/`，公开头文件位于其 `include/` 下，与原生 Swift target 并列。
- 简化 SwiftPM 配置，同步更新 CocoaPods、手动接入文档和旧 iOS 示例的文件引用。
- CI 增加旧示例及测试 bundle 的构建，防止移动文件后留下失效引用。

**接口与算法没有变化。** SwiftPM/CocoaPods 用户可直接升级，模块名和头文件名保持一致。手动引用仓库文件的项目需更新为以下路径，也可以将这两份文件复制到应用的同一目录：

```text
Sources/TQLocationConverterObjC/TQLocationConverter.m
Sources/TQLocationConverterObjC/include/TQLocationConverter.h
```

`1.0.0` 标签保留原来的目录布局。SwiftPM 使用 `from: "1.0.1"`；CocoaPods 使用仓库 Git 地址及 `:tag => '1.0.1'`。此版本尚未发布到 CocoaPods trunk。

[中文使用指南](https://github.com/TinyQ/TQLocationConverter/blob/1.0.1/Documentation/Guide.zh-CN.md)

## English

Organize the Objective-C sources to keep the repository root clear.

- Move the implementation into `Sources/TQLocationConverterObjC/`, with public headers in `include/`, alongside the native Swift target.
- Simplify the SwiftPM manifest and update CocoaPods, manual integration documentation and legacy iOS example references.
- Add a CI build of the legacy example and its test bundle to catch stale references after file moves.

**Public APIs and algorithms are unchanged.** SwiftPM/CocoaPods consumers can upgrade with the same module and header names. Projects referencing repository files directly must update to the paths above; manually copied header/implementation files can still live together in the application.

The `1.0.0` tag retains the old layout. Use `from: "1.0.1"` in SwiftPM, or the repository Git URL with `:tag => '1.0.1'` in CocoaPods. This version has not been published to CocoaPods trunk.

[English usage guide](https://github.com/TinyQ/TQLocationConverter/blob/1.0.1/Documentation/Guide.en-US.md)
