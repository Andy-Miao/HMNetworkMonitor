Pod::Spec.new do |s|
  s.name         = "HMNetworkMonitor"
  s.version      = "0.0.1"
  s.ios.deployment_target = '6.0'
  s.summary      = "iOS Network Monitor Tool."
  s.homepage     = "https://github.com/Andy-Miao/HMNetworkMonitor"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Andy-Miao" => "andy_hm@qq.com" }
#   s.social_media_url   = "https://twitter.com/Andy-Miao"
  s.source       = { :git => "https://github.com/Andy-Miao/HMNetworkMonitor.git", :tag => s.version }
  s.source_files  = "NetworkMonitor"
  s.requires_arc = true
end