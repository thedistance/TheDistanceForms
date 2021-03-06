//
//  ThemeViewController.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 27/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import UIKit

import SwiftyJSON
import TheDistanceForms
import TheDistanceCore
import KeyboardResponder
import TheDistanceForms
import TheDistanceFormsThemed

class ThemeFormViewController: UIViewController, FormContainer {
    
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
            let form = addFormFromURL(jsonURL, questionType: TKFormQuestion.self, toContainerView: scroll, withInsets: UIEdgeInsetsMake(16.0, 16.0, 16.0, 8.0))
            else { return }
        
        self.form = form
        keyboardResponder = setUpKeyboardResponder(onForm: form, withScrollView: scroll)
    }

    func buttonTappedForQuestion(_ question: FormQuestion) { }
}
