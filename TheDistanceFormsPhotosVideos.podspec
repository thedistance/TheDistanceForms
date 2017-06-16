Pod::Spec.new do |s| 
  s.name         = "TheDistanceFormsPhotosVideos"
  s.version      = "0.3.5"
  s.summary      = "An framework for creating flexible forms as generic collections of user input elements."
  s.homepage     = "https://github.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/thedistance/TheDistanceForms.git", :tag => "#{s.version}" }  

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  s.module_name 	= "TheDistanceFormsPhotosVideos"   
  s.default_subspec = "TheDistanceFormsPhotosVideos"

  s.subspec 'TheDistanceFormsPhotosVideos' do |pv|
	pv.source_files = 'TheDistanceFormsPhotosVideos/**/*.swift'
  	pv.dependency 'TheDistanceCore'
  	pv.dependency 'AdvancedOperationKit'
  	pv.dependency 'KeyboardResponder'
  	pv.dependency 'TDStackView'
  	pv.dependency 'SwiftyJSON'
  	pv.dependency 'TheDistanceForms'		
  end
    
end
