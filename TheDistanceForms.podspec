Pod::Spec.new do |s| 
  s.name         = "TheDistanceForms"
  s.version      = "0.2.4"
  s.summary      = "An framework for creating flexible forms as generic collections of user input elements."
  s.homepage     = "https://github.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/thedistance/TheDistanceForms.git", :tag => "#{s.version}" }  

  s.ios.deployment_target = '8.0'

  #s.source_files = 'TheDistanceForms/Classes/**/*.swift'
  
  s.requires_arc = true

  s.subspec 'Core' do |c|
	c.source_files = 'TheDistanceForms/Classes/**/*.swift'
  	c.dependency 'TheDistanceCore'
  	c.dependency 'ThemeKit'
  	c.dependency 'AdvancedOperationKit'
  	c.dependency 'KeyboardResponder'
  	c.dependency 'TDStackView'
  	c.dependency 'SwiftyJSON'	
  end

  #s.subspec 'TheDistanceFormsPhotosVideos' do |pv|
  #end
  
  #s.subspec 'TheDistanceFormsThemed' do |t|
  #end 
  
  
end