//
//  FormContainer.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 22/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import UIKit

import KeyboardResponder
import SwiftyJSON
import TheDistanceCore

public protocol FormContainer: class {
    
    var form:Form? { get }
    var buttonTargets:[ObjectTarget<UIButton>] { get set }
    
    func addFormFromURL(jsonURL:NSURL, toContainerView:UIView, withInsets:UIEdgeInsets) -> Form?
    
    func setUpKeyboardResponder(responder:KeyboardResponder, withInputAccessoryView:KeyboardResponderInputAccessoryView?, onForm:Form, withScrollView:UIScrollView) -> KeyboardResponder
    
    func buttonTapped(sender:UIButton)
    
    func buttonTappedForQuestion(question:FormQuestion)
}

public extension FormContainer {
    
    public func setUpKeyboardResponder(responder:KeyboardResponder = KeyboardResponder(), withInputAccessoryView accessoryView:KeyboardResponderInputAccessoryView? = nil, onForm form:Form, withScrollView:UIScrollView) -> KeyboardResponder {
        
        responder.scrollContainer = withScrollView
        responder.inputAccessoryView = accessoryView ?? KeyboardResponderToolbar(navigationDelegate: responder)
        
        // set components
        responder.components = form.questions.flatMap { $0.questionView.inputComponent?.inputComponent }
        
        // add targets to the buttons
        for question in form.questions {
            
            if let qv = question.questionView,
                case FormQuestionView.Button(let b) = qv {
                
                let target = ObjectTarget(control: b, forControlEvents: .TouchUpInside, completion: buttonTapped)
                buttonTargets.append(target)
            }
        }
        
        return responder
    }
    
    public func buttonTapped(sender:UIButton) {
        
        let question = form?.questions.filter({
            if let qv = $0.questionView,
                case FormQuestionView.Button(let b) = qv
                where b == sender {
                return true
            }
            return false
        })
            .first
        
        if let q = question {
            buttonTappedForQuestion(q)
        }
    }
}

public extension FormContainer where Self:UIViewController {
    
    public func addFormFromURL(jsonURL:NSURL, toContainerView container:UIView, withInsets:UIEdgeInsets = UIEdgeInsetsZero) -> Form? {
        
        guard let data = NSData(contentsOfURL: jsonURL),
            let form = Form(definition: JSON(data:data))
            else {
                return nil
        }
        
        form.formView.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(form.formView.view)
        container.addConstraints(NSLayoutConstraint.constraintsToAlign(view: form.formView.view, to: container, withInsets:withInsets))
        
        container.addConstraint(NSLayoutConstraint(item: form.formView.view,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: container,
            attribute: .Width,
            multiplier: 1.0,
            constant: -withInsets.totalXInset))
        
        if let title = form.title {
            self.title = title
        }
        
        return form
    }
}