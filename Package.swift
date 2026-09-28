// swift-tools-version: 6.0
import PackageDescription

var products: [Product] = [
  .library(name: "TQLocationConverter", targets: ["TQLocationConverter"])
]
var testDependencies: [Target.Dependency] = ["TQLocationConverter"]
var targets: [Target] = [
  .target(name: "TQLocationConverter"),
  .executableTarget(
    name: "ConversionBenchmark", dependencies: ["TQLocationConverter"], path: "Benchmarks"),
]

// Objective-C requires Apple's Foundation and CoreLocation. Keep the Swift core portable.
#if os(macOS)
  products.append(.library(name: "TQLocationConverterObjC", targets: ["TQLocationConverterObjC"]))
  targets.append(
    .target(
      name: "TQLocationConverterObjC",
      path: ".",
      exclude: [
        "Sources", "Tests", "Benchmarks", "Test", "Documentation", "Scripts", "README.md",
        "README.en-US.md", "LICENSE", "CHANGELOG.md", "CONTRIBUTING.md", "CONTRIBUTING.en-US.md",
        "TQLocationConverter.podspec", "Gemfile", "Gemfile.lock",
      ],
      sources: ["TQLocationConverter.m"],
      publicHeadersPath: "include",
      linkerSettings: [.linkedFramework("Foundation"), .linkedFramework("CoreLocation")]
    ))
  testDependencies.append("TQLocationConverterObjC")
#endif

targets.append(
  .testTarget(
    name: "TQLocationConverterTests",
    dependencies: testDependencies,
    resources: [.copy("Fixtures")]
  ))

let package = Package(
  name: "TQLocationConverter",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
  products: products,
  targets: targets,
  swiftLanguageModes: [.v6]
)
