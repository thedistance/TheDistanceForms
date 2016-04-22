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
    case TextSingle
    
    /// Multi line text entry
    case TextMultiline
    
    /// Date only selection
    case Date
    
    // Time only selection
    case Time
    
    /// Date and Time selection
    case DateTime
    
    /// Choose from a number of items
    case ChoiceDropdown // choose from a Picker View
    
    /// Choose from a limited number of items
    case ChoiceSegments
    // case ChoiceSelection // like a radio selection
    
    /// Yes or No question.
    case Boolean
    
    /// A button configurable with a title. 
    case Button
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
    
    case String(NSString)
    case Date(NSDate)
    case Boolean(Bool)
    case Number(NSNumber)
    case Custom(Any)
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
