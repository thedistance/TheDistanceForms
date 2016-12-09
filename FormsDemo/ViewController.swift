//
//  ViewController.swift
//  FormsDemo
//
//  Created by Josh Campion on 21/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import UIKit

import SwiftyJSON
import TheDistanceForms
import TheDistanceCore
import KeyboardResponder

class ViewController: UIViewController, FormContainer {
    
    var form:Form?
    var buttonTargets: [ObjectTarget<UIButton>] = []
    var keyboardResponder:KeyboardResponder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        view.addConstraints(NSLayoutConstraint.constraintsToAlign(view: scroll, to: view))
        
        guard let jsonURL = Bundle.main.url(forResource: "Form", withExtension: "json"),
            let form = addFormFromURL(jsonURL, toContainerView: scroll, withInsets: UIEdgeInsetsMake(16.0, 16.0, 16.0, 8.0))
            else { return }
        
        self.form = form
        keyboardResponder = setUpKeyboardResponder(onForm: form, withScrollView: scroll)
    }
    
    func buttonTappedForQuestion(_ question: FormQuestion) {
        print("Tapped button: \(question.key)")
        
        if question.key == "Submit" {
            submitTapped()
        }
    }
    
    func submitTapped() {
        
        guard let form = self.form else { return }
        
        let validation = form.validateForm()
        
        if validation.0 == .valid {
            
            let results = form.answersJSON()
            
            print(results)
        } else {
            
            let errors = validation.1.flatMap({ (question, result) -> String? in
                switch result {
                case .valid:
                    return nil
                case .invalid(let reason):
                    return "\(question.key): \(reason)"
                }
            })
            
            let errorString = errors.joined(separator: "\n")
            
            print("errors still in form:\n\(errorString)")
            
        }
    }
}

class RegisterViewController: UIViewController, FormContainer {
    
    var form:Form?
    var buttonTargets: [ObjectTarget<UIButton>] = []
    var keyboardResponder:KeyboardResponder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        view.addConstraints(NSLayoutConstraint.constraintsToAlign(view: scroll, to: view))
        
        guard let jsonURL = Bundle.main.url(forResource: "RegisterForm", withExtension: "json"),
            let form = addFormFromURL(jsonURL, ofType: RegisterForm.self, toContainerView: scroll, withInsets: UIEdgeInsetsMake(16.0, 16.0, 16.0, 8.0))
            else { return }
        
        self.form = form
        keyboardResponder = setUpKeyboardResponder(onForm: form, withScrollView: scroll)
    }
    
    func buttonTappedForQuestion(_ question: FormQuestion) { }
    
}

