//
//  ErrorStack.swift
//  StackView
//
//  Created by Josh Campion on 09/02/2016.
//


import Foundation

import StackView

public class ErrorStack:CreatedStack {
    
    // MARK: Errors
    
    /// Sets the text of the `errorLabel` and shows / hides `errorLabel` and `errorImageView` based on whether this string `.isEmpty`. This can be configured manually or setting `self.validation` and calling `validateValue()`.
    public var errorText:String? {
        didSet {
            errorLabel.text = errorText
            errorLabel.hidden = errorText?.isEmpty ?? true
            errorImageView.hidden = errorLabel.hidden
            
            // TODO: Weak link to TextResponder Cocoapod
            // this will cause layout to occur which could affect the position of other text input items, after which the keyboard responder should be notified to update the scroll accordingly.
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
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
    public let centerStack:StackView
    
    /// A vertical `StackView` containing the `centerStack` and `errorLabel`.
    public let errorStack:StackView
    
    public init(centerComponent:UIView,
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView()) {
            
            self.errorLabel = errorLabel
            self.errorImageView = errorImageView
            self.iconImageView = iconImageView
            
            errorLabel.numberOfLines = 0
            errorLabel.hidden = true
            errorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            
            for iv in [errorImageView, iconImageView] {
                
                iv.contentMode = .ScaleAspectFit
                iv.backgroundColor = UIColor.clearColor()
                iv.hidden = true
                
                iv.setContentHuggingPriority(255, forAxis: .Horizontal)
                
                iv.setContentCompressionResistancePriority(760, forAxis: .Horizontal)
                iv.setContentCompressionResistancePriority(760, forAxis: .Vertical)
            }
            
            centerStack = CreateStackView([centerComponent, errorImageView])
            centerStack.axis = .Horizontal
            centerStack.spacing = 8.0
            
            errorStack = CreateStackView([centerStack.view, errorLabel])
            errorStack.axis = UILayoutConstraintAxis.Vertical
            errorStack.stackAlignment = .Fill
            errorStack.stackDistribution = .Fill
            errorStack.spacing = 8.0
            
            super.init(arrangedSubviews: [iconImageView, errorStack.view])
            stack.axis = .Horizontal
            stack.spacing = 8.0
    }
}