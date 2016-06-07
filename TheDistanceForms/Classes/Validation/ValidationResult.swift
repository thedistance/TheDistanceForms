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
    case Valid
    
    /// Implies this value has failed validation. Contains the reason for failure as an associated value.
    case Invalid(reason:String)
}

/// Equatable conformance for `ValidationResult`. Equality is determined by the case and the associated value if `.Invalid`.
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