//
//  ValidationResult.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 07/06/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

/// Enum used to represent the validity of a user entered value used in conjunction with a `Validation` object.
public enum ValidationResult: Equatable {
    
    /// Implies the value is acceptable.
    case valid
    
    /// Implies this value has failed validation. Contains the reason for failure as an associated value.
    case invalid(reason:String)
}

/// Equatable conformance for `ValidationResult`. Equality is determined by the case and the associated value if `.Invalid`.
public func ==(v1:ValidationResult, v2:ValidationResult) -> Bool {
    switch (v1, v2) {
    case (.valid, .valid):
        return true
    case (.valid, .invalid(_)), (.invalid(_), .valid):
        return false
    case (.invalid(let m1), .invalid(let m2)):
        return m1 == m2
    }
}

/// Combines two `ValidationResult`s as if combining two `Bool`s using `&&`. The invalidation messages are combined with "\n".

public func &&(v1:ValidationResult, v2:ValidationResult) -> ValidationResult {
    switch (v1, v2) {
    case (.valid, .valid):
        return .valid
    case (.valid, .invalid(_)):
        return v2
    case (.invalid(_), .valid):
        return v1
    case (.invalid(let m1), .invalid(let m2)):
        return .invalid(reason: m1 + "\n" + m2)
    }
}

/// Combines two `ValidationResult`s as if combining two `Bool`s using `||`. If both parameters are `Invalid`, invalidation messages are combined with "\n".

public func ||(v1:ValidationResult, v2:ValidationResult) -> ValidationResult {
    switch (v1, v2) {
    case (.valid, .valid), (.valid, .invalid(_)), (.invalid(_), .valid):
        return .valid
    case (.invalid(let m1), .invalid(let m2)):
        return .invalid(reason: m1 + "\n" + m2)
    }
}
