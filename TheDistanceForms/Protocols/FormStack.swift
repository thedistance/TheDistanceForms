//
//  FormStack.swift
//  StackView
//
//  Created by Josh Campion on 23/10/2015.
//  Copyright © 2015 The Distance. All rights reserved.
//

import Foundation

public typealias HashableRaw = protocol<Hashable, RawRepresentable>

/// Defines the requirement of an object that can contain valid values.
public protocol ValueElement {
    
    /// Should return the value if there is one, nil otherwise.
    func getValue() -> Any?
    
    /**
     
     Attempts to assign a given value and returns whether it was successfully assigned.
     
     - parameter value: The new value to assign to this elemnt. 
     - return `true` if successfully assigned, `false` otherwise.
    */
    func setValue<T>(value:T?) -> Bool
    
    /// Should performs some check on the value returning `true` if the value is appropriate, `false` otherwise.
    func validateValue() -> ValidationResult
}

///
public protocol KeyedValueElementContainer {
    
    associatedtype KeyType:HashableRaw
    
    func elementForKey(key:KeyType) -> ValueElement?
    
    var elements:[ValueElement] { get set }
    
    /// Should return the value for the element with the given key. Default implementation calls `elementForKey(_:)?.getValue()`.
    func getValueForKey(key:KeyType) -> Any?
    
    /// Should attempt to set the given value for the element with the given key. Default implementation calls `elementForKey(_:)?.setValue()`.
    func setValue<T>(value:T?, forKey:KeyType) -> Bool
    
    /**
     
     Should return whether all elements in this container are valid.
     
     The default implementation is to iterate through `elements()` calling `validateValue()`.
     
     - returns: `.Valid` if there are no invalid values, `.Invalid(_)` otherwise.
     
     */
    func validateValues() -> ValidationResult
}

public extension KeyedValueElementContainer {
    
    public func getValueForKey(key:KeyType) -> Any? {
        return elementForKey(key)?.getValue()
    }
    
    public func setValue<T>(value:T?, forKey:KeyType) -> Bool {
        return elementForKey(forKey)?.setValue(value) ?? false
    }
    
    public func validateValues() -> ValidationResult {
        return elements.reduce(.Valid, combine: { return $0 && $1.validateValue() })
    }
}

public protocol KeyedView {
    
    associatedtype KeyType:HashableRaw
    
    var viewKeys:[KeyType:UIView] { get set }
}

public typealias KeyedValueElementContainerView = protocol<KeyedView, KeyedValueElementContainer>

public extension KeyedValueElementContainer where Self:KeyedView {
    
    var elements:[ValueElement] {
        return viewKeys.flatMap({ $0.0 as? ValueElement })
    }
    
    public func elementForKey(key:KeyType) -> ValueElement? {
        return viewKeys[key] as? ValueElement
    }
    
    
}