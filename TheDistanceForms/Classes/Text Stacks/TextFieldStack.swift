//
//  TextFieldStack.swift
//  CreatedStacks
//
//  Created by Josh Campion on 22/10/2015.
//  Copyright © The Distance. All rights reserved.
//

import Foundation

import StackView
import TheDistanceCore

/**

 `TextStack` subclass using a `UITextField`.

 `placeholderLabel` and `errorLabel` are configured in response to `UITextFieldTextDidBeginEditingNotification` and `UITextFieldTextDidEndEditingNotification`, which call `textFieldBeganEditing()` and `textFieldFinishedEditing()` respectively.
 
*/
@IBDesignable
public class TextFieldStack: TextStack {
    
    /// Optional variable that retains a reference to a `UIPickerViewDataController` if one is requried.
    var pickerController:UIPickerViewDataController?
    
    /// Optional variable that retains a reference to a `UIDatePickerDataController` if one is requried.
    var dateController:UIDatePickerDataController?
    
    // MARK: - Properties
    /// The whitespace trimmed text entered into the `textField`.
    override public var text:String? {
        get {
            return textField.text?.whitespaceTrimmedString()
        } set {
            textField.text = newValue?.whitespaceTrimmedString()
            configurePlaceholder()
        }
    }
    
    /// Flag to determine whether user interaction is enabled for the `textView`. This causes a layout pass to be called.
    public var enabled:Bool = true {
        didSet {
            textField.enabled = enabled
            
            configurePlaceholder()
            configureUnderline()
            
            stackView.invalidateIntrinsicContentSize()
            stackView.setNeedsLayout()
        }
    }
    
    /// The text field the user interacts with. Text should be set using the `text` property rather than directly setting it on this variable.
    public let textField:UITextField
    
    private var textBeginObserver:NotificationObserver?
    private var textEndObserver:NotificationObserver?
    
    // MARK: - CreatedStack Methods
    
    /**
    
    Default initialiser.
    
    Subclasses can call through to super with arguments for each variable but configuration to override the defaults should be done after `super.init()`.
    
    Subclasses can set this before calling `super.init()` to use a custom subclass. Configures the default values for the stack and text field. Calls `configureErrorImageAlignedToView(_:)` and `addUnderlineForView(_:)` to set up the remaining view hierarchy. Adds observers to NSNotificationCenter to respond to the `textField` becoming and resigning first responder status.
    */
    public init(textField:UITextField = UITextField(),
        placeholderLabel:UILabel = UILabel(),
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView(),
        underline:UIView = UIView()) {
        
        // create the specific views
            self.textField = textField
        textField.borderStyle = .None
        
        super.init(textComponent: textField,
            placeholderLabel: placeholderLabel,
            errorLabel: errorLabel,
            errorImageView: errorImageView,
            iconImageView: iconImageView,
            underline: underline)
        
        textBeginObserver = NotificationObserver(name: UITextFieldTextDidBeginEditingNotification, object: textField) { (note) -> () in
            self.configureUnderline()
            
            self.placeholderLabel.text = self.textField.placeholder ?? self.textField.attributedPlaceholder?.string
            self.placeholderLabel.hidden = (self.hidesPlaceholderLabel && !self.textField.isFirstResponder())
            
            self.textField.placeholder = nil
        }
        
        textEndObserver = NotificationObserver(name: UITextFieldTextDidEndEditingNotification, object: textField) { (note) -> () in
            self.configureUnderline()
            
            self.textField.placeholder = self.placeholderText
            self.placeholderLabel.hidden = (self.textField.text?.isEmpty ?? true) || (self.hidesPlaceholderLabel && !self.textField.isFirstResponder())
            
            if self.liveValidation {
                self.validateValue()
            }
        }
        
        addUnderlineForView(textField)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// Shows / hides the `placeholderLabel` and `placeholder` text of the `textField` based on the currently entered text.
    public override func configurePlaceholder() {
        
        if placeholderLabel.text != placeholderText {
            placeholderLabel.text = placeholderText
        }
        
        if !textField.isFirstResponder() {    
            
            if textField.placeholder != placeholderText {
                textField.placeholder = placeholderText
            }
            
            let placeholderHidden = (textField.text?.isEmpty ?? true) || (hidesPlaceholderLabel && !textField.isFirstResponder())
            if placeholderLabel.hidden != placeholderHidden {
                placeholderLabel.hidden = placeholderHidden
                // TODO: Weak link to TextResponder Cocoapod
                // post notification as showing / hiding the label changes the position of the text view
                // NSNotificationCenter.defaultCenter().postNotificationName(KeyboardResponderRequestUpdateScrollNotification, object: textField)
            }
        } else {
            textField.placeholder = nil
        }
    }
    
    public func configureUnderline() {
        underline.alpha = textField.isFirstResponder() ? 1.0 : (enabled ? 0.5 : 0.0)
    }
}