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
public class TKFormQuestion: FormQuestion {
    
    /// - returns: A new `TKTextFieldStack`
    public override func newTextSingleView() -> TextFieldStack {
        return TKTextFieldStack()
    }
    
    /// - returns: A new `TKTextViewStack`
    public override func newTextMultilineView() -> TextViewStack {
        return TKTextViewStack()
    }
    
    /// - returns: A new `TKSegmentedTextFieldStack`
    public override func newSegmentChoiceViewWithChoices(choices: [String]) -> SegmentedTextFieldStack {
        return TKSegmentedTextFieldStack(items: choices)
    }
    
    /// - returns: A new `TKSwitchStack`
    public override func newSwitchView() -> SwitchStack {
        return TKSwitchStack()
    }
    
    /// - returns: A new `TKButton` with `.Accent` tint colour and `.Button` text style.
    public override func newButtonView() -> UIButton {
        
        let button = TKButton(type: .System)
        button.tintColourStyle = .Accent
        button.textStyle = .Button
        
        return button
    }
}