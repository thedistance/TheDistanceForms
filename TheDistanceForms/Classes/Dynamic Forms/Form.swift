//
//  Form.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 21/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation
import SwiftyJSON
import TDStackView
import KeyboardResponder

let ServerDateFormatter: DateFormatter = {
    return DateFormatter.newServerFormatter()
}()

extension DateFormatter {
    
    
    /// - returns: An `NSDateFormatter` with a format string `"yyyy-MM-dd'T'hh:mm:ss"`, with the correct time zone and locale to read and print dates in UTC.
    public class func newServerFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        return formatter
    }
    
}

extension String: RawRepresentable {
    
    public typealias RawValue = String
    
    public var rawValue:String {
        return self
    }
    
    public init(rawValue: String) {
        self.init(rawValue)!
    }
}

open class Form: KeyedValueElementContainer, KeyedView {
    
    public typealias KeyType = String
    
    open let title:String?
    
    open let questions:[FormQuestion]
    
    open var elements: [ValueElement] {
        return questions.map { $0.questionView }
    }
    
    open var viewKeys: [String : UIView] {
        return Dictionary(questions.map { ($0.key, $0.questionView.view ) })
    }
    
    open fileprivate(set) var formView:StackView
    
    convenience public init?(filename: String, inBundle: Bundle = Bundle.main, questionType: FormQuestion.Type = FormQuestion.self) {
        
        guard let url = inBundle.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                return nil
        }
        
        self.init(definition: JSON(data: data), questionType: questionType)
    }
    
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
    
    /**
     
     Convenience method for getting all of the inputs for this form to be used with a `KeyboardResponder`. Subclasses can override this if inputs are not part of the `questions` array. Such inputs will not be validated and will not be included in the answers JSON.
     
     */
    open func inputComponents() -> [KeyboardResponderInputType] {
        return questions.flatMap { $0.questionView.inputComponent?.inputComponent }
    }
    
    open func questionForKey(_ key:String) -> FormQuestion? {
        return questions.filter { $0.key == key }
            .first
    }
    
    open func createFormView() -> StackView {
        
        var stack = CreateStackView(questions.map { $0.questionView.view })
        stack.axis = .vertical
        stack.stackDistribution = .fill
        stack.stackAlignment = .fill
        stack.spacing = 26.0
        
        return stack
    }
    
    open func elementForKey(_ key: String) -> ValueElement? {
        return questions.filter({ $0.key == key }).first?.questionView
    }
    
    /// Convenience method for getting the overall validation result alongside each individual result for each question
    open func validateForm() -> (ValidationResult, [(FormQuestion, ValidationResult)]) {
        
        let answerableQuestions = questions.filter { $0.type != .button }
        let results = answerableQuestions.map { ($0, $0.questionView.validateValue()) }
        
        let totalResult = answerableQuestions
            .map { $0.questionView.validateValue() }
            .reduce(.valid, { $0 && $1 })
        
        return (totalResult, results)
    }
    
    /**
     - returns: A JSON dictionary of all the answers in the form. Questions not answered have a `.Null` JSON type.
     */
    open func answersJSON() -> JSON {
        
        let answerableQuestions = questions.filter { $0.type != .button }
        
        let answers = answerableQuestions
            .map { (question) -> (String, JSON) in
                
                let key = question.key
                let value = question.questionView.getValue()
                
                let json:JSON
                if let date = value as? Date {
                    json = JSON(ServerDateFormatter.string(from: date))
                } else if let valueObject = value {
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
