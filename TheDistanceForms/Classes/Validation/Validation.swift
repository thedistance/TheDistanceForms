//
//  FormValidation.swift
//  CreatedStack
//
//  Created by Josh Campion on 23/10/2015.
//

import Foundation
import TheDistanceCore

/**

Structure that performs validation on a value of a given type, returning `true` or `false` if that validation passes. The generic `Type` parameter is used to strongly type the value validation.

 - seealso: `NonEmptyStringValidation(_:)`
 - seealso: `RegexValidationWithMessage(_:regex:allowingNull:)`
 - seealso: `EmailValidationWithMessage(_:allowingNull:)`
 - seealso: `NumberValidationWithMessage(_:allowingNull:)`
 - seealso: `PhoneValidationWithMessage(_:allowingNull:)`
 - seealso: `UKPostcodeValidationWithMessage(_:allowingNull:)`
 
*/
public struct Validation<Type> {
    
    /// Should return `true` if the value passes, `false` otherwise. The value is optional as user data is likely to contain `nil` entries.
    public let validate:(_ value:Type?) -> ValidationResult
    
    /// Initialiser assigning the parameters to the properties of the same names.
    public init(message:String, validation:@escaping (_ value:Type?) -> Bool) {
        // self.message = message
        self.validate = { (v:Type?) -> ValidationResult in
            return validation(v) ? .valid : .invalid(reason: message)
        }
    }
    
    /// Convenience initialiser for a group of validations that should be applied using `&&` logic, i.e. all child validations must be valid for this validation to be valid.
    public init(andValidations:[Validation<Type>], message:String? = nil) {
        self.validate = { (v:Type?) -> ValidationResult in
            
            let compound = andValidations.reduce(.valid, { $0 && $1.validate(v) })
            
            if let m = message, compound != .valid {
                return .invalid(reason: m)
            } else {
                return compound
            }
        }
    }
    
    /// Convenience initialiser for a group of validations that should be applied using `||` logic, i.e. at least one child validation must be valid for this validation to be valid.
    public init(orValidations:[Validation<Type>], message:String? = nil) {
        
        self.validate = { (v:Type?) -> ValidationResult in
            let compound = orValidations.reduce(.valid, { $0 || $1.validate(v) })
            
            if let m = message, compound != .valid {
                return .invalid(reason: m)
            } else {
                return compound
            }
        }
    }
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace, has content.
 
 - parameter message: The `message` property of the returned `Validation`. validation fails.
 
 - returns: A configured `Validation<String>` object.
 */
public func NonEmptyStringValidation(_ message:String) -> Validation<String> {
    
    return Validation<String>(message: message, validation: { (value) -> Bool in
        
        if let str = value {
            return !str.whitespaceTrimmedString().isEmpty
        }
        
        return false
    })
}

/**

 Convenience creator for a validation that checks whether a given string is a valid email. The check is based on the regex:

     [a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+
 
 - seealso: `RegexValidationWithMessage(_:regex:allowingNull:)`
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional email address.
 
 - returns: A configured `Validation<String>` object.
*/
public func EmailValidationWithMessage(_ message:String, allowingNull:Bool = false) -> Validation<String> {
    
    var regexString = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}"
    regexString += "\\@"
    regexString += "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}"
    regexString += "("
    regexString += "\\."
    regexString += "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}"
    regexString += ")+"
    
    // this is a programmer error in creating the regex so ensure it is correct by force
    return RegexValidationWithMessage(message, regex: regexString, allowingNull: allowingNull)!
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid phone number. The check is based on the regex:
 
 [0-9\s]
 
 - seealso: `RegexValidationWithMessage(_:regex:allowingNull:)`
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional number.
 
 - returns: A configured `Validation<String>` object.
 */
public func NumberValidationWithMessage(_ message:String, allowingNull:Bool = false) -> Validation<String> {
    
    let regexString = "[0-9\\s]"
    
    // this is a programmer error in creating the regex so ensure it is correct by force
    return RegexValidationWithMessage(message, regex: regexString, allowingNull: allowingNull)!
}

/**

 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid phone number. The check is based on the regex:

    [\+]?[0-9.-]+

 - seealso: `RegexValidationWithMessage(_:regex:allowingNull:)`
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
 
 - returns: A configured `Validation<String>` object.
*/
public func PhoneValidationWithMessage(_ message:String, allowingNull:Bool = false) -> Validation<String> {
    
    let regexString = "[\\+]?[0-9.-]+"
    
    // this is a programmer error in creating the regex so ensure it is correct by force
    return RegexValidationWithMessage(message, regex: regexString, allowingNull: allowingNull)!
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid UK postcode number. The check is based on the regex:
 
 (GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKPSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})
 
 - seealso: `RegexValidationWithMessage(_:regex:allowingNull:)`
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
 
 - returns: A configured `Validation<String>` object.
 */
public func UKPostcodeValidationWithMessage(_ message:String, allowingNull:Bool = false) -> Validation<String> {
    
    let regexString = "(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKPSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})"
    
    
    // this is a programmer error in creating the regex so ensure it is correct by force
    return RegexValidationWithMessage(message, regex: regexString, allowingNull: allowingNull)!
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is valid against given regex.
 
 - seealso: `EmailValidationWithMessage(_:allowingNull:)`
 - seealso: `NumberValidationWithMessage(_:allowingNull:)`
 - seealso: `PhoneValidationWithMessage(_:allowingNull:)`
 - seealso: `UKPostcodeValidationWithMessage(_:allowingNull:)`
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
 
 - returns: A validation if a, `NSRegularExpression` is created with the given `regex`, `nil` otherwise.
 
 */
public func RegexValidationWithMessage(_ message:String, regex:String, allowingNull:Bool = true) -> Validation<String>? {
    
    if let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) {
        return Validation<String>(message: message, validation: { (value) -> Bool in
            
            guard let stringValue = value else {
                return false
            }
            
            if !allowingNull{
                if (stringValue.isEmpty) {
                    return false
                }
                if NonEmptyStringValidation("").validate(stringValue) != .valid {
                    return false
                }
            }
            
            return regex.matches(in: stringValue, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
            
        })
    } else {
        return nil
    }
}
