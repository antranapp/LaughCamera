Pod::Spec.new do |s|
  s.name             = "LaughCamera"
  s.version          = "1.0"
  s.summary          = "A fast, straightforward implementation of AVFoundation camera with customizable real-time photo filters."
  s.homepage         = "https://github.com/peacemoon/LaughCamera"
  s.license          = 'MIT'
  s.author           = {
                          "Laura Skelton" => "laura@ifttt.com",
                          "Jonathan Hersh" => "jonathan@ifttt.com",
                          "Max Meyers" => "max@ifttt.com",
                          "Devin Foley" => "devin@ifttt.com"
                       }
  s.source           = { :git => "https://github.com/peacemoon/LaughCamera.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/peacemoon'
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.compiler_flags   = '-fmodules'
  s.frameworks       = 'UIKit', 'AVFoundation', 'CoreMotion'

  s.source_files     = 'LaughCamera/*.{h,m}'

end
