//
//  SwitchStack.swift
//  Pods
//
//  Created by Josh Campion on 10/02/2016.
//
//

import Foundation
import StackView

public class SwitchStack: ErrorStack, ValueElement {
    
    public let titleLabel:UILabel
    public let subtitleLabel:UILabel
    
    public let switchControl:UISwitch
    
    public var validation:Validation<Bool>?
    
    public init(switchControl:UISwitch,
        titleLabel:UILabel = UILabel(),
        subtitleLabel:UILabel = UILabel(),
        errorLabel:UILabel = UILabel(),
        errorImageView:UIImageView = UIImageView(),
        iconImageView:UIImageView = UIImageView()) {
            
            self.switchControl = switchControl
            
            self.titleLabel = titleLabel
            self.subtitleLabel = subtitleLabel
            
            var textStack = CreateStackView([self.titleLabel, self.subtitleLabel])
            textStack.axis = .Vertical
            textStack.spacing = 4.0
            
            var switchStack = CreateStackView([textStack.view, self.switchControl])
            switchStack.axis = .Horizontal
            switchStack.spacing = 8.0
            switchStack.stackAlignment = .Center
            
            super.init(centerComponent: switchStack.view,
                errorLabel: errorLabel,
                errorImageView: errorImageView,
                iconImageView: iconImageView)
    }
    
    public func getValue() -> Any? {
        return switchControl.on
    }
    
    public func setValue<T>(value: T?) -> Bool {
        
        if let on = value as? Bool {
            switchControl.on = on
            return true
        } else {
            return false
        }
    }
    
    public func validateValue() -> ValidationResult {
        return validation?.validate(value: switchControl.on) ?? .Valid
    }
}