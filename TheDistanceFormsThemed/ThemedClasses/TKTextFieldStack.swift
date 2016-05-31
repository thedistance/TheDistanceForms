//
//  TKTextFieldStack.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import ThemeKitCore

/**
 
 `TextFieldStack` whose views are ThemeKit equivalents.
 
 - `textField` is a `TKTextField` configured as `.Body1` font and placeholder font, `.Text` text colour, and `.SecondaryText` placeholder text colour.
 - `placeholderLabel` is a `TKLabel` with `.Caption` font and `.SecondaryText` colour.
 - `errorLabel` is a `TKLabel` with `.Caption` font and `.Accent` colour.
 - `errorImageView` is a `TKImageView` with `.Accent` tint colour and `.ScaleAspectFit` contentMode.
 - `iconImageView` is a `TKImageView` with no tint colour and `.ScaleAspectFit` contentMode.
 - `underline` is a `TKView` which is `.Accent` alpha 1.0 when `textField.isFirstResponder` is `true`, `.SecondaryText` when `textField.isFirstResponder` is `false` but `textField.enabled`, and invisible when `textField.enabled` is `false`.
 
*/
public class TKTextFieldStack: TextFieldStack {
    
    /// Default initialiser. Creates and styles the components.
    init() {
        
        let textField = TKTextField()
        textField.textStyle = .Body1
        textField.placeholderTextStyle = .Body1
        
        textField.textColourStyle = .Text
        textField.placeholderTextColourStyle = .SecondaryText
        
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
        
        super.init(textField: textField,
                   placeholderLabel: placeholder,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView,
                   underline: underline)
    }
    
    /// Configures the `underline` to be `.Accent` when the view is active and `hidden`
    public override func configureUnderline() {
        
        guard let underline = self.underline as? TKView else { return }
        
        if textField.isFirstResponder() {
            underline.backgroundColourStyle = .Accent
            underline.alpha = 1.0
        } else {
            underline.backgroundColourStyle = .SecondaryText
            underline.alpha = enabled ? 1.0 : 0.0
        }
    }
}