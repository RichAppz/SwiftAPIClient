Pod::Spec.new do |s|
  s.name = 'SwiftAPIClient'
  s.version = '1.2.6'
  s.license = 'MIT'
  s.summary = 'Simple API Client for Apple Swift Projects'
  s.homepage = 'https://github.com/RichAppz'
  s.source = { :git => 'https://github.com/RichAppz/SimpleAPIClient.git', :tag => s.version }
  s.authors = { 'Rich Mucha' => 'rich@richappz.com' }
  
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '3.0'
  
  s.source_files = 'Source/**/*.{swift}'
  s.ios.source_files = 'Reachability/**/*.{swift}'
  s.osx.source_files = 'Reachability/**/*.{swift}'
  s.tvos.source_files = 'Reachability/**/*.{swift}'
  s.swift_versions = '5.0'
  
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'CryptoSwift'
  
#  s.test_spec 'Tests' do |test_spec|
#      test_spec.source_files = 'Tests/**/*.{swift}'
#      test_spec.dependency 'Alamofire', '~> 4.0'
#      test_spec.dependency 'CryptoSwift'
#  end

end 
