source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'

use_frameworks!

workspace 'PoliteCoreData'

target 'PoliteCoreData_Framework' do
    project 'PoliteCoreData_Framework.xcodeproj'
end

target 'PoliteCoreData_Example' do
    project 'PoliteCoreData_Example.xcodeproj'
    pod 'Shakuro.CommonTypes', '1.9.0'
    pod 'SwiftLint', '0.57.1'
end

post_install do |installer|
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
  
end
