//
//  StackView.swift
//  StackView
//
//  Created by Josh Campion on 05/01/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation
import TZStackView

public enum StackViewAlignment:Int {
    case Fill
    case Leading
    static var Top = StackViewAlignment.Leading
    case FirstBaseline // valid for horizontal baseline only
    case Center
    case Trailing
    static var Bottom = StackViewAlignment.Trailing
    case LastBaseline // valid for horizontal baseline only
    
    public init(tz:TZStackViewAlignment) {
        
        switch tz {
        case .Fill:
            self = .Fill
        case .Leading:
            self = .Leading
        case .Top:
            self = .Top
        case .FirstBaseline:
            self = .FirstBaseline
        case .Center:
            self = .Center
        case .Trailing:
            self = .Trailing
        case .Bottom:
            self = .Bottom
        }
        
    }
    
    @available( iOS 9, *)
    public init(ui:UIStackViewAlignment) {
        
        switch ui {
        case .Fill:
            self = .Fill
        case .Leading:
            self = .Leading
        case .FirstBaseline:
            self = .FirstBaseline
        case .Center:
            self = .Center
        case .Trailing:
            self = .Trailing
        case .LastBaseline:
            self = .LastBaseline
        }
        
    }
    
    public func tzValue() -> TZStackViewAlignment {
        switch self {
        case .Fill:
            return .Fill
        case .Leading:
            return .Leading
        case .FirstBaseline:
            return .FirstBaseline
        case .Center:
            return .Center
        case .Trailing:
            return .Trailing
        case .LastBaseline:
            return .FirstBaseline
        }
        
    }
    
    @available( iOS 9, *)
    public func uiValue() -> UIStackViewAlignment {
        switch self {
        case .Fill:
            return .Fill
        case .Leading:
            return .Leading
        case .FirstBaseline:
            return .FirstBaseline
        case .Center:
            return .Center
        case .Trailing:
            return .Trailing
        case .LastBaseline:
            return .LastBaseline
        }
        
    }
    
}

public enum StackViewDistribution {
    case Fill
    case FillEqually
    case FillProportionally
    case EqualSpacing
    case EqualCentering
    
    public init(tz:TZStackViewDistribution) {
        
        switch tz {
        case .Fill:
            self = .Fill
        case .FillEqually:
            self = .FillEqually
        case .FillProportionally:
            self = .FillProportionally
        case .EqualSpacing:
            self = .EqualSpacing
        case .EqualCentering:
            self = .EqualCentering
        }
        
    }
    
    @available(iOS 9, *)
    public init(ui:UIStackViewDistribution) {
        
        switch ui {
        case .Fill:
            self = .Fill
        case .FillEqually:
            self = .FillEqually
        case .FillProportionally:
            self = .FillProportionally
        case .EqualSpacing:
            self = .EqualSpacing
        case .EqualCentering:
            self = .EqualCentering
        }
    }
    
    public func tzValue() -> TZStackViewDistribution {
        switch self {
        case .Fill:
            return .Fill
        case .FillEqually:
            return .FillEqually
        case .FillProportionally:
            return .FillProportionally
        case .EqualSpacing:
            return .EqualSpacing
        case .EqualCentering:
            return .EqualCentering
        }
    }
    
    @available(iOS 9, *)
    public func uiValue() -> UIStackViewDistribution {
        switch self {
        case .Fill:
            return .Fill
        case .FillEqually:
            return .FillEqually
        case .FillProportionally:
            return .FillProportionally
        case .EqualSpacing:
            return .EqualSpacing
        case .EqualCentering:
            return .EqualCentering
        }
    }
}

public protocol StackView {
    
    /// The `UIView` representation of this Stack. On iOS 8 this will be a `TZStackView`. On iOS 9 this will be a `UIStackView`.
    var view:UIView { get }
    
    // Managing Arranged Subviews
    
    func addArrangedSubview(view: UIView)
    
    var arrangedSubviews: [UIView] { get }
    
    func insertArrangedSubview(view: UIView, atIndex stackIndex: Int)
    
    func removeArrangedSubview(view: UIView)
    
    // Configuring The Layout
    
    var stackAlignment: StackViewAlignment { get set }
    
    var axis: UILayoutConstraintAxis { get set }
    
    // var baselineRelativeArrangement: Bool { get set }
    
    var stackDistribution: StackViewDistribution  { get set }
    
    var layoutMarginsRelativeArrangement: Bool  { get set }
    
    var spacing: CGFloat { get set }
    
}

public func CreateStackView(arrangedSubviews:[UIView]) -> StackView {
    
    if #available(iOS 9, *) {
        return UIStackView(arrangedSubviews: arrangedSubviews)
    } else {
        return TZStackView(arrangedSubviews: arrangedSubviews)
    }
}

extension TZStackView: StackView {
    
    public var view:UIView {
        return self
    }
    
    public var stackDistribution: StackViewDistribution {
        get {
            return StackViewDistribution(tz:distribution)
        }
        set {
            distribution = newValue.tzValue()
        }
        
    }
    
    public var stackAlignment: StackViewAlignment {
        get {
            return StackViewAlignment(tz:alignment)
        }
        set {
            alignment = newValue.tzValue()
        }
    }
}

@available(iOS 9, *)
extension UIStackView: StackView {
    
    public var view:UIView {
        return self
    }
    
    public var stackDistribution: StackViewDistribution {
        get {
            return StackViewDistribution(ui:distribution)
        }
        set {
            distribution = newValue.uiValue()
        }
        
    }
    
    public var stackAlignment: StackViewAlignment {
        get {
            return StackViewAlignment(ui:alignment)
        }
        set {
            alignment = newValue.uiValue()
        }
    }
}


