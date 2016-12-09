//
//  MyTheme.swift
//  ThemeKit
//
//  Created by Josh Campion on 07/02/2016.
//  Copyright © 2016 Josh Campion. All rights reserved.
//

import UIKit
import ThemeKitCore

// Define your app specific theme

/// License Key for you app's bundle ID. Use "Simulator" for a trial that allows the framework to run on Simulator.
let ThemeKitLicense =  "Simulator"

struct MyTheme: Theme {
    
    /// Use the default text sizes as standard
    let defaultTextSizes = MaterialTextSizes // default
    
    /// Use the Apple standard font adjustmentst to give consistent user experience for users with adjusted accessibility settings.
    let textSizeAdjustments = AppleFontAdjustments // default
    
    // Swap These for the colours in you app
    let themeColours:[ColourStyle:UIColor] = [.accent: UIColor.red,
                                              .main: UIColor.blue,
                                              .text: UIColor.black.withAlphaComponent(0.87),
                                              .secondaryText: UIColor.black.withAlphaComponent(0.54),
                                              .lightText: UIColor.white.withAlphaComponent(0.87),
                                              .secondaryLightText: UIColor.white.withAlphaComponent(0.54),
                                              ]
    
    /// Use standard iOS sans-serif fonts.
    func fontName(_ textStye:TextStyle) -> String {
        
        let thinFont:String = "AvenirNext-Regular"
        let normalFont:String = "AvenirNext-DemiBold"
        let mediumFont:String = "AvenirNext-Bold"
        
        // --- Replace these values to return branded fonts if applicable.
        switch textStye {
        case .display4:
            return thinFont
        case .display3, .display2, .display1:
            return thinFont
        case .headline:
            return normalFont
        case .title:
            return mediumFont
        case .subHeadline:
            return normalFont
        case .body2, .button:
            return mediumFont
        case .body1, .custom(_):
            return thinFont
        case .caption:
            return normalFont
        }
    }
}

// Create a vendor...

/// Custom Vendor to return the theme specific to this app.
class MyVendor: TKThemeVendor {
    
    private var _defaultTheme:Theme? = MyTheme()
    
    override var defaultTheme:Theme? {
        get {
            return _defaultTheme
        }
        set {
            _defaultTheme = newValue
        }
    }
}

// ... and assign it as the default vendor early in the running stage
extension TKThemeVendor {
    
    override open class func initialize() {
        
        if self == TKThemeVendor.self {
            assert(MyVendor.shared().defaultTheme != nil)
        }
        
        super.initialize()
    }
}

// Extend to return your Theme for Interface Builder
extension IBThemeable {
    
    public func ibTheme() -> Theme? {
        return MyTheme()
    }
}
