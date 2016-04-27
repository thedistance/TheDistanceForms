//
//  TKSegmentedTextFieldStack.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import ThemeKitCore

/**
 
 `SegmentedTextFieldStack` whose views are ThemeKit equivalents.
 
 - `choiceControl` is a `TKSegmentedControl` with `.Button` text style and `.Accent` tint colour.
 - `inputStack` is a default `TKTextFieldStack`
 - `titleLabel` is a `TKLabel` with `.Body2` font and `.Text` colour.
 - `subtitleLabel` is a `TKLabel` with `.Body1` font and `.Text` colour.
 - `errorLabel` is a `TKLabel` with `.Caption` font and `.Accent` colour.
 - `errorImageView` is a `TKImageView` with `.Accent` tint colour and `.ScaleAspectFit` contentMode.
 - `iconImageView` is a `TKImageView` with no tint colour and `.ScaleAspectFit` contentMode.

 - parameter items: The choices to initialise the `Segmentext
 
 */
public class TKSegmentedTextFieldStack: SegmentedTextFieldStack {
    
    init(items:[AnyObject]?) {
        
        let segmentedControl = TKSegmentedControl(items: items)
        segmentedControl.textStyle = .Button
        segmentedControl.tintColourStyle = .Accent
        
        let inputStack = TKTextViewStack()
        
        let titleLabel = TKLabel()
        titleLabel.textStyle = .Body2
        titleLabel.textColourStyle = .Text
        
        let subtitleLabel = TKLabel()
        subtitleLabel.textStyle = .Body1
        subtitleLabel.textColourStyle = .Text
        
        let errorLabel = TKLabel()
        errorLabel.textStyle = .Caption
        errorLabel.textColourStyle = .Accent
        
        let errorImageView = TKImageView()
        errorImageView.tintColourStyle = .Accent
        errorImageView.contentMode = .ScaleAspectFit
        
        let iconImageView = TKImageView()
        iconImageView.contentMode = .ScaleAspectFit
        
        super.init(control: segmentedControl,
                   inputStack: inputStack,
                   titleLabel: titleLabel,
                   subtitleLabel: subtitleLabel,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
    }
    
}