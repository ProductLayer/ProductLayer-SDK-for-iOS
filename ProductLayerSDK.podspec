Pod::Spec.new do |spec|
  spec.name         = 'ProductLayerSDK'
  spec.version      = '0.3.0'
  spec.summary      = "The ultimate product information API, enabling a new breed of product-centric apps."
  spec.homepage     = "https://github.com/ProductLayer/ProductLayer-SDK-for-iOS"
  spec.author       = { "Oliver Drobnik" => "oliver@ProductLayer.com" }
  spec.social_media_url = 'https://twitter.com/ProductLayer'
  spec.source       = { :git => "https://github.com/ProductLayer/ProductLayer-SDK-for-iOS.git" }
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.7'
  spec.license      = 'BSD'
  spec.requires_arc = true

  spec.subspec 'Core' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.7'
    ss.dependency 'DTFoundation/Core', '~>1.7.4'
    ss.dependency 'DTKeychain', '~>1.0.0'
    ss.dependency 'ProductLayerSDK/PLYEntities'
    ss.source_files = 'Core/Source/*.{h,m}'
  end

  spec.subspec 'PLYEntities' do |ss|
    ss.source_files = 'Core/Source/PLYEntities/*.{h,m}'
  end

end
