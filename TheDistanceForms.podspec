Pod::Spec.new do |s| 
  s.name         = "TheDistanceForms"
  s.version      = "0.3.5"
  s.summary      = "An framework for creating flexible forms as generic collections of user input elements."
  s.homepage     = "https://github.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/thedistance/TheDistanceForms.git", :tag => "#{s.version}" }  

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
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

end
