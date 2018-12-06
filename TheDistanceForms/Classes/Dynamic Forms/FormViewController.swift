//
//  FormURLViewController.swift
//  Crew Calls
//
//  Created by Josh Campion on 02/08/2016.
//  Copyright © 2016 Virgin Trains East Cost. All rights reserved.
//

import UIKit

import SwiftyJSON
import TheDistanceCore
import KeyboardResponder

open class FormViewController: UIViewController, FormContainer {
    
    open var form:Form?
    open var buttonTargets: [ObjectTarget<UIButton>] = []
    open var keyboardResponder:KeyboardResponder?
    
    public convenience init?(filename: String, inBundle: Bundle = Bundle.main, questionType: FormQuestion.Type = FormQuestion.self) {
        
        guard let url = inBundle.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        
        self.init(url: url, questionType: questionType)
    }
    
    public init?(url: URL, questionType: FormQuestion.Type) {
        
        guard let data = try? Data(contentsOf: url),
            let definition = try? JSON(data: data),
            let form = Form(definition: definition, questionType: questionType) else {
                return nil
        }
        
        self.form = form
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view, typically from a nib.
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        view.addConstraints(NSLayoutConstraint.constraintsToAlign(view: scroll, to: view))
        
        if let formView = self.form?.createFormView() {
            formView.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(formView)
            let insets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
            let constrs = NSLayoutConstraint.constraintsToAlign(view: formView, to: scroll, withInsets: insets)
            let width = NSLayoutConstraint(item: formView,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .width,
                                           multiplier: 1.0,
                                           constant: -insets.totalXInset)
            NSLayoutConstraint.activate(constrs + [width])
        }
        
        keyboardResponder = setUpKeyboardResponder(onForm: form!, withScrollView: scroll)
    }
    
    open func buttonTappedForQuestion(_ question: FormQuestion) { }
}
