//
//  FormURLViewController.swift
//  Crew Calls
//
//  Created by Josh Campion on 02/08/2016.
//  Copyright © 2016 Virgin Trains East Cost. All rights reserved.
//

import UIKit

import SwiftyJSON
import TheDistanceForms
import TheDistanceCore
import KeyboardResponder
import TheDistanceForms
import TheDistanceFormsThemed


public class FormViewController: UIViewController, FormContainer {
    
    public var form:Form?
    public var buttonTargets: [ObjectTarget<UIButton>] = []
    public var keyboardResponder:KeyboardResponder?
    
    public convenience init?(filename: String, inBundle: NSBundle = NSBundle.mainBundle(), questionType: FormQuestion.Type = FormQuestion.self) {
        
        guard let url = inBundle.URLForResource(filename, withExtension: "json") else {
            return nil
        }
        
        self.init(url: url, questionType: questionType)
    }
    
    public init?(url: NSURL, questionType: FormQuestion.Type) {
        
        guard let data = NSData(contentsOfURL: url),
            let form = Form(definition: JSON(data: data), questionType: questionType) else {
                return nil
        }
        
        self.form = form
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view, typically from a nib.
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        view.addConstraints(NSLayoutConstraint.constraintsToAlign(view: scroll, to: view))
        
        if let formView = self.form?.createFormView().view {
            formView.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(formView)
            let insets = UIEdgeInsetsMake(16, 8, 16, 8)
            let constrs = NSLayoutConstraint.constraintsToAlign(view: formView, to: scroll, withInsets: insets)
            let width = NSLayoutConstraint(item: formView,
                                           attribute: .Width,
                                           relatedBy: .Equal,
                                           toItem: view,
                                           attribute: .Width,
                                           multiplier: 1.0,
                                           constant: -insets.totalXInset)
            NSLayoutConstraint.activateConstraints(constrs + [width])
        }
        
        keyboardResponder = setUpKeyboardResponder(onForm: form!, withScrollView: scroll)
    }
    
    public func buttonTappedForQuestion(question: FormQuestion) { }
}
