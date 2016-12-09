//
//  FormsTableViewController.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 26/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import UIKit

import SwiftyJSON
import TheDistanceForms
import TheDistanceCore
import KeyboardResponder

class EventFormViewController: UIViewController, FormContainer {

    @IBOutlet weak var scrollContainer:UIScrollView!
    @IBOutlet weak var formContainer:UIView!
    
    var form:Form?
    var buttonTargets: [ObjectTarget<UIButton>] = []
    var keyboardResponder:KeyboardResponder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let jsonURL = Bundle.main.url(forResource: "EventForm", withExtension: "json"),
            let form = addFormFromURL(jsonURL, ofType: EventForm.self, toContainerView: formContainer, withInsets: UIEdgeInsets.zero)
            else { return }
        
        self.form = form
        keyboardResponder = setUpKeyboardResponder(onForm: form, withScrollView: scrollContainer)
    }

    func buttonTappedForQuestion(_ question: FormQuestion) {
        
    }
}

