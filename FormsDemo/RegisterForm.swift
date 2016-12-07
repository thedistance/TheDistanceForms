//
//  RegisterForm.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 26/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import TDStackView
import SwiftyJSON
import TheDistanceCore

class RegisterForm: Form {
    
    required init?(definition: JSON, questionType: FormQuestion.Type) {
        super.init(definition: definition, questionType: questionType)
        
        guard let passwordView = questionForKey("password")?.questionView,
            case let .TextSingle(passwordStack) = passwordView,
            let confirmView = questionForKey("confirm_password")?.questionView,
            case let .TextSingle(confirmStack) = confirmView
            else {
                return nil
        }
        
        confirmStack.validation = Validation(message: "Your passwords must match.", validation: { (value) -> Bool in
            return value == passwordStack.text
        })
    }
    
    override func createFormView() -> StackView {
        
        guard let titleView = viewKeys["title"],
            let firstView = viewKeys["first_name"],
            let lastView = viewKeys["last_name"],
            let emailView = viewKeys["email"],
            let passwordView = viewKeys["password"],
            let confirmView = viewKeys["confirm_password"],
            let signUpView = viewKeys["sign_up"]
            else { return super.createFormView() }
        
        titleView.setContentHuggingPriority(255, forAxis: .Horizontal)
        
        var nameStack = CreateStackView([firstView, lastView])
        nameStack.spacing = 8.0
        nameStack.stackDistribution = .FillEqually
        
        var wholeNameStack = CreateStackView([titleView, nameStack.view])
        wholeNameStack.spacing = 8.0
        
        var completeStack = CreateStackView([wholeNameStack.view, emailView, passwordView, confirmView, signUpView])
        completeStack.axis = .Vertical
        completeStack.spacing = 16.0
        
        return completeStack
    }
}
