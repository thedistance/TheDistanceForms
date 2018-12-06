//
//  FormStack.swift
//  StackView
//
//  Created by Josh Campion on 23/10/2015.
//  Copyright © 2015 The Distance. All rights reserved.
//

import Foundation
import TDStackView

public typealias HashableRaw = Hashable & RawRepresentable

/**
 
 Defines the requirement of an object that can contain values, which may or may not be consider valid.
 
 This protocol could define a typealias to specify the type of values it allows. This would mean that `ValueElement`s could only be used as generic constraints, restricting their use.
 
 */
public protocol ValueElement {
    
    /// Should return the value if there is one, nil otherwise.
    func getValue() -> Any?
    
    /**
     
     Attempts to assign a given value and returns whether it was successfully assigned.
     
     - parameter value: The new value to assign to this elemnt. 
     - return `true` if successfully assigned, `false` otherwise.
    */
    func setValue<T>(_ value:T?) -> Bool
    
    /// Should performs some check on the value returning `true` if the value is appropriate, `false` otherwise.
    func validateValue() -> ValidationResult
}


public protocol KeyedValueElementContainer {
    
    associatedtype KeyType:HashableRaw
    
    func elementForKey(_ key:KeyType) -> ValueElement?
    
    var elements:[ValueElement] { get }
    
    /// Should return the value for the element with the given key. Default implementation calls `elementForKey(_:)?.getValue()`.
    func getValueForKey(_ key:KeyType) -> Any?
    
    /// Should attempt to set the given value for the element with the given key. Default implementation calls `elementForKey(_:)?.setValue()`.
    func setValue<T>(_ value:T?, forKey:KeyType) -> Bool
    
    /**
     
     Should return whether all elements in this container are valid.
     
     The default implementation is to iterate through `elements()` calling `validateValue()`.
     
     - returns: `.Valid` if there are no invalid values, `.Invalid(_)` otherwise.
     
     */
    func validateValues() -> ValidationResult
}

public extension KeyedValueElementContainer {
    
    public func getValueForKey(_ key:KeyType) -> Any? {
        return elementForKey(key)?.getValue()
    }
    
    public func setValue<T>(_ value:T?, forKey:KeyType) -> Bool {
        return elementForKey(forKey)?.setValue(value) ?? false
    }
    
    public func validateValues() -> ValidationResult {
        return elements.reduce(.valid, { return $0 && $1.validateValue() })
    }
}

public protocol KeyedView {
    
    associatedtype KeyType:HashableRaw
    
    var viewKeys:[KeyType:UIView] { get }
}

public typealias KeyedValueElementContainerView = KeyedView & KeyedValueElementContainer

public extension KeyedValueElementContainer where Self:KeyedView {
    
    var elements:[ValueElement] {
        return viewKeys.compactMap({ $0.0 as? ValueElement })
    }
    
    public func elementForKey(_ key:KeyType) -> ValueElement? {
        return viewKeys[key] as? ValueElement
    }
    
    
}
