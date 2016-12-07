//
//  TextViewStack.swift
//  CreatedStacks
//
//  Created by Josh Campion on 22/10/2015.
//  Copyright © The Distance. All rights reserved.
//

import Foundation

import TheDistanceCore
import TDStackView
import KeyboardResponder

/**
 
 `TextStack` subclass using a `UITextView`.
 
 `placeholderLabel` is configured in response to `UITextViewTextDidBeginEditingNotification`, UITextViewTextDidChangeNotification and `UITextViewTextDidEndEditingNotification`, which configure the placeholder and underline.
 
 */
@IBDesignable
open class TextViewStack: TextStack, KeyboardResponderInputContainer {
    
    // MARK: - Properties
    
    /// The whitespace trimmed text entered into `textView`.
    open override var text:String? {
        get {
            return textView.text == placeholderText ? "" : textView.text.whitespaceTrimmedString()
        }
        set {
            textView.text = newValue?.whitespaceTrimmedString()
        }
    }
    
    
    /// Adjusts `textView.textContainerInsets` according to `activeTextContainerInset` and `inactiveTextContainerInset`, and causes a layout pass to be called.
    open override var enabled:Bool {
        didSet {
            textView.isEditable = enabled
            textView.isSelectable = true
            textView.textContainerInset = enabled ? activeTextContainerInset : inactiveTextContainerInset
            
            configurePlaceholder()
            configureUnderline()
            
            stackView.invalidateIntrinsicContentSize()
            stackView.setNeedsLayout()
        }
    }
    
    /// The `UITextView` the user interacts with.
    open let textView:UITextView
    
    /// The `textContainerInset` applied to `textView` when `enabled == true`. Default is `(4,-5,4,-5)`.
    open var activeTextContainerInset = UIEdgeInsetsMake(4,-5,4,-5) {
        didSet {
            stackView.setNeedsLayout()
        }
    }
    
    /// The `textContainerInset` applied to `textView` when `enabled == false`. Default is `(0,-5,0,-5)`.
    open var inactiveTextContainerInset = UIEdgeInsetsMake(0,-5,0,-5) {
        didSet {
            stackView.setNeedsLayout()
        }
    }
    
    /// The colour applied to the text in the `textView` when the user has entered text.
    open var textColour:UIColor? {
        didSet {
            configurePlaceholder()
        }
    }
    
    /// The colour applied to the text in the `textView` when `placeholderText` is the text in the `textView`.
    open var placeholderTextColour:UIColor? {
        didSet {
            placeholderLabel.textColor = placeholderTextColour
            
            configurePlaceholder()
        }
    }
    
    // References to the observers. These are optional as they reference self within the handlers and so must be set after super.init(textComponent:)
    fileprivate var boundsObserver:ObjectObserver?
    fileprivate var textObserver:ObjectObserver?
    fileprivate var textViewObservers:[NotificationObserver]?
    
    /// The component to use with a `KeyboardResponder`.
    open var inputComponent: KeyboardResponderInputType {
        return .textView(textView)
    }
    
    /**
     
     Default initialiser.
     
     Subclasses can call through to super with arguments for each variable but configuration to override the defaults should be done after `super.init()`.
     
     - parameter textView: The `UITextView` to use as the center component of this `ErrorStack`.
     - parameter placeholderLabel: The `UILabel` or subclass to show the `placeholderText` when the user has already entered text. Default value is a new `UILabel`.
     - parameter underline: The `UIView` or subclass to use as an underline for `textComponent`.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`. The font for this labels is set to `UIFontTextStyleCaption2`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
     
     */
    public init(textView:UITextView = UITextView(),
                placeholderLabel:UILabel = UILabel(),
                errorLabel:UILabel = UILabel(),
                errorImageView:UIImageView = UIImageView(),
                iconImageView:UIImageView = UIImageView(),
                underline:UIView = UIView()) {
        
        self.textView = textView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.dataDetectorTypes = [.all]
        textView.isScrollEnabled = false
        textView.contentInset = UIEdgeInsets.zero
        textView.textContainerInset = activeTextContainerInset
        textView.isSelectable = true
        
        textView.textContainer.heightTracksTextView = true
        
        // --
        // embed the text view in a wrapper scroll view to ensure UITextView's auto scroll is disabled.
        let wrapperScroll = UIScrollView()
        wrapperScroll.addSubview(textView)
        
        wrapperScroll.addConstraint(NSLayoutConstraint(item: wrapperScroll,
            attribute: .height,
            relatedBy: .equal,
            toItem: textView,
            attribute: .height,
            multiplier: 1.0,
            constant: 0.0))
        
        wrapperScroll.addConstraint(NSLayoutConstraint(item: wrapperScroll,
            attribute: .width,
            relatedBy: .equal,
            toItem: textView,
            attribute: .width,
            multiplier: 1.0,
            constant: 0.0))
        
        wrapperScroll.addConstraints(NSLayoutConstraint.constraintsToAlign(view: wrapperScroll, to: textView))
        
        // -- //
        
        super.init(textComponent: wrapperScroll,
                   placeholderLabel: placeholderLabel,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView,
                   underline: underline)
        
        
        addUnderlineForView(textView)
        
        // configure the stack
        stack.axis = UILayoutConstraintAxis.vertical
        stack.stackAlignment = .fill
        //        stack.spacing = 0.0
        
        
        // add observers to the textview to update layout and configure the placeholders
        boundsObserver = ObjectObserver(keypath: "bounds", object: textView) { (keypath, object, change) -> () in
            
            if let obj = object as? UITextView,
                let changeDict = change, obj == self.textView && obj.isFirstResponder {
                if let oldFrame = (changeDict[NSKeyValueChangeKey.oldKey] as AnyObject).cgRectValue,
                    let newFrame = (changeDict[NSKeyValueChangeKey.newKey] as AnyObject).cgRectValue, oldFrame.size.height != newFrame.size.height {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyboardResponderRequestUpdateScrollNotification), object: textView)
                    self.stackView.invalidateIntrinsicContentSize()
                }
            }
        }
        
        textObserver = ObjectObserver(keypath: "text", object: textView) { (_, _, _) -> () in
            self.configurePlaceholder()
        }
        
        let beginObserver = NotificationObserver(name: NSNotification.Name.UITextViewTextDidBeginEditing.rawValue, object: textView) { (note) -> () in
            self.configureUnderline()
            self.configurePlaceholder()
        }
        
        let changeObserver = NotificationObserver(name: NSNotification.Name.UITextViewTextDidChange.rawValue, object: textView) { (note) -> () in
            self.configurePlaceholder()
        }
        
        let endObserver = NotificationObserver(name: NSNotification.Name.UITextViewTextDidEndEditing.rawValue, object: textView) { (note) -> () in
            self.configureUnderline()
            self.configurePlaceholder()
            
            if self.liveValidation {
                _ = self.validateValue()
            }
        }
        
        textViewObservers = [beginObserver, changeObserver, endObserver]
    }
    
    /**
     
     Helper function.
     
     - returns: Whether the text of the text view equals the placeholder
    */
    func textIsPlaceholder() -> Bool {
        return textView.text == placeholderText
    }
    
    /// Shows / hides the `placeholderLabel` and sets the text of `textView` based on the currently entered text.
    override open func configurePlaceholder() {
        
        if let placeholderText = self.placeholderText {
            
            placeholderLabel.text = placeholderText
            
            if textView.text.isEmpty && !textView.isFirstResponder {
                textView.text = placeholderText
            } else if textIsPlaceholder() && textView.isFirstResponder {
                textView.text = ""
            }
            
            textView.textColor = textIsPlaceholder() ? placeholderTextColour : textColour
            
            // show hide the placeholder label as appropriate
            let placeholderHidden = textIsPlaceholder() || (hidesPlaceholderLabel && !textView.isFirstResponder)
            if placeholderLabel.isHidden != placeholderHidden {
                placeholderLabel.isHidden = placeholderHidden
                
                if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_3 {
                
                    // perform layout. Due to the nested nature of text views this extra layout pass is sometimes necessary...
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.stackView.invalidateIntrinsicContentSize()
                        self.stackView.setNeedsUpdateConstraints()
                        self.stackView.setNeedsLayout()
                    })
                }
                
                DispatchQueue.main.async(execute: { () -> () in
                    // post notification as showing / hiding the label changes the position of the text view. This is done in a new block to ensure the layout pass has occured and the frames have been updated.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyboardResponderRequestUpdateScrollNotification), object: self.textView)
                })
            }
        }
    }
    
    /// Sets the alpha of `underline` based on whether `textField` is first responder, and `enabled`.
    open func configureUnderline() {
        underline.alpha = textView.isFirstResponder ? 1.0 : (enabled ? 0.5 : 0.0)
    }
}
