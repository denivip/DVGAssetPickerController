#
# Be sure to run `pod lib lint DVGAssetPickerController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DVGAssetPickerController"
  s.version          = "0.1.0"
  s.summary          = "Assets Library media picker controller similar to Messages.app."
  s.description      = <<-DESC
This is an attempt to reimplement Apple's UI from Messages.app for iOS where
you can select photos from Camera Roll to attach to your imessage.
                       DESC
  s.homepage         = "https://github.com/denivip/DVGAssetPickerController"
  s.screenshots      = "https://raw.githubusercontent.com/denivip/DVGAssetPickerController/master/Screenshots/screenshot1.jpg", "https://raw.githubusercontent.com/denivip/DVGAssetPickerController/master/Screenshots/screenshot2.jpg"
  s.license          = 'MIT'
  s.author           = { "DENIVIP Group" => "support@denivip.ru" }
  s.source           = { :git => "https://github.com/denivip/DVGAssetPickerController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AppTogether'

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'DVGAssetPickerController' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/DVGAssetPickerViewController.h'
  s.frameworks = 'UIKit', 'AssetsLibrary'
  s.dependency 'TLLayoutTransitioning'
end
