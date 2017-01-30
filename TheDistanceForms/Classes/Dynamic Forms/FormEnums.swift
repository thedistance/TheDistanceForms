//
//  FormEnums.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation



public enum FormQuestionType:String {
    
    /// Single text field entry.
    case textSingle
    
    /// Multi line text entry
    case textMultiline
    
    /// Date only selection
    case date
    
    // Time only selection
    case time
    
    /// Date and Time selection
    case dateTime
    
    /// Choose from a number of items
    case choiceDropdown // choose from a Picker View
    
    /// Choose from a limited number of items
    case choiceSegments
    // case ChoiceSelection // like a radio selection
    
    /// Yes or No question.
    case boolean
    
    /// A button configurable with a title. 
    case button
}

public enum ValidationType:String {
    
    case notNegative
    case notEmpty
    case email
    case number
    case postcode
    case regex
    
}

/// Enum used to define the value that a `ValueElemnt` can return.
public enum FormQuestionValue {
    
    case string(NSString)
    case date(Foundation.Date)
    case boolean(Bool)
    case number(NSNumber)
    case custom(Any)
}

/// Enum used to interpret the value types for validation objects from form json.
public enum FormValueType:String {
    
    case string
    case date
    case bool
    case number
    
}

public enum KeyboardType:String {
    
    case `default` // Default type for the current input method.
    case asciiCapable // Displays a keyboard which can enter ASCII characters, non-ASCII keyboards remain active
    case numbersAndPunctuation // Numbers and assorted punctuation.
    case url // A type optimized for URL entry (shows . / .com prominently).
    case numberPad // A number pad (0-9). Suitable for PIN entry.
    case phonePad // A phone pad (1-9, *, 0, #, with letters under the numbers).
    case namePhonePad // A type optimized for entering a person's name or phone number.
    case emailAddress // A type optimized for multiple email address entry (shows space @ . prominently).
    case decimalPad // A number pad with a decimal point.
    case twitter // A type optimized for twitter text entry (easy access to @ #)
    case webSearch // A default keyboard type with URL-oriented addition (shows space . prominently).
    
    /// The `UIKeyboardType` equivalent for this enum.
    var uiKeyboardType:UIKeyboardType {
        switch self {
        case .default:
            return .default
        case .asciiCapable:
            return .asciiCapable
        case .numbersAndPunctuation:
            return .numbersAndPunctuation
        case .url:
            return .URL
        case .numberPad:
            return .numberPad
        case .phonePad:
            return .phonePad
        case .namePhonePad:
            return .namePhonePad
        case .emailAddress:
            return .emailAddress
        case .decimalPad:
            return .decimalPad
        case .twitter:
            return .twitter
        case .webSearch:
            return .webSearch
        }
    }
}

public enum CapitalizationType : String {
    
    case none
    case words
    case sentences
    case allCharacters
    
    var uiAutoCapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .none:
            return .none
        case .words:
            return .words
        case .sentences:
            return .sentences
        case .allCharacters:
            return .allCharacters
        }
    }
}

public enum DateTimeFormatStyle: String {
    
    case short
    case medium
    case long
    case full
    
    var dateFormatStyle: DateFormatter.Style {
        switch self {
        case .short:
            return .short
        case .medium:
            return .medium
        case .long:
            return .long
        case .full:
            return .full
        }
    }
}
