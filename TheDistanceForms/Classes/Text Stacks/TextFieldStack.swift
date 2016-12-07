//
//  TextFieldStack.swift
//  CreatedStacks
//
//  Created by Josh Campion on 22/10/2015.
//  Copyright © The Distance. All rights reserved.
//

import Foundation

import TDStackView
import TheDistanceCore
import KeyboardResponder

/**

 `TextStack` subclass using a `UITextField`.

 `placeholderLabel` is configured in response to `UITextFieldTextDidBeginEditingNotification` and `UITextFieldTextDidEndEditingNotification`, which call `textFieldBeganEditing()` and `textFieldFinishedEditing()` respectively.
 
*/
@IBDesignable
open class TextFieldStack: TextStack, KeyboardResponderInputContainer {
    
    
    // MARK: - Properties
 
    /// The whitespace trimmed text entered into `textField`.
    override open var text:String? {
        get {
            return textField.text?.whitespaceTrimmedString()
        } set {
            textField.text = newValue?.whitespaceTrimmedString()
            configurePlaceholder()
        }
    }
    
    /// Sets the `enabled` property of `textField`.
    open override var enabled:Bool {
        didSet {
            textField.isEnabled = enabled
            
            configurePlaceholder()
            configureUnderline()
            
            stackView.invalidateIntrinsicContentSize()
            stackView.setNeedsLayout()
        }
    }
    
    /// The `UITextField` the user interacts with. Text should be set using the `text` property rather than directly setting it on this variable.
    open let textField:UITextField
    
    fileprivate var textBeginObserver:NotificationObserver?
    fileprivate var textEndObserver:NotificationObserver?
    
    /// The component to use with a [`KeyboardResponder`](https://github.com/thedistance/KeyboardResponder).
    open var inputComponent: KeyboardResponderInputType {
        return .textField(textField)
    }
    
    /// Optional variable that retains a reference to a `UIPickerViewDataController` if one is requried.
    var pickerController:UIPickerViewDataController?
    
    /// Optional variable that retains a reference to a `UIDatePickerDataController` if one is requried.
    var dateController:UIDatePickerDataController?
    
    
    // MARK: Initialiser
    
    /**
    
    Default initialiser.
    
    Subclasses can call through to super with arguments for each variable but configuration to override the defaults should be done after `super.init()`.
    
     - parameter textField: The `UITextField` to use as the center component of this `ErrorStack`.
     - parameter placeholderLabel: The `UILabel` or subclass to show the `placeholderText` when the user has already entered text. Default value is a new `UILabel`.
     - parameter underline: The `UIView` or subclass to use as an underline for `textComponent`.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`. The font for this labels is set to `UIFontTextStyleCaption2`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
     
    */
    public init(textField:UITextField = UITextField(),
        placeholderLabel:UILabel = UILabel(),
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView(),
        underline:UIView = UIView()) {
        
        // create the specific views
            self.textField = textField
        textField.borderStyle = .none
        
        super.init(textComponent: textField,
            placeholderLabel: placeholderLabel,
            errorLabel: errorLabel,
            errorImageView: errorImageView,
            iconImageView: iconImageView,
            underline: underline)
        
        textBeginObserver = NotificationObserver(name: NSNotification.Name.UITextFieldTextDidBeginEditing.rawValue, object: textField) { (note) -> () in
            self.configureUnderline()
            
            self.placeholderLabel.text = self.textField.placeholder ?? self.textField.attributedPlaceholder?.string
            self.placeholderLabel.isHidden = (self.hidesPlaceholderLabel && !self.textField.isFirstResponder)
            
            self.textField.placeholder = nil
        }
        
        textEndObserver = NotificationObserver(name: NSNotification.Name.UITextFieldTextDidEndEditing.rawValue, object: textField) { (note) -> () in
            self.configureUnderline()
            
            self.textField.placeholder = self.placeholderText
            self.placeholderLabel.isHidden = (self.textField.text?.isEmpty ?? true) || (self.hidesPlaceholderLabel && !self.textField.isFirstResponder)
            
            if self.liveValidation {
                _ = self.validateValue()
            }
        }
        
        addUnderlineForView(textField)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Configuration
    
    /// Shows / hides the `placeholderLabel` and `placeholder` text of the `textField` based on the currently entered text.
    open override func configurePlaceholder() {
        
        if placeholderLabel.text != placeholderText {
            placeholderLabel.text = placeholderText
        }
        
        if !textField.isFirstResponder {    
            
            if textField.placeholder != placeholderText {
                textField.placeholder = placeholderText
            }
            
            let placeholderHidden = (textField.text?.isEmpty ?? true) || (hidesPlaceholderLabel && !textField.isFirstResponder)
            if placeholderLabel.isHidden != placeholderHidden {
                placeholderLabel.isHidden = placeholderHidden
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyboardResponderRequestUpdateScrollNotification), object: textField)
            }
        } else {
            textField.placeholder = nil
        }
    }
    
    /// Sets the alpha of `underline` based on whether `textField` is first responder, and `enabled`.
    open func configureUnderline() {
        underline.alpha = textField.isFirstResponder ? 1.0 : (enabled ? 0.5 : 0.0)
    }
}
