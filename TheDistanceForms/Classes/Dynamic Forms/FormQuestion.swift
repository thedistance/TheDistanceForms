//
//  FormQuestion.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TDStackView
import SwiftyJSON

open class FormQuestion {
    
    // MARK: Properties
    
    fileprivate(set) open var questionView:FormQuestionView!
    
    open let key:String
    open let type:FormQuestionType
    open let definition:JSON
    
    // MARK: Initialisers
    
    required public init?(json:JSON) {
        
        definition = json
        
        if let key = json["key"].string,
            let typeString = json["question_type"].string,
            let type = FormQuestionType(rawValue: typeString) {
            
            self.key = key
            self.type = type
            
            // create a blank one so the view can be created in a method not this initialiser
            questionView = .none
            
            let view:FormQuestionView?
            switch type {
            case .textSingle:
                view = textSingleViewForQuestion(json)
            case .textMultiline:
                view = textMultiViewForQuestion(json)
            case .date, .dateTime, .time:
                view = dateTimeViewForQuestion(json)
            case .choiceDropdown:
                view = dropdownViewForQuestion(json)
            case .choiceSegments:
                view = segmentViewForQuestion(json)
            case .boolean:
                view = switchViewForQuestion(json)
            case .button:
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
    
    open func checkQuestionDefinition(_ questionDefinition:JSON, isType:FormQuestionType) -> Bool {
        return checkQuestionDefinition(questionDefinition, isOneOfType: [isType])
    }
    
    open func checkQuestionDefinition(_ questionDefinition:JSON, isOneOfType:[FormQuestionType]) -> Bool {
        
        if let typeString = questionDefinition["question_type"].string,
            let type = FormQuestionType(rawValue: typeString) {
            return isOneOfType.contains(type)
        }
        
        return false
    }
    
    // MARK: Configured View Creation
    
    open func textSingleViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .textSingle),
            let prompt = questionDefinition["prompt"].string else { return nil }
        
        // Create the view
        let textElement = newTextSingleView()
        textElement.placeholderText = prompt
        
        // UITextInputTraits
        if let kbTypeString = questionDefinition["keyboard_type"].string,
            let kbType = KeyboardType(rawValue: kbTypeString) {
            textElement.textField.keyboardType = kbType.uiKeyboardType
        }
        
        if let capitalString = questionDefinition["capitalization"].string,
            let capital = CapitalizationType(rawValue: capitalString) {
            textElement.textField.autocapitalizationType = capital.uiAutoCapitalizationType
        }
        
        if let autoCorrect = questionDefinition["auto_correct"].bool {
            textElement.textField.autocorrectionType = autoCorrect ? .yes : .no
        }
        
        if let secure = questionDefinition["secure_text_entry"].bool {
            
            textElement.textField.isSecureTextEntry = secure
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
        
        return .textSingle(textElement)
    }
    
    open func textMultiViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .textMultiline),
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
            textElement.textView.autocorrectionType = autoCorrect ? .yes : .no
        }
        
        if let secure = questionDefinition["secure_text_entry"].bool {
            textElement.textView.isSecureTextEntry = secure
        }
        
        // Validation
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationTypeString), validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return .textMultiline(textElement)
    }
    
    open func dateTimeViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard let typeString = questionDefinition["question_type"].string,
            let type = FormQuestionType(rawValue: typeString), [.date, .time, .dateTime].contains(type),
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
        case .date:
            datePicker.datePickerMode = .date
        case .dateTime:
            datePicker.datePickerMode = .dateAndTime
        case .time:
            datePicker.datePickerMode = .time
        default:
            break
        }
        
        // format style
        if type == .date || type == .dateTime,
            let dateFormatString = questionDefinition["date_format_style"].string,
            let dateFormat = DateTimeFormatStyle(rawValue: dateFormatString) {
            
            dateController.dateFormatter.dateStyle = dateFormat.dateFormatStyle
        } else {
            dateController.dateFormatter.dateStyle = .none
        }
        
        if type == .time || type == .dateTime,
            let timeFormatString = questionDefinition["time_format_style"].string,
            let timeFormat = DateTimeFormatStyle(rawValue: timeFormatString) {
            
            dateController.dateFormatter.timeStyle = timeFormat.dateFormatStyle
        } else {
            dateController.dateFormatter.timeStyle = .none
        }
        
        if let interval = questionDefinition["minute_interval"].int {
            dateController.datePicker.minuteInterval = interval
        }
        
        // validation
        
        if let typeString = questionDefinition["question_type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = questionDefinition["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = questionDefinition["question_type"].string, valueType == .Date &&
                type == .NotEmpty {
            
            textElement.validation = NonEmptyStringValidation(message)
        }
        
        switch type {
        case .date:
            return .date(textElement, dateController)
        case .dateTime:
            return .dateTime(textElement, dateController)
        case .time:
            return .time(textElement, dateController)
        default:
            return nil
        }
    }
    
    open func dropdownViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .choiceDropdown),
            let prompt = questionDefinition["prompt"].string,
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string }), choices.count > 0
            else { return nil }
        
        // Create the view
        let textElement = newTextSingleView()
        textElement.placeholderText = prompt
        
        // Create the picker
        let pickerView = UIPickerView()
        let controller = UIPickerViewDataController(choices: [choices], pickerView: pickerView, textField: textElement.textField)
        textElement.pickerController = controller
        
        if let validationTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationTypeString), validationValue == .String {
            
            textElement.validation = stringValidationForDefinition(questionDefinition["validation"])
        }
        
        return .choiceDropdown(textElement, controller)
    }
    
    open func segmentViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .choiceSegments),
            let choices = questionDefinition["choices"].array?.flatMap({ $0.string }), choices.count > 0
            else { return nil }
        
        let segmentElement = newSegmentChoiceViewWithChoices(choices)
        
        
        segmentElement.titleLabel.text = questionDefinition["title"].string
        segmentElement.titleLabel.isHidden = segmentElement.titleLabel.text?.isEmpty ?? true
        
        segmentElement.subtitleLabel.text = questionDefinition["subtitle"].string
        segmentElement.subtitleLabel.isHidden = segmentElement.subtitleLabel.text?.isEmpty ?? true
        
        if let validationValueTypeString = questionDefinition["validation", "value_type"].string,
            let validationValue = FormValueType(rawValue: validationValueTypeString), validationValue == .Number {
            
            segmentElement.validation = numberValidationForDefinition(questionDefinition["validation"])
        }
        
        return .choiceSegments(segmentElement)
    }
    
    open func switchViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .boolean)
            else { return nil }
        
        let switchElement = newSwitchView()
        
        switchElement.titleLabel.text = questionDefinition["title"].string
        switchElement.titleLabel.isHidden = switchElement.titleLabel.text?.isEmpty ?? true
        
        switchElement.subtitleLabel.text = questionDefinition["subtitle"].string
        switchElement.subtitleLabel.isHidden = switchElement.subtitleLabel.text?.isEmpty ?? true
        
        if let defaultValue = questionDefinition["default"].bool {
            switchElement.switchControl.isOn = defaultValue
        }
        
        
        return .boolean(switchElement)
    }
    
    open func buttonViewForQuestion(_ questionDefinition:JSON) -> FormQuestionView? {
        
        guard checkQuestionDefinition(questionDefinition, isType: .button),
            let title = questionDefinition["title"].string
            else { return nil }
        
        let button = newButtonView()
        button.setTitle(title, for: .normal)
        
        return .button(button)
    }
    
    // MARK: Validation Creation
    
    open func stringValidationForDefinition(_ definition:JSON?) -> Validation<String>? {
        
        guard let typeString = definition?["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = definition?["message"].string, valueType == .String
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
    
    open func numberValidationForDefinition(_ definition:JSON?) -> Validation<Int>? {
        
        guard let typeString = definition?["type"].string,
            let type = ValidationType(rawValue: typeString),
            let valueTypeString = definition?["value_type"].string,
            let valueType = FormValueType(rawValue: valueTypeString),
            let message = definition?["question_type"].string, valueType == .Number
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
    open func newTextSingleView() -> TextFieldStack {
        
        let textStack = TextFieldStack()
        
        textStack.placeholderLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        textStack.errorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        textStack.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        return textStack
    }
    
    /**
     
     Creates a view to display multiple lines of text configured with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.TextMultiline FormQuestionType`s.
     
     - seealso: `textMultiViewForQuestion(_:)`
     
     - returns: A newly initialised `TextViewStack`.

     */
    open func newTextMultilineView() -> TextViewStack {
        
        let textStack = TextViewStack()
        
        textStack.placeholderLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        textStack.errorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        textStack.textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        return textStack
    }
    
    /**
     
     Creates a view to display segmented choices with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.ChoiceSegments FormQuestionType`s.
     
     - seealso: `segmentViewForQuestion(_:)`
     
     - returns: A newly initialised `SegmentedTextFieldStack`.
     
    */
    open func newSegmentChoiceViewWithChoices(_ choices:[String]) -> SegmentedTextFieldStack {
        
        let segments = UISegmentedControl(items: choices)
        let input = newTextSingleView()
        let segmentElement = SegmentedTextFieldStack(control: segments, inputStack: input)
        segmentElement.titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        segmentElement.subtitleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        return segmentElement
    }
    
    /**
     
     Creates a view to display segmented choices with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.ChoiceSegments FormQuestionType`s.
     
     - returns: A newly initialised `SegmentedTextFieldStack`.
     
     */
    open func newSwitchView() -> SwitchStack {
        
        let switchStack = SwitchStack(switchControl: UISwitch())
        switchStack.titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        switchStack.subtitleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        return switchStack
    }
    
    /**
     
     Creates a view to display buttons with default font styles. Subclasses can override this method to return their desired views or customise ths default view. This is used in `.Button FormQuestionType`s.
     
     - returns: A newly initialised `UIButton` with `.System` type.
     
     */
    open func newButtonView() -> UIButton {
        
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        return button
    }
    
}
