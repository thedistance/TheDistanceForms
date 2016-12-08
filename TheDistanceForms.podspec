Pod::Spec.new do |s| 
  s.name         = "TheDistanceForms"
  s.version      = "0.2.7"
  s.summary      = "An framework for creating flexible forms as generic collections of user input elements."
  s.homepage     = "https://github.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/thedistance/TheDistanceForms.git", :tag => "#{s.version}" }  

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  #s.source_files = 'TheDistanceForms/Classes/**/*.swift'
  
  s.module_name 	= "TheDistanceForms"   
  s.default_subspec = "TheDistanceForms"

  s.subspec 'TheDistanceForms' do |c|
	c.source_files = 'TheDistanceForms/Classes/**/*.swift'
  	c.dependency 'TheDistanceCore'
  	c.dependency 'AdvancedOperationKit'
  	c.dependency 'KeyboardResponder'
  	c.dependency 'TDStackView'
  	c.dependency 'SwiftyJSON'	
  end

  s.subspec 'TheDistanceFormsPhotosVideos' do |pv|
	pv.source_files = 'TheDistanceFormsPhotosVideos/**/*.swift'  
  	pv.dependency 'TheDistanceCore'
  	pv.dependency 'AdvancedOperationKit'
  	pv.dependency 'KeyboardResponder'
  	pv.dependency 'TDStackView'
  	pv.dependency 'SwiftyJSON'		
  end
  
  s.subspec 'TheDistanceFormsThemed' do |t|
	t.source_files = 'TheDistanceFormsThemed/ThemedClasses/*.swift', 'TheDistanceForms/Classes/**/*.swift'
  	t.dependency 'ThemeKit'	
  	t.dependency 'TheDistanceCore'
  	t.dependency 'AdvancedOperationKit'
  	t.dependency 'KeyboardResponder'
  	t.dependency 'TDStackView'
  	t.dependency 'SwiftyJSON'
  end 
  
  
end