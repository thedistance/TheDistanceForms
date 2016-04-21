//
//  UIPickerDataControllers.swift
//  StackView
//
//  Created by Josh Campion on 13/09/2015.
//  Copyright © 2016 Josh Campion.
//

import Foundation

public enum UIPickerType {
    case Date(UIDatePickerDataController)
    case Picker(UIPickerViewDataController)
}

public class UIDatePickerDataController: NSObject {
    
    public var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        return formatter
        }()
    
    public let datePicker:UIDatePicker
    public let textField:UITextField
    
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
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let datePicker = object as? UIDatePicker
            where keyPath == "date" {
            dateChanged(datePicker)
        }
    }
    
    public func dateChanged(sender:UIDatePicker) {
        
        textField.text = dateFormatter.stringFromDate(sender.date)
    }
}

public class UIPickerViewDataController:NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public let choices:[[String]]
    public let pickerView:UIPickerView
    public let textField:UITextField
    
    public init(choices:[[String]], pickerView:UIPickerView, textField:UITextField) {
        self.choices = choices
        self.pickerView = pickerView
        self.textField = textField
        
        super.init()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        textField.inputView = pickerView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIPickerViewDataController.matchPickerToTextField), name: UITextFieldTextDidBeginEditingNotification, object: textField)
    }
    
    func matchPickerToTextField() {
        if let text = textField.text,
            let idx = choices[0].indexOf(text) {
                pickerView.selectRow(idx + 1, inComponent: 0, animated: true)
        }
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return choices.count
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices[component].count + 1
    }
    
    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if row == 0 {
            return NSAttributedString(string: "")
        }
        
        return NSMutableAttributedString(string: choices[component][row - 1], attributes: [NSFontAttributeName: textField.font!])
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            textField.text = choices[component][row - 1]
        } else {
            textField.text = nil
        }
    }
}