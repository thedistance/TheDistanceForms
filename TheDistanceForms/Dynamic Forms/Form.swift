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

extension String: RawRepresentable {
    
    public typealias RawValue = String
    
    public var rawValue:String {
        return self
    }
    
    public init(rawValue: String) {
        self.init(rawValue)
    }
}

public class Form: KeyedValueElementContainer {
    
    public typealias KeyType = String
    
    public let title:String?
    
    public let questions:[FormQuestion]
    
    public var elements: [ValueElement] {
        return questions.map { $0.questionView }
    }
    
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
    
    public func elementForKey(key: String) -> ValueElement? {
        return questions.filter({ $0.key == key }).first?.questionView
    }
    
    public func validateForm() -> (ValidationResult, [(FormQuestion, ValidationResult)]) {
        
        let answerableQuestions = questions.filter { $0.type != .Button }
        let results = answerableQuestions.map { ($0, $0.questionView.validateValue()) }
        
        let totalResult = answerableQuestions
            .map { $0.questionView.validateValue() }
            .reduce(.Valid, combine: { $0 && $1 })
        
        return (totalResult, results)
    }
    
    /**
     - returns: A JSON dictionary of all the answers in the form. Questions not answered have a `.Null` JSON type.
    */
    public func answersJSON() -> JSON {
        
        let answerableQuestions = questions.filter { $0.type != .Button }
        
        let answers = answerableQuestions
            .map { (question) -> (String, JSON) in
            
            let key = question.key
            let value = question.questionView.getValue()
            
            let json:JSON
            if let valueObject = value as? AnyObject {
                json = JSON(valueObject)
            } else {
                json = JSON(NSNull())
            }
            
            return (key, json)
        }
        
        let answersDict = Dictionary(answers)
        
        return JSON(answersDict)
    }
}