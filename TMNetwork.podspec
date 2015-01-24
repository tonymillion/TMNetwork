Pod::Spec.new do |s|

  s.name         = "TMNetwork"
  s.version      = "0.0.4"
  s.summary      = "Simple networking that makes sense."

  s.homepage           = "https://github.com/tonymillion/TMNetwork"
  s.license            = { :type => 'MIT' }
  s.author             = { "Tony Million" => "tonymillion@gmail.com" }
  s.source             = { :git => "https://github.com/tonymillion/TMNetwork.git", :tag => "0.0.4" }
  s.social_media_url   = "http://twitter.com/tonymillion"

  s.platform     = :ios, "7.0"
  s.requires_arc = true

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

end
