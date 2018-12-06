//
//  SwitchStack.swift
//  Pods
//
//  Created by Josh Campion on 10/02/2016.
//
//

import Foundation
import TDStackView

/**
 
 `ErrorStack` subclass showing with extra UI for a title, subtitle and a switch. Conforms to `ValueElement` to represent boolean choices in a `Form`.
 
 */
open class SwitchStack: ErrorStack, ValueElement {
    
    /// `UILabel` to show the title. Defaults to `UIFontTextStyleHeadline`.
    public let titleLabel:UILabel
    
    /// `UILabel` to show subtitle title. Defaults to `UIFontTextStyleSubheadline`.
    public let subtitleLabel:UILabel
    
    /// The switch the user will interact with.
    public let switchControl:UISwitch
    
    /// `Validation` used for `ValueElement` conformation.
    open var validation:Validation<Bool>?
    
    /**
     
     Default initialiser. Creates a stack of the switch and labels and sets this as the center component of is `ErrorStack`.
     
     Subclasses can call through to super with arguments for each variable but configuration to override the defaults should be done after `super.init()`.
     
     - parameter switchControl: The `UISwitch` the user interacts with, and whose value is used for validation.
     - titleLabel: The label the title will be shown on. Default font is `UIFontTextStyleHeadline`.
     - subtitleLabel: The label the title will be shown on. Default font is `UIFontTextStyleSubheadline`.
     - parameter errorLabel: The `UILabel` or subclass to use to show the error text. Default value is a new `UILabel`. The font for this labels is set to `UIFontTextStyleCaption2`.
     - parameter iconImageView: The `UIImageView` or subclass to use to show the icon. Default value is a new `UIImageView`.
     - parameter errorImageView: The `UIImageView` or subclass to use to show the error icon. Default value is a new `UIImageView`.
     
     */
    public init(switchControl:UISwitch,
                titleLabel:UILabel = UILabel(),
                subtitleLabel:UILabel = UILabel(),
                errorLabel:UILabel = UILabel(),
                errorImageView:UIImageView = UIImageView(),
                iconImageView:UIImageView = UIImageView()) {
        
        self.switchControl = switchControl
        
        self.titleLabel = titleLabel
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        
        self.subtitleLabel = subtitleLabel
        self.subtitleLabel.numberOfLines = 0
        self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        
        let textStack = CreateStackView([self.titleLabel, self.subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4.0
        
        let switchStack = CreateStackView([textStack, self.switchControl])
        switchStack.axis = .horizontal
        switchStack.spacing = 8.0
        switchStack.alignment = .center
        
        super.init(centerComponent: switchStack,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
        
        switchControl.addTarget(self, action: #selector(SwitchStack.switchTapped(_:)), for: .touchUpInside)        
    }
    
    // MARK: - ValueElement Methods
    
    /**
     
     `ValueElement` conformation.
     
     - returns: `Bool` for whether the switch is on or off.
     */
    open func getValue() -> Any? {
        return switchControl.isOn
    }
    
    /**
     
     `ValueElement` conformation. Sets the value of `switchControl.on` if `value` is a `Bool`.
     
     - parameter value: If this is a `Bool` the value of `switchControl.on` is set, otherwise this does nothing.
     - returns: `true` if value is a `Bool`, `false` otherwise.
     */
    open func setValue<T>(_ value: T?) -> Bool {
        
        if let on = value as? Bool {
            switchControl.isOn = on
            return true
        } else {
            return false
        }
    }
    
    /// `ValueElement` conformation. Uses the `validation` property to determine validity. If `validation` is `nil`, any value is `.Valid`.
    open func validateValue() -> ValidationResult {
        return validation?.validate(switchControl.isOn) ?? .valid
    }
    
    @objc open func switchTapped(_ sender: AnyObject?) {
        
        switchControl.willChangeValue(forKey: "on")
        switchControl.didChangeValue(forKey: "on")
        
    }
}
