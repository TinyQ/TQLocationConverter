Pod::Spec.new do |s|
  s.name = 'TQLocationConverter'
  s.version = '1.0.0'
  s.summary = 'Offline WGS-84, GCJ-02 and BD-09LL conversion for Apple platforms.'
  s.description = 'Objective-C coordinate conversion with validation, explicit region policies, and refined numerical inverses. Native Swift support is available through Swift Package Manager.'
  s.homepage = 'https://github.com/TinyQ/TQLocationConverter'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'qfu' => 'tinyqf@gmail.com' }
  # Prepared for the first modern release. Create this tag only after validation and review.
  s.source = { :git => 'https://github.com/TinyQ/TQLocationConverter.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'
  s.visionos.deployment_target = '1.0'
  s.source_files = 'TQLocationConverter.{h,m}'
  s.public_header_files = 'TQLocationConverter.h'
  s.frameworks = 'Foundation', 'CoreLocation'
  s.requires_arc = true
end
