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

public class Form: KeyedValueElementContainer, KeyedView {
    
    public typealias KeyType = String
    
    public let title:String?
    
    public let questions:[FormQuestion]
    
    public var elements: [ValueElement] {
        return questions.map { $0.questionView }
    }
    
    public var viewKeys: [String : UIView] {
        return Dictionary(questions.map { ($0.key, $0.questionView.view ) })
    }
    
    public private(set) var formView:StackView
    
    required public init?(definition:JSON, questionType:FormQuestion.Type = FormQuestion.self) {
        
        guard let title = definition["title"].string,
            let questionsJSON = definition["questions"].array
            else {
                return nil
        }
        
        self.title = title
        
        // initialise as empty so can call other methods from this initialiser
        questions = questionsJSON.flatMap { questionType.init(json: $0) }
     
        formView = CreateStackView([])
        formView = createFormView()
    }
    
    public func questionForKey(key:String) -> FormQuestion? {
        return questions.filter { $0.key == key }
            .first
    }
    
    public func createFormView() -> StackView {
        
        var stack = CreateStackView(questions.map { $0.questionView.view })
        stack.axis = .Vertical
        stack.stackDistribution = .Fill
        stack.stackAlignment = .Fill
        stack.spacing = 26.0

        return stack
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