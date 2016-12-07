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
    
    func addFormFromURL(_ jsonURL:URL, ofType formType:Form.Type, questionType:FormQuestion.Type, toContainerView:UIView, withInsets:UIEdgeInsets) -> Form?
    
    func setUpKeyboardResponder(_ responder:KeyboardResponder, withInputAccessoryView:KeyboardResponderInputAccessoryView?, onForm:Form, withScrollView:UIScrollView) -> KeyboardResponder
    
    func buttonTapped(_ sender:UIButton)
    
    func buttonTappedForQuestion(_ question:FormQuestion)
}

public extension FormContainer {
    
    public func setUpKeyboardResponder(_ responder:KeyboardResponder = KeyboardResponder(), withInputAccessoryView accessoryView:KeyboardResponderInputAccessoryView? = nil, onForm form:Form, withScrollView:UIScrollView) -> KeyboardResponder {
        
        responder.scrollContainer = withScrollView
        responder.inputAccessoryView = accessoryView ?? KeyboardResponderToolbar(navigationDelegate: responder)
        
        // set components
        responder.components = form.questions.flatMap { $0.questionView.inputComponent?.inputComponent }
        
        // add targets to the buttons
        for question in form.questions {
            
            if let qv = question.questionView,
                case FormQuestionView.button(let b) = qv {
                
                let target = ObjectTarget(control: b, forControlEvents: .touchUpInside, completion: buttonTapped)
                buttonTargets.append(target)
            }
        }
        
        return responder
    }
    
    public func buttonTapped(_ sender:UIButton) {
        
        let question = form?.questions.filter({
            if let qv = $0.questionView,
                case FormQuestionView.button(let b) = qv, b == sender {
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
    
    public func addFormFromURL(_ jsonURL:URL, ofType formType:Form.Type = Form.self, questionType:FormQuestion.Type = FormQuestion.self, toContainerView container:UIView, withInsets:UIEdgeInsets = UIEdgeInsets.zero) -> Form? {
        
        guard let data = try? Data(contentsOf: jsonURL),
            let form = formType.init(definition: JSON(data:data), questionType: questionType)
            else {
                return nil
        }
        
        form.formView.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(form.formView.view)
        container.addConstraints(NSLayoutConstraint.constraintsToAlign(view: form.formView.view, to: container, withInsets:withInsets))
        
        container.addConstraint(NSLayoutConstraint(item: form.formView.view,
            attribute: .width,
            relatedBy: .equal,
            toItem: container,
            attribute: .width,
            multiplier: 1.0,
            constant: -withInsets.totalXInset))
        
        if let title = form.title {
            self.title = title
        }
        
        return form
    }
}
