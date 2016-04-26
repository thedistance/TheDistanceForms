//
//  FormValidation.swift
//  CreatedStack
//
//  Created by Josh Campion on 23/10/2015.
//

import Foundation
import TheDistanceCore

public enum ValidationResult: Equatable {
    case Valid
    case Invalid(reason:String)
}

public func ==(v1:ValidationResult, v2:ValidationResult) -> Bool {
    switch (v1, v2) {
    case (.Valid, .Valid):
        return true
    case (.Valid, .Invalid(_)), (.Invalid(_), .Valid):
        return false
    case (.Invalid(let m1), .Invalid(let m2)):
        return m1 == m2
    }
}

/// Combines two `ValidationResult`s as if combining two `Bool`s using `&&`. The invalidation messages are combined with "\n".
@warn_unused_result
public func &&(v1:ValidationResult, v2:ValidationResult) -> ValidationResult {
    switch (v1, v2) {
    case (.Valid, .Valid):
        return .Valid
    case (.Valid, .Invalid(_)):
        return v2
    case (.Invalid(_), .Valid):
        return v1
    case (.Invalid(let m1), .Invalid(let m2)):
        return .Invalid(reason: m1 + "\n" + m2)
    }
}

/// Combines two `ValidationResult`s as if combining two `Bool`s using `||`. If both parameters are `Invalid`, invalidation messages are combined with "\n".
@warn_unused_result
public func ||(v1:ValidationResult, v2:ValidationResult) -> ValidationResult {
    switch (v1, v2) {
    case (.Valid, .Valid), (.Valid, .Invalid(_)), (.Invalid(_), .Valid):
        return .Valid
    case (.Invalid(let m1), .Invalid(let m2)):
        return .Invalid(reason: m1 + "\n" + m2)
    }
}

/**

Structure that performs validation on a value of a given type, returning `true` or `false` if that validation passes.

- seealso: NullStringValidation, EmailValidation

*/
public struct Validation<Type> {
    
    /// Should return `true` if the value passes, `false` otherwise. The value is optional as user data is likely to contain `nil` entries.
    public let validate:(value:Type?) -> ValidationResult
    
    /// Initialiser assigning the parameters to the properties of the same names.
    public init(message:String, validation:(value:Type?) -> Bool) {
        // self.message = message
        self.validate = { (v:Type?) -> ValidationResult in
            return validation(value: v) ? .Valid : .Invalid(reason: message)
        }
    }
    
    public init(andValidations:[Validation<Type>], message:String? = nil) {
        self.validate = { (v:Type?) -> ValidationResult in
            
            let compound = andValidations.reduce(.Valid, combine: { $0 && $1.validate(value: v) })
            
            if let m = message where compound != .Valid {
                return .Invalid(reason: m)
            } else {
                return compound
            }
        }
    }
    
    public init(orValidations:[Validation<Type>], message:String? = nil) {
        
        self.validate = { (v:Type?) -> ValidationResult in
            let compound = orValidations.reduce(.Valid, combine: { $0 || $1.validate(value: v) })
            
            if let m = message where compound != .Valid {
                return .Invalid(reason: m)
            } else {
                return compound
            }
        }
    }
}

/// Convenience creator for a validation that checks whether a given string, trimmed from whitespace, is has content.
public func NonEmptyStringValidation(message:String) -> Validation<String> {
    
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
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional email address.
*/
public func EmailValidationWithMessage(message:String, allowingNull:Bool = false) -> Validation<String> {
    
    return Validation<String>(message: message, validation: { (value) -> Bool in
        
        let nullValidation = NonEmptyStringValidation("")
        
        guard let stringValue = value else {
            return false
        }
        
        if !allowingNull && nullValidation.validate(value: stringValue) != ValidationResult.Valid {
            return false
        }
        
        if allowingNull && stringValue.isEmpty {
            return true
        }
        
        var regexString = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}"
        regexString += "\\@"
        regexString += "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}"
        regexString += "("
        regexString += "\\."
        regexString += "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}"
        regexString += ")+"
        
        // this is a programmer error so ensure it is correct by force
        let regex = try! NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
        return regex.matchesInString(stringValue, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
    })
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid phone number. The check is based on the regex:
 
 [0-9\s]
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional number.
 */
public func NumberValidationWithMessage(message:String, allowingNull:Bool = false) -> Validation<String> {
    
    return Validation<String>(message: message, validation: { (value) -> Bool in
        let nullValidation = NonEmptyStringValidation("")
        
        guard let stringValue = value else {
            return false
        }
        
        if !allowingNull && nullValidation.validate(value: stringValue) != .Valid {
            return false
        }
        
        if allowingNull && stringValue.isEmpty {
            return true
        }
        
        
        let regexString = "[0-9\\s]"
        
        // this is a programmer error so ensure it is correct by force
        let regex = try! NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
        return regex.matchesInString(stringValue, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
    })
}

/**

 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid phone number. The check is based on the regex:

    [\+]?[0-9.-]+

 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
*/
public func PhoneValidationWithMessage(message:String, allowingNull:Bool = false) -> Validation<String> {
    
    return Validation<String>(message: message, validation: { (value) -> Bool in
        let nullValidation = NonEmptyStringValidation("")
        
        guard let stringValue = value else {
            return false
        }
        
        if !allowingNull && nullValidation.validate(value: stringValue) == .Valid {
            return false
        }
        
        if allowingNull && stringValue.isEmpty {
            return true
        }
        
        
        let regexString = "[\\+]?[0-9.-]+"
        
        // this is a programmer error so ensure it is correct by force
        let regex = try! NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
        return regex.matchesInString(stringValue, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
    })
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is a valid UK postcode number. The check is based on the regex:
 
 (GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKPSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
 */
public func UKPostcodeValidationWithMessage(message:String, allowingNull:Bool = false) -> Validation<String> {
    
    return Validation<String>(message: message, validation: { (value) -> Bool in
        let nullValidation = NonEmptyStringValidation("")
        
        guard let stringValue = value else {
            return false
        }
        
        if !allowingNull && nullValidation.validate(value: stringValue) != .Valid {
            return false
        }
        
        if allowingNull && stringValue.isEmpty {
            return true
        }
        
        
        let regexString = "(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKPSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})"
        
        // this is a programmer error so ensure it is correct by force
        let regex = try! NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
        return regex.matchesInString(stringValue, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
    })
}

/**
 
 Convenience creator for a validation that checks whether a given string, trimmed from whitespace is valid against given regex.
 
 
 - parameter message: The `message` property of the returned `Validation`.
 - parameter allowingNull: Whether or not an empty string will be allowed. Default is `false`. `true` allows validation of an optional phone number.
 - returns: A validation if a, `NSRegularExpression` is created with the given `regex`, `nil` otherwise.
 */
public func RegexValidationWithMessage(message:String, regex:String, allowingNull:Bool = false) -> Validation<String>? {
    
    if let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive) {
        return Validation<String>(message: message, validation: { (value) -> Bool in
            let nullValidation = NonEmptyStringValidation("")
            
            guard let stringValue = value else {
                return false
            }
            
            if !allowingNull && nullValidation.validate(value: stringValue) != .Valid {
                return false
            }
            
            if allowingNull && stringValue.isEmpty {
                return true
            }
        
            return regex.matchesInString(stringValue, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, stringValue.characters.count)).count > 0
            
        })
    } else {
        return nil
    }
}