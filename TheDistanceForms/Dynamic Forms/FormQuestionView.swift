//
//  FormQuestionView.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import KeyboardResponder

public enum FormQuestionView {
    
    
    
    case TextSingle(TextFieldStack)
    case TextMultiline(TextViewStack)
    case Date(TextFieldStack, UIDatePickerDataController)
    case Time(TextFieldStack, UIDatePickerDataController)
    case DateTime(TextFieldStack, UIDatePickerDataController)
    case ChoiceDropdown(TextFieldStack, UIPickerViewDataController)
    case ChoiceSegments(SegmentedTextFieldStack)
    // case ChoiceSelection // like a radio selection
    case Boolean(SwitchStack)
    case Button(UIButton)
    
    var inputComponent:KeyboardResponderInputContainer? {
        switch self {
        case .TextSingle(let tf):
            return tf
        case .TextMultiline(let tv):
            return tv
        case .Date(let tf, _):
            return tf
        case .Time(let tf, _):
            return tf
        case .DateTime(let tf, _):
            return tf
        case .ChoiceDropdown(let tf, _):
            return tf
        case .ChoiceSegments(_), .Boolean(_), .Button(_):
            return nil
        }
    }
    
    var view:UIView {
        switch self {
        case .TextSingle(let tf):
            return tf.stackView
        case .TextMultiline(let tv):
            return tv.stackView
        case .Date(let tf, _):
            return tf.stackView
        case .Time(let tf, _):
            return tf.stackView
        case .DateTime(let tf, _):
            return tf.stackView
        case .ChoiceDropdown(let tf, _):
            return tf.stackView
        case .ChoiceSegments(let segments):
            return segments.stackView
        // case ChoiceSelection // like a radio selection
        case .Boolean(let switchControl):
            return switchControl.stackView
        case .Button(let button):
            return button
        }
    }
    
    /*
    var questionType:FormQuestionType {
        switch self {
        case .TextSingle(_):
            return .TextSingle
        case .TextMultiline(_):
            return .TextMultiline
        case .Date(_, _):
            return .Date
        case .Time(_, _):
            return .Time
        case .DateTime(_, _):
            return .DateTime
        case .ChoiceDropdown(_, _):
            return .ChoiceDropdown
        case .ChoiceSegments(_):
            return .ChoiceSegments
        // case ChoiceSelection // like a radio selection
        case Boolean(_):
            return .Boolean
        case Button(_):
            return .Button
        }

    }
 */
}