#!/usr/bin/env ruby
# Build and run independent consumers using the public CocoaPods headers/module.
require 'fileutils'
require 'pathname'
require 'xcodeproj'

root = Pathname.new(__dir__).parent
modes = %w[static-library static-framework dynamic-framework]
abort "Usage: bundle exec ruby #{$PROGRAM_NAME} [#{modes.join('|')}]" unless ARGV.empty? || (ARGV.length == 1 && modes.include?(ARGV.first))
modes = ARGV unless ARGV.empty?

modes.each do |mode|
  directory = root.join('.build', 'cocoapods', mode)
  FileUtils.mkdir_p(directory)
  project = Xcodeproj::Project.new(directory.join('Consumer.xcodeproj'))
  { 'ObjectiveCConsumer' => 'Tests/ObjectiveC/main.m',
    'SwiftConsumer' => 'Tests/CocoaPods/main.swift' }.each do |name, source|
    target = project.new_target(:application, name, :osx, '10.15')
    target.source_build_phase.add_file_reference(project.main_group.new_file(root.join(source).to_s))
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.tinyq.tests.#{name}"
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      config.build_settings['CLANG_ENABLE_OBJC_ARC'] = 'YES'
      config.build_settings['SWIFT_VERSION'] = '6.0'
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/../Frameworks']
    end
  end
  project.save

  linkage = case mode
            when 'static-library' then 'use_modular_headers!'
            when 'static-framework' then 'use_frameworks! :linkage => :static'
            else 'use_frameworks! :linkage => :dynamic'
            end
  directory.join('Podfile').write(<<~PODFILE)
    platform :osx, '10.15'
    install! 'cocoapods', :deterministic_uuids => true
    #{linkage}
    target 'ObjectiveCConsumer' do
      pod 'TQLocationConverter', :path => #{root.to_s.dump}
    end
    target 'SwiftConsumer' do
      pod 'TQLocationConverter', :path => #{root.to_s.dump}
    end
  PODFILE
  system('bundle', 'exec', 'pod', 'install', '--project-directory=' + directory.to_s, exception: true)
  %w[ObjectiveCConsumer SwiftConsumer].each do |name|
    # The minimum deployment target is checked by CI with Xcode 16.4. Newer SDKs
    # can require a higher target for a local smoke run; never change the podspec for it.
    overrides = ENV['TQ_TEST_MACOS_DEPLOYMENT_TARGET'] ? ["MACOSX_DEPLOYMENT_TARGET=#{ENV.fetch('TQ_TEST_MACOS_DEPLOYMENT_TARGET')}"] : []
    system('xcodebuild', '-workspace', directory.join('Consumer.xcworkspace').to_s,
           '-scheme', name, '-configuration', 'Release', '-destination', 'generic/platform=macOS',
           '-derivedDataPath', directory.join('DerivedData').to_s,
           'CODE_SIGNING_ALLOWED=NO', *overrides, 'build', exception: true)
    system(directory.join('DerivedData', 'Build', 'Products', 'Release', "#{name}.app", 'Contents', 'MacOS', name).to_s, exception: true)
  end
  puts "CocoaPods #{mode}: Objective-C and Swift consumers built and ran successfully."
end
