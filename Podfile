platform :ios, '14.0'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
         end
    end
  end

  installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
  end
end

use_frameworks!

target 'FanNoise' do

  pod 'SwiftLint'
  pod 'RxSwift', '~> 5.1'
  pod 'RealmSwift', '~> 10.32.3'
  pod 'Swinject'
  pod 'TLLogging'
  pod 'YYImage'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Alamofire', '4.9.1'
  pod 'SDWebImage'
  pod 'SVProgressHUD'

end
