//
//  UIPickerDataControllers.swift
//  StackView
//
//  Created by Josh Campion on 13/09/2015.
//  Copyright © 2016 Josh Campion.
//

import Foundation
import TheDistanceCore

/**
 
 Convenience class for managing a `UIPickerView` shown as the `inputView` associated with a `UITextField`.
 
 This class contains boilerplate methods for the data source for populating `UIPickerView` and delegate methods for setting the text of the `UITextField` with the selected value.
 
 - seealso: `UIDatePickerDataController`
 
 */
open class UIPickerViewDataController:NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    /// An array of strings forming the data source for `pickerView`.
    open var choices:[[String]]{
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// The `UIPickerView` shown as the `inputView` associated with `textField`, i.e. this is shown instead of the keyboard if this field becomes first responder.
    open let pickerView:UIPickerView
    
    /// The `UITextField` that shows `pickerView` on becoming first responder, and whose text is set to be the selected date from `datePicker`.
    open let textField:UITextField
    
    /// Property for whether a blank row should be added to each component in `pickerView`. Default value is `true`.
    open var addsBlankEntry:Bool = true {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    /// Convenience variable for accessing strings in `choices` based on `addsBlankEntry`.
    open var indexOffset:Int {
        return addsBlankEntry ? 1 : 0
    }
    
    // MARK: Initialisers
    
    /**
     
     Default initialser. Sets up the links between the `textField` and the `pickerView`.
     
     - parameter choices: The strings to populate `pickerView` with. Each sub array specifies a component in the `UIPickerView`.
     - parameter pickerView: The `UIPickerView` associated with `textField`.
     - parameter textField: The `UITextField` to associate with `pickerView`.
     */
    public init(choices:[[String]], pickerView:UIPickerView, textField:UITextField) {
        self.choices = choices
        self.pickerView = pickerView
        self.textField = textField
        
        super.init()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        textField.inputView = pickerView
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIPickerViewDataController.matchPickerToTextField), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: textField)
    }
    
    /// Internal function used to preselect a value in the picker view based on entered text when the `textField` becomes active.
    func matchPickerToTextField() {
        if let text = textField.text,
            let idx = choices[0].index(of: text) {
                pickerView.selectRow(idx + indexOffset, inComponent: 0, animated: true)
        }
    }
    
    // MARK: Picker View Data Source
    
    /**
     
     `UIPickerViewDataSource` method.
     
     - returns: The number of sub-arrays in `choices`.
     
    */
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return choices.count
    }
    
    /// `UIPickerViewDataSource` method powered by `choices` and `addsBlankRow`.
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices[component].count + indexOffset
    }
    
    // MARK: Picker View Delegate
    
    /// `UIPickerViewDelegate` method powered by `choices` and `addsBlankRow`.
    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if row == 0  && addsBlankEntry {
            return NSAttributedString(string: "")
        }
        
        return NSMutableAttributedString(string: choices[component][row - indexOffset], attributes: [NSFontAttributeName: textField.font!])
    }
    
    /// Calls `textForPickerView(_:)` to update the new text.
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = textForPickerView(pickerView)
    }
    
    /**
     
     Should be used to create the text to display in `textField` given the selected state of `pickerView`.
     
     - returns: The text for all selected rows into a single string separated by ", ".
     
    */
    open func textForPickerView(_ pickerView:UIPickerView) -> String {
        
        let comps = choices.count
        let selectedChoice:[String] =  (0..<comps).map { ($0, pickerView.selectedRow(inComponent: $0) - indexOffset) }
            .filter { $0.1 >= 0 }
            .map { choices[$0.0][$0.1] }
            .map { ($0 as String).whitespaceTrimmedString() }
            .filter { !$0.isEmpty }
        
        return selectedChoice.joined(separator: ", ")

    }
}
