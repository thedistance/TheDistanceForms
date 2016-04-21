//
//  TextFieldStack+Form.swift
//  StackView
//
//  Created by Josh Campion on 23/10/2015.
//  Copyright © 2015 The Distance. All rights reserved.
//

import Foundation
import TheDistanceCore

extension TextStack: ValueElement {
    
    public func setValue<T>(value: T?) -> Bool {
        if let str = (value as? String)?.whitespaceTrimmedString() {
            
            if let result = validation?.validate(value: str), case .Valid = result  {
                text = str
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    public func getValue() -> Any? {
        return text
    }
    
    /**
    
    Calls `validation.validate(_:)` on `text` setting the `errorText` as appropriate.
    
    - returns: `.Valid` if `text` passes validation, `.Invalid(let message)` otherwise, where message is that returned by `self.validation`.
    */
    public func validateValue() -> ValidationResult {
        
        let newText = text
        let result = validation?.validate(value: newText) ?? .Valid
        
        text = newText
        
        if case .Invalid(let message) = result {
            errorText = message
        } else {
            errorText = nil
        }
        
        return result
    }
}
