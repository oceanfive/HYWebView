#
#  Be sure to run `pod spec lint HYWebView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "HYWebView"
  s.version      = "0.2.3"
  s.summary      = "HYWebView"
  s.description  = <<-DESC
  					适配不同的系统，iOS7之前使用UIWebView，iOS7之后使用WKWebView，适配了iPhone X
                   DESC

  s.homepage     = "https://github.com/oceanfive/HYWebView"
  s.license      = "MIT"
  s.author             = { "oceanfive" => "849638313@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/oceanfive/HYWebView.git", :tag => "#{s.version}" }
  s.source_files  = "HYWebViewDemo/HYWebViewDemo/HYWebView/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks = "UIKit"
  s.requires_arc = true

end
