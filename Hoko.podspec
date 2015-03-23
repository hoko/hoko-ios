Pod::Spec.new do |s|
  s.name     = 'Hoko'
  s.version  = '1.1.4'
  s.platform = :ios, '5.0'
  s.license  = 'Apache'
  s.summary  = 'Connect all your platforms with a single link with HOKO deep linking technology'
  s.homepage = 'https://github.com/hokolinks/hoko-ios'
  s.social_media_url = 'https://twitter.com/hokolinks'
  s.authors  = { 
  	'Ivan Bruel' => 'ivan@hokolinks.com',
  	'Hoko S.A.' => 'support@hokolinks.com'
  }
  s.source       = { :git => 'https://github.com/hokolinks/hoko-ios.git', :tag => "v#{s.version}"}
  s.requires_arc = true

  s.public_header_files = 'Hoko/*.h'
  s.source_files = 'Hoko/*.{h,m}'
  s.frameworks = %w(Foundation SystemConfiguration)
  s.library = 'z'
end
