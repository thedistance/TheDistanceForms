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
    
    case textSingle(TextFieldStack)
    case textMultiline(TextViewStack)
    case date(TextFieldStack, UIDatePickerDataController)
    case time(TextFieldStack, UIDatePickerDataController)
    case dateTime(TextFieldStack, UIDatePickerDataController)
    case choiceDropdown(TextFieldStack, UIPickerViewDataController)
    case choiceSegments(SegmentedTextFieldStack)
    // case ChoiceSelection // like a radio selection
    case boolean(SwitchStack)
    case button(UIButton)
    
    public var inputComponent:KeyboardResponderInputContainer? {
        switch self {
        case .textSingle(let tf):
            return tf
        case .textMultiline(let tv):
            return tv
        case .date(let tf, _):
            return tf
        case .time(let tf, _):
            return tf
        case .dateTime(let tf, _):
            return tf
        case .choiceDropdown(let tf, _):
            return tf
        case .choiceSegments(_), .boolean(_), .button(_):
            return nil
        }
    }
    
    public var view:UIView {
        switch self {
        case .textSingle(let tf):
            return tf.stackView
        case .textMultiline(let tv):
            return tv.stackView
        case .date(let tf, _):
            return tf.stackView
        case .time(let tf, _):
            return tf.stackView
        case .dateTime(let tf, _):
            return tf.stackView
        case .choiceDropdown(let tf, _):
            return tf.stackView
        case .choiceSegments(let segments):
            return segments.stackView
        // case ChoiceSelection // like a radio selection
        case .boolean(let switchControl):
            return switchControl.stackView
        case .button(let button):
            return button
        }
    }
    
    public func getValue() -> Any? {
        
        switch self {
        case .textSingle(let tf):
            return tf.getValue()
        case .textMultiline(let tv):
            return tv.getValue()
        case .date(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date
            } else {
                return nil
            }
            
        case .time(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date
            } else {
                return nil
            }
            
        case .dateTime(let tf, let controller):
            
            if tf.getValue() != nil {
                return controller.datePicker.date
            } else {
                return nil
            }
            
        case .choiceDropdown(let tf, _):
            return tf.getValue()
        case .choiceSegments(let segments):
            return segments.getValue()
        case .boolean(let switchControl):
            return switchControl.getValue()
        case .button(_):
            return nil
        }
    }

    public func setValue<T>(_ value: T?) -> Bool {
        
        switch self {
        case .textSingle(let tf):
            return tf.setValue(value)
        case .textMultiline(let tv):
            return tv.setValue(value)
        case .date(_, let controller):
            
            if let date = value as? Foundation.Date {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .time(_, let controller):
            
            if let date = value as? Foundation.Date {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .dateTime(_, let controller):
            
            if let date = value as? Foundation.Date {
                controller.datePicker.date = date
                controller.dateChanged(controller.datePicker)
                return true
            } else {
                return false
            }
            
        case .choiceDropdown(let tf, let controller):
            
            guard let string = value as? String  else { return false }
            
            var component:Int = 0
            for array in controller.choices {
                
                component += 1
                
                if let row = array.index(of: string) {
                    controller.pickerView.selectRow(row, inComponent: component, animated: true)
                    return tf.setValue(value)
                }
            }
            
            return false
            
        case .choiceSegments(let segments):
            
            guard let string = value as? String  else { return false }
            
            let n = segments.choiceControl.numberOfSegments
            for t in 0..<n {
                if segments.choiceControl.titleForSegment(at: t) == string {
                    _ = segments.setValue(t)
                    return true
                }
            }
            
            return false
            
        case .boolean(let switchControl):
            return switchControl.setValue(value)
        case .button(_):
            return false
        }
    }

    public func validateValue() -> ValidationResult {
        
        switch self {
        case .textSingle(let tf):
            
            return tf.validateValue()
            
        case .textMultiline(let tv):
            
            return tv.validateValue()
            
        case .date(let tf, _):
            
            return tf.validateValue()
            
        case .time(let tf, _):
            
            return tf.validateValue()
            
        case .dateTime(let tf, _):
            
            return tf.validateValue()
            
        case .choiceDropdown(let tf, _):
            
            return tf.validateValue()
            
        case .choiceSegments(let segments):
            
            return segments.validateValue()
            
        case .boolean(let switchControl):
            
            return switchControl.validateValue()
            
        case .button(_):
            return ValidationResult.valid
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
