//
//  DynamicFormView.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 21/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation
import SwiftyJSON
import StackView

public class FormQuestion {
    
    private(set) var questionView:CreatedStack
    
    let key:String
    
    let definition:JSON
    
    init?(json:JSON) {
        
        definition = json
        
        if let key = json["key"].string,
            let typeString = json["type"].string,
            let type = FormType(rawValue: typeString) {
            
            self.key = key
            
            // create a blank one so the view can be created in a method not this initialiser
            questionView = CreatedStack(arrangedSubviews: [])
            
            let view:CreatedStack?
            switch type {
            case .TextSingle:
                view = textSingleViewForQuestion(json)
            case .TextMultiline:
                view = textMultiViewForQuestion(json)
            case .Date, .DateTime, .Time:
                view = dateTimeViewForQuestion(json)
            case .ChoiceDropdown:
                view = dropdownViewForQuestion(json)
            case .ChoiceSegments:
                view = segmentViewForQuestion(json)
            case .Switch:
                view = switchViewForQuestion(json)
            default:
                view = nil
            }
            
            if let v = view {
                questionView = v
            } else {
                return nil
            }
            
        } else {
            return nil
        }

        
    }
    
    public func checkQuestionDefinition(questionDefinition:JSON, isType:FormType) -> Bool {
        return checkQuestionDefinition(questionDefinition, isOneOfType: [isType])
    }
    
    public func checkQuestionDefinition(questionDefinition:JSON, isOneOfType:[FormType]) -> Bool {
        
        if let typeString = questionDefinition["type"].string,
            let type = FormType(rawValue: typeString) {
            return isOneOfType.contains(type)
        }
        
        return false
    }
    
    public func textSingleViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .TextSingle),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // Create the view
        let textElement = TextFieldStack()
        textElement.placeholderText = prompt
        
        // UITextInputTraits
        if let kbTypeString = questionDefinition["keyboardType"].string,
            let kbType = KeyboardType(rawValue: kbTypeString) {
            textElement.textField.keyboardType = kbType.uiKeyboardType
        }
        
        if let capitalString = questionDefinition["capitalization"].string,
            let capital = CapitalizationType(rawValue: capitalString) {
            textElement.textField.autocapitalizationType = capital.uiAutoCapitalizationType
        }
        
        if let autoCorrect = questionDefinition["auto_correct"].bool {
            textElement.textField.autocorrectionType = autoCorrect ? .Yes : .No
        }
        
        if let secure = questionDefinition["secure_text_entry"].bool {
            textElement.textField.secureTextEntry = secure
        }
        
        // Validation
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = ValidationValueType(rawValue: validationTypeString) {
            
            switch validationValue {
            case .String:
                textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
            default:
                break
            }
        }
        
        return textElement
    }
    
    public func textMultiViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .TextSingle),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // create the view
        let textElement = TextFieldStack()
        textElement.placeholderText = prompt
        
        // UITextInputTraits
        if let kbTypeString = questionDefinition["keyboardType"].string,
            let kbType = KeyboardType(rawValue: kbTypeString) {
            textElement.textField.keyboardType = kbType.uiKeyboardType
        }
        
        if let capitalString = questionDefinition["capitalization"].string,
            let capital = CapitalizationType(rawValue: capitalString) {
            textElement.textField.autocapitalizationType = capital.uiAutoCapitalizationType
        }
        
        if let autoCorrect = questionDefinition["auto_correct"].bool {
            textElement.textField.autocorrectionType = autoCorrect ? .Yes : .No
        }
        
        if let secure = questionDefinition["secure_text_entry"].bool {
            textElement.textField.secureTextEntry = secure
        }
        
        // Validation
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = ValidationValueType(rawValue: validationTypeString)
            where validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return textElement
    }
    
    public func dateTimeViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard let typeString = questionDefinition["type"].string,
            let type = FormType(rawValue: typeString)
            where [.Date, .Time, .DateTime].contains(type),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // Create the view
        let textElement = TextFieldStack()
        textElement.placeholderText = prompt
        
        // Create the picker
        let datePicker = UIDatePicker()
        let dateController = UIDatePickerDataController(datePicker: datePicker, textField: textElement.textField)
        textElement.dateController = dateController
        
        // picker mode
        switch type {
        case .Date:
            datePicker.datePickerMode = .Date
        case .DateTime:
            datePicker.datePickerMode = .DateAndTime
        case .Time:
            datePicker.datePickerMode = .Time
        default:
            break
        }
        
        // format style
        if type == .Date || type == .DateTime,
            let dateFormatString = questionDefinition["date_format_style"].string,
            let dateFormat = DateTimeFormatStyle(rawValue: dateFormatString) {
            
            dateController.dateFormatter.dateStyle = dateFormat.dateFormatStyle
        }
        
        if type == .Time || type == .DateTime,
            let timeFormatString = questionDefinition["time_format_style"].string,
            let timeFormat = DateTimeFormatStyle(rawValue: timeFormatString) {
            
            dateController.dateFormatter.timeStyle = timeFormat.dateFormatStyle
        }
        
        // validation
        
        if let typeString = questionDefinition["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = questionDefinition["value_type"].string,
            let valueType = ValidationValueType(rawValue: valueTypeString),
            let message = questionDefinition["type"].string
            where valueType == .Date &&
                type == .NotEmpty {
            
            textElement.validation = NonEmptyStringValidation(message)
        }
        
        return textElement
    }
    
    public func dropdownViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .ChoiceDropdown),
            let prompt = questionDefinition["prompt"].string,
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string })
            where choices.count > 0
            else { return nil }
        
        // Create the view
        let textElement = TextFieldStack()
        textElement.placeholderText = prompt
        
        // Create the picker
        let pickerView = UIPickerView()
        let controller = UIPickerViewDataController(choices: [choices], pickerView: pickerView, textField: textElement.textField)
        textElement.pickerController = controller
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = ValidationValueType(rawValue: validationTypeString)
            where validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return textElement
    }
    
    public func segmentViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .ChoiceDropdown),
            let prompt = questionDefinition["prompt"].string,
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string })
            where choices.count > 0
            else { return nil }

        let segments = UISegmentedControl(items: choices)
        
        let segmentElement = SegmentedTextFieldStack(control: segments, inputStack: TextFieldStack())
        
        segmentElement.titleLabel.text = prompt
        
        if let validationValueTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = ValidationValueType(rawValue: validationValueTypeString)
            where validationValue == .Number {
            
            segmentElement.validation = numberValidationForDefinition(questionDefinition["validation"])
        }
        
        return segmentElement
    }
    
    public func switchViewForQuestion(questionDefinition:JSON) -> CreatedStack? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .ChoiceDropdown),
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string })
            where choices.count > 0
            else { return nil }
        
        let switchElement = SwitchStack(switchControl: UISwitch())
        
        switchElement.titleLabel.text = questionDefinition["title"].string
        switchElement.titleLabel.hidden = switchElement.titleLabel.text?.isEmpty ?? true
        
        switchElement.subtitleLabel.text = questionDefinition["subtitle"].string
        switchElement.subtitleLabel.hidden = switchElement.subtitleLabel.text?.isEmpty ?? true
        
        if let defaultValue = questionDefinition["default"].bool {
            switchElement.switchControl.on = defaultValue
        }

        
        return switchElement
    }
    
    public func stringValidationForDefinition(definition:JSON?) -> Validation<String>? {
        
        guard let typeString = definition?["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = ValidationValueType(rawValue: valueTypeString),
            let message = definition?["type"].string
            where valueType == .String
            else { return nil }
        
        
        switch type {
        case .NotEmpty:
            return NonEmptyStringValidation(message)
        case .Email:
            return EmailValidationWithMessage(message)
        case .Number:
            return NumberValidationWithMessage(message)
        case .Postcode:
            return UKPostcodeValidationWithMessage(message)
        case .Regex:
            if let reg = definition?["regex"].string {
                return RegexValidationWithMessage(message, regex: reg)
            } else {
                return nil
            }
        }
    }

    public func numberValidationForDefinition(definition:JSON?) -> Validation<Int>? {
        
        guard let typeString = definition?["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = ValidationValueType(rawValue: valueTypeString),
            let message = definition?["type"].string
            where valueType == .Number
            else { return nil }
        
        
        switch type {
        case .NotEmpty:
            return Validation(message: message, validation: { (value) -> Bool in
                value != nil
            })
        default:
            return nil
        }
    }

}

public class Form {
    
    let title:String?
    
    
    private (set) var formView:StackView
    
    init(definition:JSON) {
        
        title = definition["title"].string
        
        guard let questionDefinitions = definition.array else {
            formView = CreateStackView([])
            return
        }
        
        // initialise as empty so can call other methods from this initialiser
        formView = CreateStackView([])
        
        let views = questionDefinitions.flatMap { FormQuestion(json: $0) }
        
        
        formView = CreateStackView(views.map { $0.questionView.stackView })
        formView.axis = .Vertical
        formView.spacing = 8.0
    }
    
}

public enum FormType:String {
    
    case TextSingle
    case TextMultiline
    case Date
    case Time
    case DateTime
    case ChoiceDropdown // choose from a Picker View
    case ChoiceSegments
    case ChoiceSelection // like a radio selection
    case Switch
    case Button
}

public enum ValidationType:String {
    
    case NotEmpty
    case Email
    case Number
    case Postcode
    case Regex
    
}

public enum ValidationValueType:String {
    
    case String
    case Date
    case Bool
    case Number
    
}

public enum KeyboardType:String {
    
    case Default // Default type for the current input method.
    case ASCIICapable // Displays a keyboard which can enter ASCII characters, non-ASCII keyboards remain active
    case NumbersAndPunctuation // Numbers and assorted punctuation.
    case URL // A type optimized for URL entry (shows . / .com prominently).
    case NumberPad // A number pad (0-9). Suitable for PIN entry.
    case PhonePad // A phone pad (1-9, *, 0, #, with letters under the numbers).
    case NamePhonePad // A type optimized for entering a person's name or phone number.
    case EmailAddress // A type optimized for multiple email address entry (shows space @ . prominently).
    case DecimalPad // A number pad with a decimal point.
    case Twitter // A type optimized for twitter text entry (easy access to @ #)
    case WebSearch // A default keyboard type with URL-oriented addition (shows space . prominently).
    
    /// The `UIKeyboardType` equivalent for this enum.
    var uiKeyboardType:UIKeyboardType {
        switch self {
        case .Default:
            return .Default
        case .ASCIICapable:
            return .ASCIICapable
        case .NumbersAndPunctuation:
            return .NumbersAndPunctuation
        case .URL:
            return .URL
        case .NumberPad:
            return .NumberPad
        case .PhonePad:
            return .PhonePad
        case .NamePhonePad:
            return .NamePhonePad
        case .EmailAddress:
            return .EmailAddress
        case .DecimalPad:
            return .DecimalPad
        case .Twitter:
            return .Twitter
        case .WebSearch:
            return .WebSearch
        }
    }
}

public enum CapitalizationType : String {
    
    case None
    case Words
    case Sentences
    case AllCharacters
    
    var uiAutoCapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .None:
            return .None
        case .Words:
            return .Words
        case .Sentences:
            return .Sentences
        case .AllCharacters:
            return .AllCharacters
        }
    }
}

public enum DateTimeFormatStyle: String {
    
    case Short
    case Medium
    case Long
    case Full
    
    var dateFormatStyle: NSDateFormatterStyle {
        switch self {
        case .Short:
            return .ShortStyle
        case .Medium:
            return .MediumStyle
        case .Long:
            return .LongStyle
        case .Full:
            return .FullStyle
        }
    }
}
