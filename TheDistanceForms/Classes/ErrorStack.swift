//
//  ErrorStack.swift
//  StackView
//
//  Created by Josh Campion on 09/02/2016.
//


import Foundation

import TDStackView

/**
 
 Abstract class that shows an icon, error label and error image around a given center component view. This class has convenience properties for the `errorText` which will then set `hidden` of the error label and image view. This is the core view of all form components that can show errors.
 
 - seealso: `TextStack`
 - seealso: `TextFieldStack`
 - seealso: `TextViewStack`
 - seealso: `SwitchStack`
 - seealso: `SegmentedTextFieldStack`
 
 */
open class ErrorStack:CreatedStack {
    
    // MARK: Errors
    
    /// Sets the text of the `errorLabel` and shows / hides `errorLabel` and `errorImageView` based on whether this string `.isEmpty`. This can be configured manually or setting `self.validation` and calling `validateValue()`.
    open var errorText:String? {
        didSet {
            errorLabel.text = errorText
            errorLabel.isHidden = errorText?.isEmpty ?? true
            errorImageView.isHidden = errorLabel.isHidden
            
            // TODO: Weak link to TextResponder Cocoapod
            // this will cause layout to occur which could affect the position of other text input items, after which the keyboard responder should be notified to update the scroll accordingly.
            DispatchQueue.main.async { () -> Void in
                // NSNotificationCenter.defaultCenter().postNotificationName(KeyboardResponderRequestUpdateScrollNotification, object: nil)
            }
        }
    }
    
    /// The label showing the error associated with the user's input. The text for this label should be set through the `errorText` property, which configures properties such as showing and hiding the label.
    public let errorLabel:UILabel
    
    /// The `UIImageView` to show an error icon centered on the text input if there is an error.
    public let errorImageView:UIImageView
    
    /// The `UIImageView` to show an icon aligned to the left of the text input.
    public let iconImageView:UIImageView
    
    /// A horizontal `StackView` containing the `errorImageView` and `centerComponent` from the default initialiser
    open var centerStack: UIStackView
    
    /// A vertical `StackView` containing the `centerStack` and `errorLabel`.
    open var errorStack: UIStackView
    
    /**
     
     Default initialiser. Creates the necessary views as sub-stacks. It has many optional parameters to allow for customisation using custom subclasses, perhaps a class which configures the components to match your apps branding.
     
     - seealso: TheDistanceFormsThemed
     
     - parameter centerComponent: The view to use that is supplemented with an icon, error label and error image.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
     
    */
    public init(centerComponent:UIView,
                errorLabel:UILabel = UILabel(),
                errorImageView:UIImageView = UIImageView(),
                iconImageView:UIImageView = UIImageView()) {
        
        self.errorLabel = errorLabel
        self.errorImageView = errorImageView
        self.iconImageView = iconImageView
        
        if errorImageView.image == nil {
           errorImageView.image = UIImage(named: "ic_warning", in: Bundle(for: ErrorStack.self), compatibleWith: nil)
        }
        
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        
        for iv in [errorImageView, iconImageView] {
            
            iv.contentMode = .scaleAspectFit
            iv.backgroundColor = UIColor.clear
            iv.isHidden = true
            
            iv.setContentHuggingPriority(UILayoutPriority(rawValue: 255), for: .horizontal)
            
            iv.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 760), for: .horizontal)
            iv.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 760), for: .vertical)
        }
        
        centerStack = CreateStackView([centerComponent, errorImageView])
        centerStack.axis = .horizontal
        centerStack.spacing = 8.0
        
        errorStack = CreateStackView([centerStack, errorLabel])
        errorStack.axis = .vertical
        errorStack.alignment = .fill
        errorStack.distribution = .fill
        errorStack.spacing = 8.0
        
        super.init(arrangedSubviews: [iconImageView, errorStack])
        
        /*
         
         // this layout should work but doesn't due to a bug in UIStackView
         
         errorStack = CreateStackView([errorImageView, errorLabel])
         errorStack.axis = .Horizontal
         errorStack.spacing = 8.0
         
         centerStack = CreateStackView([centerComponent, errorStack.view])
         centerStack.axis = UILayoutConstraintAxis.Vertical
         centerStack.stackAlignment = .Fill
         centerStack.stackDistribution = .Fill
         centerStack.spacing = 8.0
         
         super.init(arrangedSubviews: [iconImageView, centerStack.view])
        */
        
        
        stack.axis = .horizontal
        stack.spacing = 8.0
    }
}
