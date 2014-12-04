Pod::Spec.new do |spec|
  spec.name         = 'ProductLayerSDK'
  spec.version      = '0.3.0'
  spec.summary      = "The ultimate product information API, enabling a new breed of product-centric apps."
  spec.homepage     = "https://github.com/ProductLayer/ProductLayer-SDK-for-iOS"
  spec.author       = { "Oliver Drobnik" => "oliver@ProductLayer.com" }
  spec.social_media_url = 'https://twitter.com/ProductLayer'
  spec.source       = { :git => "https://github.com/ProductLayer/ProductLayer-SDK-for-iOS.git", :tag => spec.version.to_s }
  spec.ios.source_files = 'Core/Source/iOS/*.{h,m}', 'Core/Source/*.{h,m}', 'Core/*.h'
  spec.osx.source_files = 'Core/Source/*.{h,m}', 'Core/*.h'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.7'
  spec.license      = 'BSD'
  spec.requires_arc = true
  spec.dependency 'DTFoundation/Core', '~>1.7.4'
  spec.dependency 'DTKeychain', '~>1.0.0'
end
