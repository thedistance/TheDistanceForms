//
//  BookingForm.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 26/04/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

import TheDistanceForms
import StackView
import SwiftyJSON
import TheDistanceCore

class EventForm: Form {
    
    private(set) var startObserver:ObjectObserver!
    
    required init?(definition: JSON, questionType: FormQuestion.Type) {
        super.init(definition: definition, questionType: questionType)
        
        guard let startView = questionForKey("start_date")?.questionView,
            case let .DateTime(startStack, startController) = startView,
            let endView = questionForKey("end_date")?.questionView,
            case let .DateTime(_, endController) = endView
            else {
                return nil
        }
        
        startController.datePicker.minimumDate = NSDate()
        endController.datePicker.minimumDate = NSDate()
        
        startObserver = ObjectObserver(keypath: "text", object: startStack.textField, completion: { (keypath, object, change) in
            endController.datePicker.minimumDate = startController.datePicker.date.dateByAddingTimeInterval(30 * 60)
        })
    }
    
    override func createFormView() -> StackView {
        
        guard let titleView = self.viewKeys["event_title"],
            let startView = self.viewKeys["start_date"],
            let endView = self.viewKeys["end_date"],
            let notesView = self.viewKeys["notes"]
            else { return CreateStackView([]) }
        
        var dateStack = CreateStackView([startView, endView])
        dateStack.spacing = 8.0
        dateStack.stackDistribution = .FillEqually
        
        var stack = CreateStackView([titleView, dateStack.view, notesView])
        stack.axis = .Vertical
        stack.spacing = 16.0
        
        return stack
    }
    
}