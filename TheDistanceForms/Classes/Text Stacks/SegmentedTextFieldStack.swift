//
//  SegmentedTextFieldStack.swift
//  Pods
//
//  Created by Josh Campion on 09/02/2016.
//
//

import UIKit
import TheDistanceCore
import TDStackView

/**
 
 Error Stack containing a `UISegemntedControl` and a `TextStack`. This class allows for a scoped `UITextField`. Override `typeChanged()` to respond to the scope change and call `reloadInputViews` if the text component's `inputView` should change.
 
 This is a `ValueElement` with a validation property for the segemented control. Validation tests both the `validation` property and the `inputStack.validtion`.
 
 */
open class SegmentedTextFieldStack: ErrorStack, ValueElement {
    
    /// `UILabel` to show the title. Defaults to `UIFontTextStyleHeadline`.
    open let titleLabel:UILabel
    
    /// `UILabel` to show subtitle title. Defaults to `UIFontTextStyleSubheadline`.
    open let subtitleLabel:UILabel
    
    /// The control the user will interact with.
    open let choiceControl:UISegmentedControl
    
    /// `Validation` that validates the user's selection.
    open var validation:Validation<Int>?
    
    /// The `TextStack` aligned below the segmented control that allows for scope text entry.
    open let inputStack:TextStack
    
    // internal varaible returning either the `UITextField` or `UITextView` of the `inputStack`.
    var inputView:UIView? {
        
        return (inputStack as? TextFieldStack)?.textField ??
            (inputStack as? TextViewStack)?.textView
    }
    
    /// Internal variable for managing changes in `choiceControl`
    fileprivate var target:ObjectTarget<UISegmentedControl>?
    
    /**
     
     Default initialiser.
     
     Subclasses can call through to super with arguments for each variable but configuration to override the defaults should be done after `super.init()`.
     
     - parameter control: The `UISegementedControl` the user will interact with.
     - parameter inputStack: The `TextStack` that can created a scoped text entry.
     - titleLabel: The label the title will be shown on. Default font is `UIFontTextStyleHeadline`.
     - subtitleLabel: The label the title will be shown on. Default font is `UIFontTextStyleSubheadline`.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`. The font for this labels is set to `UIFontTextStyleCaption2`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
     
     */
    public init(control:UISegmentedControl,
                inputStack:TextStack,
                titleLabel:UILabel = UILabel(),
                subtitleLabel:UILabel = UILabel(),
                errorLabel:UILabel = UILabel(),
                errorImageView:UIImageView = UIImageView(),
                iconImageView:UIImageView = UIImageView()) {
        
        choiceControl = control
        self.inputStack = inputStack
        inputStack.stackView.isHidden = true
        
        self.titleLabel = titleLabel
        self.titleLabel.numberOfLines = 0
        
        self.subtitleLabel = subtitleLabel
        self.subtitleLabel.numberOfLines = 0
        
        var textStack = CreateStackView([self.titleLabel, self.subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4.0
        
        var contentStack = CreateStackView([textStack.view, choiceControl, inputStack.stackView])
        contentStack.axis = .vertical
        contentStack.spacing = 12.0
        
        super.init(centerComponent: contentStack.view,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
        
        stack.axis = .vertical
        stack.spacing = 12.0
        
        target = ObjectTarget(control:choiceControl, forControlEvents: .valueChanged, completion: typeChange)
    }
    
    /**
     
     Sets the selected segment of `choiceControl` and propagates that through `typeChange(_:)`.
     
     - parameter idx: The `selectedSegmentIndex` set on `choiceControl`.
    */
    open func selectSegment(_ idx:Int) {
        choiceControl.selectedSegmentIndex = idx
        typeChange(choiceControl)
    }
    
    /// Called when the selected value of `choiceControl` changes. This makes the `inputStack` become the first responder if it is not hidden.
    open func typeChange(_ sender:UISegmentedControl) {
        if !(inputView?.isFirstResponder ?? false) && !inputStack.stackView.isHidden {
            inputView?.becomeFirstResponder()
        }
    }
    
    // MARK: Form Element
    
    /// - returns: The text value of the selected segement of `choiceControl`.
    open func stringValue() -> String? {
        if choiceControl.selectedSegmentIndex >= 0 {
            return choiceControl.titleForSegment(at: choiceControl.selectedSegmentIndex)
        }
        
        return nil
    }
    
    /**
     
     `ValueElement` conformance. 
     
     - returns: The `selectedSegmentIndex` of `choiceControl`.
     
    */
    open func getValue() -> Any? {
        return choiceControl.selectedSegmentIndex
    }
    
    open func setValue<T>(_ value: T?) -> Bool {
        if let idx = value as? Int, idx >= 0 && idx < choiceControl.numberOfSegments {
            choiceControl.selectedSegmentIndex = idx
            return true
        } else {
            return false
        }
    }
    
    /// `ValueElement` conformance. Applies `&&` to the results of `validation` on self and `validation` on `inputStack`.
    open func validateValue() -> ValidationResult {
        
        let segmentResult:ValidationResult
        
        if let value = getValue() as? Int {
            segmentResult = validation?.validate(value) ?? .valid
        } else {
            segmentResult = validation?.validate(nil) ?? .valid
        }
        
        if case .invalid(let message) = segmentResult {
            errorText = message
        } else {
            errorText = nil
        }
        
        let result = segmentResult && inputStack.validateValue()
        
        return result
    }
}
