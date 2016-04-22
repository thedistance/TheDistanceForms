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
        
        guard let jsonURL = NSBundle.mainBundle().URLForResource("Form", withExtension: "json"),
            let form = addFormFromURL(jsonURL, toContainerView: scroll, withInsets: UIEdgeInsetsMake(16.0, 16.0, 16.0, 8.0))
            else { return }
        
        self.form = form
        self.title = form.title
        
        keyboardResponder = setUpKeyboardResponder(onForm: form, withScrollView: scroll)
    }

    func buttonTappedForQuestion(question: FormQuestion) {
        print("Tapped button: \(question.key)")
    }
}

