//
//  TextViewStack.swift
//  CreatedStacks
//
//  Created by Josh Campion on 22/10/2015.
//  Copyright © The Distance. All rights reserved.
//

import Foundation

import TheDistanceCore
import StackView
import KeyboardResponder

/**
 
 `TextStack` subclass using a `UITextView`.
 
 `placeholderLabel` is configured in response to `UITextViewTextDidBeginEditingNotification`, UITextViewTextDidChangeNotification and `UITextViewTextDidEndEditingNotification`, which configure the placeholder and underline.
 
 */
@IBDesignable
public class TextViewStack: TextStack, KeyboardResponderInputContainer {
    
    // MARK: - Properties
    
    /// The whitespace trimmed text entered into `textView`.
    public override var text:String? {
        get {
            return textView.text == placeholderText ? "" : textView.text.whitespaceTrimmedString()
        }
        set {
            textView.text = newValue?.whitespaceTrimmedString()
        }
    }
    
    
    /// Adjusts `textView.textContainerInsets` according to `activeTextContainerInset` and `inactiveTextContainerInset`, and causes a layout pass to be called.
    public override var enabled:Bool {
        didSet {
            textView.editable = enabled
            textView.selectable = true
            textView.textContainerInset = enabled ? activeTextContainerInset : inactiveTextContainerInset
            
            configurePlaceholder()
            configureUnderline()
            
            stackView.invalidateIntrinsicContentSize()
            stackView.setNeedsLayout()
        }
    }
    
    /// The `UITextView` the user interacts with.
    public let textView:UITextView
    
    /// The `textContainerInset` applied to `textView` when `enabled == true`. Default is `(4,-5,4,-5)`.
    public var activeTextContainerInset = UIEdgeInsetsMake(4,-5,4,-5) {
        didSet {
            stackView.setNeedsLayout()
        }
    }
    
    /// The `textContainerInset` applied to `textView` when `enabled == false`. Default is `(0,-5,0,-5)`.
    public var inactiveTextContainerInset = UIEdgeInsetsMake(0,-5,0,-5) {
        didSet {
            stackView.setNeedsLayout()
        }
    }
    
    /// The colour applied to the text in the `textView` when the user has entered text.
    public var textColour:UIColor? {
        didSet {
            configurePlaceholder()
        }
    }
    
    /// The colour applied to the text in the `textView` when `placeholderText` is the text in the `textView`.
    public var placeholderTextColour:UIColor? {
        didSet {
            placeholderLabel.textColor = placeholderTextColour
            
            configurePlaceholder()
        }
    }
    
    // References to the observers. These are optional as they reference self within the handlers and so must be set after super.init(textComponent:)
    private var boundsObserver:ObjectObserver?
    private var textObserver:ObjectObserver?
    private var textViewObservers:[NotificationObserver]?
    
    /// The component to use with a `KeyboardResponder`.
    public var inputComponent: KeyboardResponderInputType {
        return .TextView(textView)
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
        textView.dataDetectorTypes = [.All]
        textView.scrollEnabled = false
        textView.contentInset = UIEdgeInsetsZero
        textView.textContainerInset = activeTextContainerInset
        textView.selectable = true
        
        textView.textContainer.heightTracksTextView = true
        
        // --
        // embed the text view in a wrapper scroll view to ensure UITextView's auto scroll is disabled.
        let wrapperScroll = UIScrollView()
        wrapperScroll.addSubview(textView)
        
        wrapperScroll.addConstraint(NSLayoutConstraint(item: wrapperScroll,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: textView,
            attribute: .Height,
            multiplier: 1.0,
            constant: 0.0))
        
        wrapperScroll.addConstraint(NSLayoutConstraint(item: wrapperScroll,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: textView,
            attribute: .Width,
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
        stack.axis = UILayoutConstraintAxis.Vertical
        stack.stackAlignment = .Fill
        //        stack.spacing = 0.0
        
        
        // add observers to the textview to update layout and configure the placeholders
        boundsObserver = ObjectObserver(keypath: "bounds", object: textView) { (keypath, object, change) -> () in
            
            if let obj = object as? UITextView,
                let changeDict = change
                where obj == self.textView && obj.isFirstResponder() {
                if let oldFrame = changeDict[NSKeyValueChangeOldKey]?.CGRectValue,
                    let newFrame = changeDict[NSKeyValueChangeNewKey]?.CGRectValue
                    where oldFrame.size.height != newFrame.size.height {
                    NSNotificationCenter.defaultCenter().postNotificationName(KeyboardResponderRequestUpdateScrollNotification, object: textView)
                    self.stackView.invalidateIntrinsicContentSize()
                }
            }
        }
        
        textObserver = ObjectObserver(keypath: "text", object: textView) { (_, _, _) -> () in
            self.configurePlaceholder()
        }
        
        let beginObserver = NotificationObserver(name: UITextViewTextDidBeginEditingNotification, object: textView) { (note) -> () in
            self.configureUnderline()
            self.configurePlaceholder()
        }
        
        let changeObserver = NotificationObserver(name: UITextViewTextDidChangeNotification, object: textView) { (note) -> () in
            self.configurePlaceholder()
        }
        
        let endObserver = NotificationObserver(name: UITextViewTextDidEndEditingNotification, object: textView) { (note) -> () in
            self.configureUnderline()
            self.configurePlaceholder()
            
            if self.liveValidation {
                self.validateValue()
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
    override public func configurePlaceholder() {
        
        if let placeholderText = self.placeholderText {
            
            placeholderLabel.text = placeholderText
            
            if textView.text.isEmpty && !textView.isFirstResponder() {
                textView.text = placeholderText
            } else if textIsPlaceholder() && textView.isFirstResponder() {
                textView.text = ""
            }
            
            textView.textColor = textIsPlaceholder() ? placeholderTextColour : textColour
            
            // show hide the placeholder label as appropriate
            let placeholderHidden = textIsPlaceholder() || (hidesPlaceholderLabel && !textView.isFirstResponder())
            if placeholderLabel.hidden != placeholderHidden {
                placeholderLabel.hidden = placeholderHidden
                
                if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_3 {
                
                    // perform layout. Due to the nested nature of text views this extra layout pass is sometimes necessary...
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.stackView.invalidateIntrinsicContentSize()
                        self.stackView.setNeedsUpdateConstraints()
                        self.stackView.setNeedsLayout()
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> () in
                    // post notification as showing / hiding the label changes the position of the text view. This is done in a new block to ensure the layout pass has occured and the frames have been updated.
                    NSNotificationCenter.defaultCenter().postNotificationName(KeyboardResponderRequestUpdateScrollNotification, object: self.textView)
                })
            }
        }
    }
    
    /// Sets the alpha of `underline` based on whether `textField` is first responder, and `enabled`.
    public func configureUnderline() {
        underline.alpha = textView.isFirstResponder() ? 1.0 : (enabled ? 0.5 : 0.0)
    }
}