//
//  TextStack.swift
//  StackView
//
//  Created by Josh Campion on 22/10/2015.
//

import Foundation
import TheDistanceCore
import TDStackView

/**

`ErrorStack` subclass to contain the common elements and logic shared between `TextFieldStack` and `TextViewStack`. These show an editable text component with a placeholder, icon, optional error label and error image.

 - seealso: `TextFieldStack`
 - seealso: `TextViewStack`

*/
open class TextStack: ErrorStack, ValueElement {
    
    // MARK: - Properties
    
    /// Stylistic view for underlining the text component. Subclasses are responsible for adding this using `addUnderlineToView(_:withInsets:)`.
    open let underline:UIView
    
    // MARK: Form Stack

    /**
     
     Should return the whitespace trimmed value of the text component.
     
     - note: This is an empty computed property as we cannot override a stored property with a computed property based on the text component of the subclass
    */
    open var text:String? {
        // this is an empty computed property as we cannot override a stored property with a computed property based on the text component of the subclass
        get {
            return nil
        }
        set {
            configurePlaceholder()
        }
    }
    
    /// If `true`, the validation is checked after the text elements resigns first responder status. Default is `true`.
    open var liveValidation:Bool = true
    
    /// Validation object to allow this to be a `ValueElement`. The value is the `text` property.
    open var validation:Validation<String>? // Stored properties cannot currently go in an extension
    
    /// Flag to determine whether user interaction is enabled for the text component. Resetting this should configure the placeholder and underline for their enabled state, and causes a layout pass to be called.
    open var enabled:Bool = true
    
    // MARK: Placeholder Variables
    
    fileprivate var _placeholderText:String?
    
    /**
     
     This should be the placeholder text when the text is empty and when the user begins editing or the text is set to something other than this string, the `placeholderLabel` set to this text becomes visible.
     
     - seealso `configurePlaceholder()`
    */
    open var placeholderText:String? {
        get {
            return _placeholderText
        }
        set {
            
            if let newPlaceholder = newValue {
                
                // append an invisible character that the user cannot input themselves to prevent the user's entered text being blanked out if they enter the same text as this variable.
                if _placeholderText != newPlaceholder + "\u{00A0}" {
                    _placeholderText = newPlaceholder + "\u{00A0}"
                    configurePlaceholder()
                }
            } else {
                if _placeholderText != nil {
                    _placeholderText = nil
                    configurePlaceholder()
                }
            }
        }
    }
    
    /// The label that shows the placeholder content once the user is editting or text is showing.
    open let placeholderLabel:UILabel
    
    /// Flag to determine whether the placeholder label should appear when text has been entered into the text element.
    open var hidesPlaceholderLabel:Bool = false {
        didSet {
            if oldValue != hidesPlaceholderLabel {
                configurePlaceholder()
            }
        }
    }
    
    
    // MARK: - Metods

    /**
    
     Creates and configures the shared views `placeholderLabel`, `errorLabel`, `iconImageView` and `errorImageView` with the types provided in the optional arguments. Calls through to `init(arrangedSubviews:)` with the `textComponent` in the `centerStack`.
    
    
     - parameter textComponent: The view the user will interact with.
     - parameter placeholderLabel: The `UILabel` or subclass to show the `placeholderText` when the user has already entered text. Default value is a new `UILabel`.
     - parameter underline: The `UIView` or subclass to use as an underline for `textComponent`.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`. The font for this labels is set to `UIFontTextStyleCaption2`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
    */
    public init(textComponent:UIView,
        placeholderLabel:UILabel = UILabel(),
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView(),
        underline:UIView = UIView()) {
        
            // create the views allowing subclasses to return a different class
            self.placeholderLabel = placeholderLabel
            self.underline = underline
            
            placeholderLabel.numberOfLines = 0
            placeholderLabel.isHidden = true
            placeholderLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
            
            var contentStack = CreateStackView([placeholderLabel, textComponent])
            contentStack.axis = .vertical
            contentStack.spacing = 8.0
            
            super.init(centerComponent: contentStack.view,
                errorLabel: errorLabel,
                errorImageView: errorImageView,
                iconImageView: iconImageView)
    }
     
    /**
    
    Adds `underline` to `stackView`, bottom aligned to a given view with given insets.
    
    - parameter view: The view to align `underline` to.
    - parameter withInsets: The insets to align the newly created `underline` to `view` with. Default value is `UIEdgeInsetsZero`.
    
    */
    open func addUnderlineForView(_ view:UIView, withInsets:UIEdgeInsets = UIEdgeInsets.zero) {
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor.black
        
        stackView.addSubview(underline)
        
        underline.addConstraints(NSLayoutConstraint.constraintsToSize(underline, toWidth: nil, andHeight: 1.0))
        
        // align underline left, bottom, right
        let constrs = NSLayoutConstraint.constraintsToAlign(view: underline, to: view, withInsets: withInsets)
        stackView.addConstraints(Array(constrs[1...3]))
    }
    
    /// To be overridden by sub classes to show / hide the placeholder correctly.
    open func configurePlaceholder() { }
    
    // MARK: - ValueElement
    
    /**
     
     Sets `text` to the given value if and only if it is a String that passes the `validation`.
     
     - parameter value: The object to set as `text`. This should be a String.
     
     - returns: `true` if the the given value is set as `text`, `false` otherwise.
     
    */
    open func setValue<T>(_ value: T?) -> Bool {
        if let str = (value as? String)?.whitespaceTrimmedString() {
            
            if let result = validation?.validate(str), case .valid = result  {
                text = str
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    open func getValue() -> Any? {
        return text
    }
    
    /**
     
     Calls `validation.validate(_:)` on `text` setting the `errorText` as appropriate.
     
     - returns: `.Valid` if `text` passes validation, `.Invalid(let message)` otherwise, where message is that returned by `self.validation`.
     */
    open func validateValue() -> ValidationResult {
        
        let newText = text
        let result = validation?.validate(newText) ?? .valid
        
        text = newText
        
        if case .invalid(let message) = result {
            errorText = message
        } else {
            errorText = nil
        }
        
        return result
    }
}


