Pod::Spec.new do |s|
  s.name             = 'FlexImageCropView'
  s.version          = '1.1'
  s.license          = 'MIT'
  s.summary          = 'Image Cropping using Flex Style Component Framework'
  s.homepage         = 'https://github.com/Rehsco/FlexImageCropView.git'
  s.authors          = { 'Martin Jacob Rehder' => 'gitrepocon01@rehsco.com' }
  s.source           = { :git => 'https://github.com/Rehsco/FlexImageCropView.git', :tag => s.version }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '11.0'

  s.dependency 'MJRFlexStyleComponents'
  s.dependency 'StyledOverlay'
  s.dependency 'StyledLabel'
  

  s.platform     = :ios, '11.0'
  s.framework    = 'UIKit'
  s.source_files = 'FlexImageCropView/**/*.swift'
  s.resources    = 'FlexImageCropView/**/*.xcassets'
  s.requires_arc = true
end
