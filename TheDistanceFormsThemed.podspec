Pod::Spec.new do |s| 
  s.name         = "TheDistanceFormsThemed"
  s.version      = "0.2.8"
  s.summary      = "An framework for creating flexible forms as generic collections of user input elements."
  s.homepage     = "https://github.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/thedistance/TheDistanceForms.git", :tag => "#{s.version}" }  

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
    
  s.module_name 	= "TheDistanceFormsThemed"   
  s.default_subspec = "TheDistanceFormsThemed"

  s.subspec 'TheDistanceFormsThemed' do |t|
	t.source_files = 'TheDistanceFormsThemed/ThemedClasses/*.swift'
  	t.dependency 'ThemeKit'	
  	t.dependency 'TheDistanceCore'
  	t.dependency 'AdvancedOperationKit'
  	t.dependency 'KeyboardResponder'
  	t.dependency 'TDStackView'
  	t.dependency 'SwiftyJSON'
  	t.dependency 'TheDistanceForms'	
  end 
  
end