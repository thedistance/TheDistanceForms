//
//  Form.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 21/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation
import SwiftyJSON
import StackView

public class Form {
    
    public let title:String?
    
    public let questions:[FormQuestion]
    
    public let formView:StackView
    
    public init?(definition:JSON) {
        
        guard let title = definition["title"].string,
            let questionsJSON = definition["questions"].array
            else {
                return nil
        }
        
        self.title = title
        
        // initialise as empty so can call other methods from this initialiser
        questions = questionsJSON.flatMap { FormQuestion(json: $0) }
        
        formView = CreateStackView(questions.map { $0.questionView.view })
        formView.axis = .Vertical
        formView.stackDistribution = .Fill
        formView.stackAlignment = .Fill
        formView.spacing = 26.0
    }
    
    func buttonTapped(sender: UIButton) {
        
        
        
    }
}