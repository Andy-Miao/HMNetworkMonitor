Pod::Spec.new do |s|
  s.name         = 'HMNetworkMonitor'
  s.summary      = 'iOS Network Monitor Tool.'
  s.version      = '0.0.1'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'Andy-Miao' => 'andy_hm@qq.com' }
 # s.social_media_url = 'https://twitter.com/Andy-Miao'
  s.homepage     = 'https://github.com/Andy-Miao/HMNetworkMonitor'
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.source       = { :git => 'https://github.com/Andy-Miao/HMNetworkMonitor.git', :tag => s.version }
  
  s.requires_arc = true
  s.source_files = 'NetworkMonitor/**/*.{h,m}'
  s.public_header_files = 'NetworkMonitor/**/*.{h}'

end
