//
//  UIDatePickerDataController.swift
//  TheDistanceForms
//
//  Created by Josh Campion on 07/06/2016.
//  Copyright © 2016 The Distance. All rights reserved.
//

import Foundation

/**
 
 Convenience class for showing a `UIDatePicker` as the `inputView` associated with a `UITextField`.
 
 This class contains boilerplate methods for populating the text of the `UITextField` with the selected date in the `UIDatePicker`. The text is formatted using the `dateFormatter` property.
 
 - seealso: `UIPickerViewDataController`
 
 */
public class UIDatePickerDataController: NSObject {
    
    // MARK: Properties
    
    /// The formatter to convert the selected date in the `datePicker` to the `text` in the `textField`.
    public var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        return formatter
    }()
    
    /// The `UIDatePicker` shown as the `inputView` associated with `textField`, i.e. this is shown instead of the keyboard if this field becomes first responder.
    public let datePicker:UIDatePicker
    
    /// The `UITextField` that shows `datePicker` on becoming first responder, and whose text is set to be the selected date from `datePicker`.
    public let textField:UITextField
    
    // MARK: Initialisers
    
    /**
     
     Default initialser. Sets up the links between the `textField` and the `datePicker`.
     
     - parameter datePicker: The `UIDatePicker` to associate with `textField`.
     - parameter textField: The `UITextField` to associate with `datePicker`.
     */
    public init(datePicker:UIDatePicker, textField:UITextField) {
        
        self.datePicker = datePicker
        self.textField = textField
        
        super.init()
        
        if let text = textField.text,
            let date = dateFormatter.dateFromString(text) {
            datePicker.date = date
        }
        
        self.textField.inputView = datePicker
        
        datePicker.addObserver(self, forKeyPath: "date", options: [.Old, .New], context: nil)
        datePicker.addTarget(self, action:#selector(UIDatePickerDataController.dateChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    deinit {
        datePicker.removeObserver(self, forKeyPath: "date")
    }
    
    // MARK: Updating methods.
    
    /**
     
     The `date` property of `datePicker` is observed to determine when the user has selected a new value, and therefore `textField` should be updated.
     
     - seealso: `dateChanged(_:)`
     
     */
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let datePicker = object as? UIDatePicker
            where keyPath == "date" {
            dateChanged(datePicker)
        }
    }
    
    /**
     
     Function called when `datePicker.date` change. Updates `textField.text` to be the newly selected date. Subclasses can override this to provide custom behaviour on date change.
     
     - parameter sender: The `UIDatePicker` whose value has changed i.e. `datePicker`.
     */
    public func dateChanged(sender:UIDatePicker) {
        
        textField.text = dateFormatter.stringFromDate(sender.date)
    }
}
