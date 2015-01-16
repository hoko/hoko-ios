Pod::Spec.new do |s|
  s.name         = "Hoko"
  s.version      = "1.0.0"
  s.summary      = "Hoko is a mobile deeplinking platform."
  s.homepage     = "http://hokolinks.com"
  s.license      = { 
    :type => 'Copyright',
    :file => 'LICENSE'
  }
  s.author       = 'Hoko'
  s.source       = { :git => "https://github.com/hokolinks/ios.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'Hoko.framework/Versions/A/Headers/*.h'
  s.requires_arc = true
  s.ios.vendored_frameworks = 'Hoko.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited)' }
  s.preserve_paths = 'Hoko.framework'
end
