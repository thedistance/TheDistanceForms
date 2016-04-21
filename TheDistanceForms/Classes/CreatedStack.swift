//
//  CreatedStack.swift
//  Pods
//
//  Created by Josh Campion on 10/01/2016.
//
//

import UIKit

/**

 Class that creates and retains a `StackView` object. 
 
 Subclasses can be defined to create reusable stacks that will be `UIStackView`s on iOS 9 and `TZStackView`s on iOS 8, allowing for the performance benefits on iOS 9 whilst still mainatining support for iOS 8.
 
 - seealso: `GenericStringsStack`
*/
public class CreatedStack {
    
    /// The `StackView` representation of this `CreatedStack`. Access and modify the properties of a `UIStackView` through this variable.
    public var stack:StackView
    
    /// The `UIView` representation of this `CreatedStack`. Use this property to manipulate the `UIView` properties of this `CreatedStack` and manage this stack in a view heierarchy.
    public var stackView:UIView {
        return stack.view
    }
    
    /**
     
     Default initialiser which retains the result of `CreateStackView(_:)` with the given `UIView`s.
     
     - parameter arrangedSubviews: The `UIView`s passed to the `CreateStackView(_:)` global function.
    */
    public init(arrangedSubviews:[UIView]) {
        stack = CreateStackView(arrangedSubviews)
    }
}