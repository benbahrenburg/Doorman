Pod::Spec.new do |s|
  s.name             = 'Doorman'
  s.version          = '0.1.0'
  s.summary          = 'Ridiculously simple, sampling and control flow for Swift'
  s.description      = <<-DESC
  Ridiculously simple, sampling and control flow for Swift.
  DESC

  s.homepage         = 'https://github.com/bencoding/Doorman'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ben Bahrenburg' => 'bencoding.com' }
  s.source           = { :git => 'https://github.com/bencoding/Sampify.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bencoding'

  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Doorman/Classes/**/*'
end
