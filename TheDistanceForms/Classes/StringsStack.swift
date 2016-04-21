//
//  StringsStack.swift
//  Pods
//
//  Created by Josh Campion on 10/01/2016.
//
//

import UIKit

/*
public class LabelStack<LabelType:UILabel>: CreatedStack {
    
    public let labels:[LabelType]
    
    public init(labelCount:Int, strings:[String?] = [String?]()) {
        
        var labels = [LabelType]()
        labels.reserveCapacity(labelCount)
        
        for l in 0..<labelCount {
            
            let label = LabelType.init()
            labels.append(label)
            if l < strings.count {
                label.text = strings[l]
            }
        }
        
        self.labels = labels
        
        super.init(arrangedSubviews: labels)
        
        stack.axis = .Vertical
        stack.spacing = 8.0
    }
    
}

public class SubtitledStack<LabelType:UILabel>: LabelStack<LabelType> {
    
    public var titleLabel:LabelType {
        return labels[0]
    }
    
    public var subtitleLabel:LabelType {
        return labels[1]
    }
    
    public init(title:String? = nil, subtitle:String? = nil) {
        super.init(labelCount: 2, strings:[title, subtitle])
    }
}
*/

/// Typealias for easy creation of the most common `GenericStringsStack`, with `UILabel`.
public typealias StringsStack = GenericStringsStack<UILabel>

/// Class to create a simple stack of strings of any subclass of `UILabel`. The total number of labels created cannot be changed.
public class GenericStringsStack<LabelClass:UILabel>:CreatedStack {
    
    /// The labels created from `init(strings:)`. These cannot be changed after created but can be modified.
    public let labels:[LabelClass]
    
    /**
     
     Creates `labels` as an array of `LabelClass` and assigns the appropriate text.
     
     - paramter strings: The text for each label to be created.
    */
    public init(strings:[String]) {
        
        labels = strings.map {
            let lab = LabelClass()
            lab.text = $0
            return lab
        }
        
        super.init(arrangedSubviews:labels)
        
        stack.axis = .Vertical
        stack.spacing = 8.0
    }
    
    /**
     
     Creates `labels` as an array of `LabelClass` and assigns the appropriate attributed text.
     
     - paramter attributedStrings: The attributed text for each label to be created.
     */
    public init(attributedStrings:[NSAttributedString]) {
        
        labels = attributedStrings.map {
            let lab = LabelClass()
            lab.attributedText = $0
            return lab
        }
        
        super.init(arrangedSubviews:labels)
        
        stack.axis = .Vertical
        stack.spacing = 8.0
    }
}