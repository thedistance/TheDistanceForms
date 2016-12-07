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
    
    case NotEmpty
    case Email
    case Number
    case Postcode
    case Regex
    
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
            return .default
        case .ASCIICapable:
            return .asciiCapable
        case .NumbersAndPunctuation:
            return .numbersAndPunctuation
        case .URL:
            return .URL
        case .NumberPad:
            return .numberPad
        case .PhonePad:
            return .phonePad
        case .NamePhonePad:
            return .namePhonePad
        case .EmailAddress:
            return .emailAddress
        case .DecimalPad:
            return .decimalPad
        case .Twitter:
            return .twitter
        case .WebSearch:
            return .webSearch
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
            return .none
        case .Words:
            return .words
        case .Sentences:
            return .sentences
        case .AllCharacters:
            return .allCharacters
        }
    }
}

public enum DateTimeFormatStyle: String {
    
    case Short
    case Medium
    case Long
    case Full
    
    var dateFormatStyle: DateFormatter.Style {
        switch self {
        case .Short:
            return .short
        case .Medium:
            return .medium
        case .Long:
            return .long
        case .Full:
            return .full
        }
    }
}
