Pod::Spec.new do |s|
  s.name             = "LaughCamera"
  s.version          = "0.0.1"
  s.summary          = "A fast, straightforward implementation of AVFoundation camera with customizable real-time photo filters (and facial gestures recognition)."
  s.homepage         = "https://github.com/peacemoon/LaughCamera"
  s.license          = 'MIT'
  s.author           = {
                          "An Tran" => "tran.binhan@gmail.com",
                       }
  s.source           = { :git => "https://github.com/peacemoon/LaughCamera.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/peacemoon'
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.compiler_flags   = '-fmodules'
  s.frameworks       = 'UIKit', 'AVFoundation', 'CoreMotion'

  s.source_files     = 'LaughCamera/*.{h,m}'

end
