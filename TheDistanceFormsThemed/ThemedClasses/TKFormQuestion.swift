//
//  TKFormQuestion.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import ThemeKitCore
import SwiftyJSON

/// FormQuestion subclass that returns ThemeKit views.
open class TKFormQuestion: FormQuestion {
    
    /// - returns: A new `TKTextFieldStack`
    open override func newTextSingleView() -> TextFieldStack {
        return TKTextFieldStack()
    }
    
    /// - returns: A new `TKTextViewStack`
    open override func newTextMultilineView() -> TextViewStack {
        return TKTextViewStack()
    }
    
    /// - returns: A new `TKSegmentedTextFieldStack`
    open override func newSegmentChoiceViewWithChoices(_ choices: [String]) -> SegmentedTextFieldStack {
        return TKSegmentedTextFieldStack(items: choices as [AnyObject]?)
    }
    
    /// - returns: A new `TKSwitchStack`
    open override func newSwitchView() -> SwitchStack {
        return TKSwitchStack()
    }
    
    /// - returns: A new `TKButton` with `.Accent` tint colour and `.Button` text style.
    open override func newButtonView() -> UIButton {
        
        let button = TKButton(type: .system)
        button.tintColourStyle = .accent
        button.textStyle = .button
        
        return button
    }
}
