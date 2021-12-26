# initial setup
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

def pods
    pod 'Alamofire'
    pod 'CryptoSwift'
end

target 'SwiftAPIClient' do
    platform :ios, '11'
    pods
    
    target 'SwiftAPIClient iOS Tests' do
      inherit! :search_paths
    end
end

target 'SwiftAPIClient-tvOS' do
    platform :tvos, '11'
    pods
end

target 'SwiftAPIClient-watchOS' do
    platform :watchos, '4'
    pods
end

target 'SwiftAPIClient-macOS' do
    platform :osx, '10.14'
    pods
end
