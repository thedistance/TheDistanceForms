//
//  TKSwitchStack.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import ThemeKitCore

public class TKSwitchStack: SwitchStack {
    
    /**
     
     `SwitchStack` whose views are ThemeKit equivalents.
     
     - `control` is a `TKSwitch` with `.accent` on tint colour.
     - `titleLabel` is a `TKLabel` with `.Body2` font and `.Text` colour.
     - `subtitleLabel` is a `TKLabel` with `.Body1` font and `.Text` colour.
     - `errorLabel` is a `TKLabel` with `.Caption` font and `.Accent` colour.
     - `errorImageView` is a `TKImageView` with `.Accent` tint colour and `.ScaleAspectFit` contentMode.
     - `iconImageView` is a `TKImageView` with no tint colour and `.ScaleAspectFit` contentMode.
     
    */
    init() {
        
        let switchControl = TKSwitch()
        switchControl.onTintColourStyle = .accent
        
        let titleLabel = TKLabel()
        titleLabel.textStyle = .body2
        titleLabel.textColourStyle = .text
        
        let subtitleLabel = TKLabel()
        subtitleLabel.textStyle = .body1
        subtitleLabel.textColourStyle = .text
        
        let errorLabel = TKLabel()
        errorLabel.textStyle = .caption
        errorLabel.textColourStyle = .accent
        
        let errorImageView = TKImageView()
        errorImageView.tintColourStyle = .accent
        errorImageView.contentMode = .scaleAspectFit
        
        let iconImageView = TKImageView()
        iconImageView.contentMode = .scaleAspectFit
        
        super.init(switchControl: switchControl,
                   titleLabel: titleLabel,
                   subtitleLabel: subtitleLabel,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
    }
    
}
