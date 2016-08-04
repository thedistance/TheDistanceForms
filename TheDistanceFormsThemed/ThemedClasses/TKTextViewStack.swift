//
//  TKTextViewStack.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import ThemeKitCore

/**
 
 `TextViewStack` whose views are ThemeKit equivalents.
 
 - `textView` is a `TKTextView` configured as `.Body1`, `.Text` text colour, and `.SecondaryText` placeholder text colour.
 - `placeholderLabel` is a `TKLabel` with `.Caption` font and `.SecondaryText` colour.
 - `errorLabel` is a `TKLabel` with `.Caption` font and `.Accent` colour.
 - `errorImageView` is a `TKImageView` with `.Accent` tint colour and `.ScaleAspectFit` contentMode.
 - `iconImageView` is a `TKImageView` with no tint colour and `.ScaleAspectFit` contentMode.
 - `underline` is a `TKView` which is `.Accent` alpha 1.0 when `textView.isFirstResponder` is `true`, `.SecondaryText` when `textView.isFirstResponder` is `false` but `textView.enabled`, and invisible when `textView.enabled` is `false`.
 
 */
public class TKTextViewStack: TextViewStack {
    
    /// Default initialiser. Creates and styles the components.
    init() {
        
        let textView = TKTextView()
        textView.textStyle = .Body1
        textView.textColourStyle = .Text
        
        let placeholder = TKLabel()
        placeholder.textStyle = .Caption
        placeholder.textColourStyle = .SecondaryText
        
        let errorLabel = TKLabel()
        errorLabel.textStyle = .Caption
        errorLabel.textColourStyle = .Accent
        
        let errorImageView = TKImageView()
        errorImageView.tintColourStyle = .Accent
        errorImageView.contentMode = .ScaleAspectFit
        
        let iconImageView = TKImageView()
        iconImageView.contentMode = .ScaleAspectFit
        
        let underline = TKView()
        
        super.init(textView: textView,
                   placeholderLabel: placeholder,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView,
                   underline: underline)
        
        placeholderTextColour = TKThemeVendor.defaultColour(.SecondaryText)
    }
    
    /// Configures the `underline` to be `.Accent` when the view is active and `hidden`
    public override func configureUnderline() {
        
        guard let underline = self.underline as? TKView else { return }
        
        if textView.isFirstResponder() {
            underline.backgroundColourStyle = .Accent
            underline.alpha = 1.0
        } else {
            underline.backgroundColourStyle = .SecondaryText
            underline.alpha = enabled ? 1.0 : 0.0
        }
    }
}