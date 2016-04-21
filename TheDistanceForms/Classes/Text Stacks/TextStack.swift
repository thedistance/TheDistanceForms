//
//  TextStack.swift
//  StackView
//
//  Created by Josh Campion on 22/10/2015.
//

import Foundation
import TheDistanceCore
import StackView

/**

Abstract parent class to contain the common elements and logic shared between `ErrorTextField` and `TextStack`. These show an editable text component with a placeholder, icon, optional error label and error image.

- seealso:
`TextFieldStack`

`TextViewStack`

*/
public class TextStack: ErrorStack {
    
    // MARK: - Properties
    
    /// Stylistic view for underlining the text component. Subclasses are responsible for adding this using `addUnderlineToView(_:withInsets:)`.
    public let underline:UIView
    
    // MARK: Form Stack

    /// Should return the whitespace trimmed value of the text component.
    public var text:String? {
        // this is an empty computed property as we cannot override a stored property with a computed property based on the text component of the subclass
        get {
            return nil
        }
        set { }
    }
    
    /// If `true`, the validation is checked after the text elements resigns first responder status. Default is `true`.
    public var liveValidation:Bool = true
    
    /// Validation object to allow this to be a `ValueElement`. The value is the `text` property.
    public var validation:Validation<String>? // Stored properties cannot currently go in an extension
    
    // MARK: Placeholder Variables
    
    private var _placeholderText:String?
    
    /// This should be the placeholder text when the text is empty and when the user begins editing or the text is set to something other than this string, this becomes the text in the `placeholderLabel`.
    public var placeholderText:String? {
        get {
            return _placeholderText
        }
        set {
            
            if let newPlaceholder = newValue {
                
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
    
    /// The label that shows the placeholder content once the user is editting or text is showing. This is force unwrapped to allow subclasses to provide a different `UILabel` subclass in `init()` before calling through to super, where the default implementation can assigns a `UILabel`.
    public let placeholderLabel:UILabel
    
    /// Flag to determine whether the placeholder label should appear when text has been entered into the text element.
    public var hidesPlaceholderLabel:Bool = false {
        didSet {
            if oldValue != hidesPlaceholderLabel {
                configurePlaceholder()
            }
        }
    }
    
    
    
    // MARK: - Metods

    /**
    
     Creates and configures the shared views `placeholderLabel`, `errorLabel`, `iconImageView` and `errorImageView` with the types provided in the optional arguments. Calls through to `init(arrangedSubviews:)` with the `textComponent` in the `centerStack`.
    
    
     - parameter textComponent: The view the user will interact with. See `TextFieldStack` and `TextViewStack`.
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
            placeholderLabel.hidden = true
            placeholderLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
            
            var contentStack = CreateStackView([placeholderLabel, textComponent])
            contentStack.axis = .Vertical
            contentStack.spacing = 8.0
            
            super.init(centerComponent: contentStack.view,
                errorLabel: errorLabel,
                errorImageView: errorImageView,
                iconImageView: iconImageView)
    }
     
    /**
    
    Adds `underline` to `stackView` bottom aligned to a given view with given insets.
    
    - parameter view: The view to align the newly created `underline` to.
    - parameter withInsets: The insets to align the newly created `underline` to `view` with.
    
    */
    public func addUnderlineForView(view:UIView, withInsets:UIEdgeInsets = UIEdgeInsetsZero) {
        
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor.blackColor()
        
        stackView.addSubview(underline)
        
        underline.addConstraints(NSLayoutConstraint.constraintsToSize(underline, toWidth: nil, andHeight: 1.0))
        
        // align underline left, bottom, right
        let constrs = NSLayoutConstraint.constraintsToAlign(view: underline, to: view, withInsets: withInsets)
        stackView.addConstraints(Array(constrs[1...3]))
    }
    
    /// To be overridden by sub classes to show / hide the placeholder correctly.
    public func configurePlaceholder() { }
    
}
