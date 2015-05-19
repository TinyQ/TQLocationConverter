#
#  Be sure to run `pod spec lint TQLocationConverter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "TQLocationConverter"
  s.version      = "0.0.1"
  s.summary      = "Converter CLLocation GCJ-02,WGS-84,Baidu."
  s.homepage     = "https://github.com/TinyQ/TQLocationConverter"
  s.license      = "MIT"
  s.author       = { "qfu" => "tinyqf@gmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/TinyQ/TQLocationConverter.git", :tag => "v0.0.1" }
  s.source_files = "TQLocationConverter.{h,m}"
  s.frameworks   = "CoreLocation"
  s.requires_arc = true
end
