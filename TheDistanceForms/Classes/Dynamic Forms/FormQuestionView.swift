//
//  FormQuestionView.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import KeyboardResponder

public enum FormQuestionView: ValueElement {
    
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
    
    public var inputComponent:KeyboardResponderInputContainer? {
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
    
    public var view:UIView {
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
    
    public func getValue() -> Any? {
        
        switch self {
        case .TextSingle(let tf):
            return tf.getValue()
        case .TextMultiline(let tv):
            return tv.getValue()
        case .Date(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date.description
            } else {
                return nil
            }
            
        case .Time(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date.description
            } else {
                return nil
            }
            
        case .DateTime(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date.description
            } else {
                return nil
            }
            
        case .ChoiceDropdown(let tf, _):
            return tf.getValue()
        case .ChoiceSegments(let segments):
            return segments.getValue()
        case .Boolean(let switchControl):
            return switchControl.getValue()
        case .Button(_):
            return nil
        }
    }

    public func setValue<T>(value: T?) -> Bool {
        
        switch self {
        case .TextSingle(let tf):
            return tf.setValue(value)
        case .TextMultiline(let tv):
            return tv.setValue(value)
        case .Date(_, let controller):
            
            if let date = value as? NSDate {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .Time(_, let controller):
            
            if let date = value as? NSDate {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .DateTime(_, let controller):
            
            if let date = value as? NSDate {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .ChoiceDropdown(let tf, let controller):
            
            guard let string = value as? String  else { return false }
            
            var component:Int = 0
            for array in controller.choices {
                
                component += 1
                
                if let row = array.indexOf(string) {
                    controller.pickerView.selectRow(row, inComponent: component, animated: true)
                    return tf.setValue(value)
                }
            }
            
            return false
            
        case .ChoiceSegments(let segments):
            
            guard let string = value as? String  else { return false }
            
            let n = segments.choiceControl.numberOfSegments
            for t in 0..<n {
                if segments.choiceControl.titleForSegmentAtIndex(t) == string {
                    segments.setValue(t)
                    return true
                }
            }
            
            return false
            
        case .Boolean(let switchControl):
            return switchControl.setValue(value)
        case .Button(_):
            return false
        }
    }

    public func validateValue() -> ValidationResult {
        
        switch self {
        case .TextSingle(let tf):
            
            return tf.validateValue()
            
        case .TextMultiline(let tv):
            
            return tv.validateValue()
            
        case .Date(let tf, _):
            
            return tf.validateValue()
            
        case .Time(let tf, _):
            
            return tf.validateValue()
            
        case .DateTime(let tf, _):
            
            return tf.validateValue()
            
        case .ChoiceDropdown(let tf, _):
            
            return tf.validateValue()
            
        case .ChoiceSegments(let segments):
            
            return segments.validateValue()
            
        case .Boolean(let switchControl):
            
            return switchControl.validateValue()
            
        case .Button(_):
            return ValidationResult.Valid
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