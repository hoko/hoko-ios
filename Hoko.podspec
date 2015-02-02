Pod::Spec.new do |s|
  s.name         = "Hoko"
  s.version      = "1.0.2"
  s.summary      = "Hoko is a mobile deeplinking platform."
  s.homepage     = "http://hokolinks.com"
  s.license      = { 
    :type => 'Copyright',
    :file => 'LICENSE'
  }
  s.social_media_url  = 'https://twitter.com/hokolinks'
  s.author       = { "Hoko S.A." => "support@hokolinks.com" }
  s.source       = { :git => "https://github.com/hokolinks/ios.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '5.0'
  s.frameworks = %w(Foundation SystemConfiguration)
  s.library = 'z'
  s.source_files = 'Hoko.framework/Versions/A/Headers/*.h'
  s.requires_arc = true
  s.ios.vendored_frameworks = 'Hoko.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited)' }
  s.preserve_paths = 'Hoko.framework'
end
