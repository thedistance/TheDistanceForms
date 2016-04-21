//
//  SegmentedTextFieldStack.swift
//  Pods
//
//  Created by Josh Campion on 09/02/2016.
//
//

import UIKit
import TheDistanceCore

/// Error Stack containing a `UISegemntedControl` and a `TextStack`. This is a `ValueElement` with a default validation property for the segemented control and a validateValue that validates both the `validation` property and the `inputStack.validtion`. This component allows for a scoped text field. Override the method `typeChanged()` to respond to the scope change and call `reloadInputViews` if the text component's input view should change.
public class SegmentedTextFieldStack: ErrorStack, ValueElement {
    
    public let choiceControl:UISegmentedControl
    
    public let inputStack:TextStack
    
    var inputView:UIView? {
        
        return (inputStack as? TextFieldStack)?.textField ??
            (inputStack as? TextViewStack)?.textView
    }
    
    private var target:ObjectTarget<UISegmentedControl>?
    
    public var validation:Validation<Int>?
    
    public init(control:UISegmentedControl,
        inputStack:TextStack,
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView()) {
            
            choiceControl = control
            self.inputStack = inputStack
            
            var contentStack = CreateStackView([choiceControl, inputStack.stackView])
            contentStack.axis = .Vertical
            contentStack.spacing = 12.0
            
            super.init(centerComponent: contentStack.view,
                errorLabel: errorLabel,
                errorImageView: errorImageView,
                iconImageView: iconImageView)
            
            stack.axis = .Vertical
            stack.spacing = 12.0
            
            target = ObjectTarget(control:choiceControl, forControlEvents: .ValueChanged, completion: typeChange)
    }
    
    public func selectSegment(idx:Int) {
        choiceControl.selectedSegmentIndex = idx
        typeChange(choiceControl)
    }
    
    public func typeChange(sender:UISegmentedControl) {
        if !(inputView?.isFirstResponder() ?? false) && !inputStack.stackView.hidden {
            inputView?.becomeFirstResponder()
        }
    }
    
    // MARK: Form Element
    public func stringValue() -> String? {
        if choiceControl.selectedSegmentIndex >= 0 {
            return choiceControl.titleForSegmentAtIndex(choiceControl.selectedSegmentIndex)
        }
        
        return nil
    }
    
    public func getValue() -> Any? {
        return choiceControl.selectedSegmentIndex
    }
    
    public func setValue<T>(value: T?) -> Bool {
        if let idx = value as? Int
            where idx >= 0 && idx < choiceControl.numberOfSegments {
                choiceControl.selectedSegmentIndex = idx
                return true
        } else {
            return false
        }
    }
    
    public func validateValue() -> ValidationResult {
        
        let segmentResult:ValidationResult
        
        if let value = getValue() as? Int {
            segmentResult = validation?.validate(value: value) ?? .Valid
        } else {
            segmentResult = validation?.validate(value: nil) ?? .Valid
        }
        
        if case .Invalid(let message) = segmentResult {
            errorText = message
        } else {
            errorText = nil
        }
        
        let result = segmentResult && inputStack.validateValue()
        
        return result
    }
}