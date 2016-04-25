//
//  FormQuestion.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import StackView
import SwiftyJSON

public class FormQuestion {
    
    // MARK: Properties
    
    private(set) var questionView:FormQuestionView!
    
    public let key:String
    public let type:FormQuestionType
    public let definition:JSON
    
    // MARK: Initialisers
    
    public init?(json:JSON) {
        
        definition = json
        
        if let key = json["key"].string,
            let typeString = json["question_type"].string,
            let type = FormQuestionType(rawValue: typeString) {
            
            self.key = key
            self.type = type
            
            // create a blank one so the view can be created in a method not this initialiser
            questionView = .None
            
            let view:FormQuestionView?
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
            case .Boolean:
                view = switchViewForQuestion(json)
            case .Button:
                view = buttonViewForQuestion(json)
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
    
    // MARK: Convenience Methods
    
    public func checkQuestionDefinition(questionDefinition:JSON, isType:FormQuestionType) -> Bool {
        return checkQuestionDefinition(questionDefinition, isOneOfType: [isType])
    }
    
    public func checkQuestionDefinition(questionDefinition:JSON, isOneOfType:[FormQuestionType]) -> Bool {
        
        if let typeString = questionDefinition["question_type"].string,
            let type = FormQuestionType(rawValue: typeString) {
            return isOneOfType.contains(type)
        }
        
        return false
    }
    
    // MARK: Configured View Creation
    
    public func textSingleViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .TextSingle),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // Create the view
        let textElement = newTextSingleView()
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
            let validationValue = FormValueType(rawValue: validationTypeString) {
            
            switch validationValue {
            case .String:
                textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
            default:
                break
            }
        }
        
        return .TextSingle(textElement)
    }
    
    public func textMultiViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .TextSingle),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // create the view
        let textElement = newTextMultilineView()
        textElement.placeholderText = prompt
        
        // UITextInputTraits
        if let kbTypeString = questionDefinition["keyboardType"].string,
            let kbType = KeyboardType(rawValue: kbTypeString) {
            textElement.textView.keyboardType = kbType.uiKeyboardType
        }
        
        if let capitalString = questionDefinition["capitalization"].string,
            let capital = CapitalizationType(rawValue: capitalString) {
            textElement.textView.autocapitalizationType = capital.uiAutoCapitalizationType
        }
        
        if let autoCorrect = questionDefinition["auto_correct"].bool {
            textElement.textView.autocorrectionType = autoCorrect ? .Yes : .No
        }
        
        if let secure = questionDefinition["secure_text_entry"].bool {
            textElement.textView.secureTextEntry = secure
        }
        
        // Validation
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationTypeString)
            where validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return .TextMultiline(textElement)
    }
    
    public func dateTimeViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard let typeString = questionDefinition["question_type"].string,
            let type = FormQuestionType(rawValue: typeString)
            where [.Date, .Time, .DateTime].contains(type),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // Create the view
        let textElement = newTextSingleView()
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
        } else {
            dateController.dateFormatter.dateStyle = .NoStyle
        }
        
        if type == .Time || type == .DateTime,
            let timeFormatString = questionDefinition["time_format_style"].string,
            let timeFormat = DateTimeFormatStyle(rawValue: timeFormatString) {
            
            dateController.dateFormatter.timeStyle = timeFormat.dateFormatStyle
        } else {
            dateController.dateFormatter.timeStyle = .NoStyle
        }
        
        if let interval = questionDefinition["miniute_interval"].int {
            dateController.datePicker.minuteInterval = interval
        }
        
        // validation
        
        if let typeString = questionDefinition["question_type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = questionDefinition["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = questionDefinition["question_type"].string
            where valueType == .Date &&
                type == .NotEmpty {
            
            textElement.validation = NonEmptyStringValidation(message)
        }
        
        switch type {
        case .Date:
            return .Date(textElement, dateController)
        case .DateTime:
            return .DateTime(textElement, dateController)
        case .Time:
            return .Time(textElement, dateController)
        default:
            return nil
        }
    }
    
    public func dropdownViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .ChoiceDropdown),
            let prompt = questionDefinition["prompt"].string,
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string })
            where choices.count > 0
            else { return nil }
        
        // Create the view
        let textElement = newTextSingleView()
        textElement.placeholderText = prompt
        
        // Create the picker
        let pickerView = UIPickerView()
        let controller = UIPickerViewDataController(choices: [choices], pickerView: pickerView, textField: textElement.textField)
        textElement.pickerController = controller
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationTypeString)
            where validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return .ChoiceDropdown(textElement, controller)
    }
    
    public func segmentViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .ChoiceSegments),
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string })
            where choices.count > 0
            else { return nil }
        
        let segmentElement = newSegmentChoiceViewWithChoices(choices)
        
        
        segmentElement.titleLabel.text = questionDefinition["title"].string
        segmentElement.titleLabel.hidden = segmentElement.titleLabel.text?.isEmpty ?? true
        
        segmentElement.subtitleLabel.text = questionDefinition["subtitle"].string
        segmentElement.subtitleLabel.hidden = segmentElement.subtitleLabel.text?.isEmpty ?? true
        
        if let validationValueTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationValueTypeString)
            where validationValue == .Number {
            
            segmentElement.validation = numberValidationForDefinition(questionDefinition["validation"])
        }
        
        return .ChoiceSegments(segmentElement)
    }
    
    public func switchViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .Boolean)
            else { return nil }
        
        let switchElement = newSwitchView()
        
        switchElement.titleLabel.text = questionDefinition["title"].string
        switchElement.titleLabel.hidden = switchElement.titleLabel.text?.isEmpty ?? true
        
        switchElement.subtitleLabel.text = questionDefinition["subtitle"].string
        switchElement.subtitleLabel.hidden = switchElement.subtitleLabel.text?.isEmpty ?? true
        
        if let defaultValue = questionDefinition["default"].bool {
            switchElement.switchControl.on = defaultValue
        }
        
        
        return .Boolean(switchElement)
    }
    
    public func buttonViewForQuestion(questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .Button),
            let title = questionDefinition["title"].string
            else { return nil }
        
        let button = newButtonView()
        button.setTitle(title, forState: .Normal)
        
        return .Button(button)
    }
    
    // MARK: Validation Creation
    
    public func stringValidationForDefinition(definition:JSON?) -> Validation<String>? {
        
        guard let typeString = definition?["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = definition?["message"].string
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
        
        guard let typeString = definition?["question_type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = definition?["question_type"].string
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
    
    
    // MARK: View Creation
    
    /**
     
     Creates a view to display single line text configured with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in the following `FormQuestionType`s:
     
     - `.TextSingle`
     - `.Date`, `.DateTime`, `.Time`
     - `.ChoiceDropdown`
     
      - seealso: `textSingleViewForQuestion(_:)`
      - seealso: `dateTimeViewForQuestion(_:)`
      - seealso: `dropdownViewForQuestion(_:)`
     
     - returns: A newly initialised `TextFieldStack`.
     */
    public func newTextSingleView() -> TextFieldStack {
        
        let textStack = TextFieldStack()
        
        textStack.placeholderLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        textStack.errorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        textStack.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        return textStack
    }
    
    /**
     
     Creates a view to display multiple lines of text configured with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.TextMultiline FormQuestionType`s.
     
     - seealso: `textMultiViewForQuestion(_:)`
     
     - returns: A newly initialised `TextViewStack`.

     */
    public func newTextMultilineView() -> TextViewStack {
        
        let textStack = TextViewStack()
        
        textStack.placeholderLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        textStack.errorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        textStack.textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        return textStack
    }
    
    /**
     
     Creates a view to display segmented choices with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.ChoiceSegments FormQuestionType`s.
     
     - seealso: `segmentViewForQuestion(_:)`
     
     - returns: A newly initialised `SegmentedTextFieldStack`.
     
    */
    public func newSegmentChoiceViewWithChoices(choices:[String]) -> SegmentedTextFieldStack {
        
        let segments = UISegmentedControl(items: choices)
        let input = newTextSingleView()
        let segmentElement = SegmentedTextFieldStack(control: segments, inputStack: input)
        segmentElement.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        segmentElement.subtitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        return segmentElement
    }
    
    /**
     
     Creates a view to display segmented choices with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.ChoiceSegments FormQuestionType`s.
     
     - returns: A newly initialised `SegmentedTextFieldStack`.
     
     */
    public func newSwitchView() -> SwitchStack {
        
        let switchStack = SwitchStack(switchControl: UISwitch())
        switchStack.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        switchStack.subtitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        return switchStack
    }
    
    /**
     
     Creates a view to display buttons with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.Button FormQuestionType`s.
     
     - returns: A newly initialised `UIButton` with `.System` type.
     
     */
    public func newButtonView() -> UIButton {
        
        let button = UIButton(type: .System)
        button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        return button
    }
    
}
