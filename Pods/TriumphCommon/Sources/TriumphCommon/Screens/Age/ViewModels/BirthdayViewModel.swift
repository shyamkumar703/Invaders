// Copyright © TriumphSDK. All rights reserved.

import UIKit

protocol BirthdayViewModelDelegate: AnyObject {
    func datePickerChanged(date: Date)
    func birthdayViewDidResign()
}

protocol BirthdayViewDelegate: BirthdayValidatableTextFieldDelegate {
    func textFieldFor(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField?
    func textFieldAfter(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField?
    func textFieldBefore(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField?
    func colorChanged(tag: Int, color: UIColor)
}

class BirthdayViewModel {
    var day: String
    var month: String
    var year: String
    
    weak var viewDelegate: BirthdayViewDelegate?
    weak var viewModelDelegate: BirthdayViewModelDelegate?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    init(day: String = "", month: String = "", year: String = "") {
        self.day = day
        self.month = month
        self.year = year
    }
    
    func generateDateString() -> String {
        return "\(month)/\(day)/\(year)"
    }
    
    // MARK: - Populate model
    // Use viewDelegate to retrieve ValidatableTextFields, and populate
    func populate() {
        for type in DateFieldType.allCases {
            switch type {
            case .day:
                day = viewDelegate?.textFieldFor(type: type)?.text ?? ""
            case .month:
                month = viewDelegate?.textFieldFor(type: type)?.text ?? ""
            case .year:
                year = viewDelegate?.textFieldFor(type: type)?.text ?? ""
            }
        }
    }
    
    // MARK: - Validation functions
    func validateDay(str: String?) -> Bool {
        if let str = str,
           let day = Int(str) {
            return day > 0 && day <= 31
        }
        return false
    }
    
    func validateMonth(str: String?) -> Bool {
        if let str = str,
           let month = Int(str) {
            return month > 0 && month <= 12
        }
        return false
    }
    
    func validateYear(str: String?) -> Bool {
        if let str = str,
           let year = Int(str) {
            let currYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 2022
            return year < currYear && year > 1900
        }
        return false
    }
    
    // MARK: - Validate all fields
    // Use viewDelegate to retrieve ValidatableTextFields, and validate using validateFromSuperview()
    func validateFields() -> Bool {
        return DateFieldType.allCases
            .map({ viewDelegate?.textFieldFor(type: $0)?.validateFromSuperview() ?? false })
            .allSatisfy({$0})
    }
    
    // MARK: - Validate model
    @discardableResult func validate() -> Bool {
        if let date = formatter.date(from: generateDateString()) {
            let isValid = validateFields()
            if isValid {
                viewModelDelegate?.datePickerChanged(date: date)
            }
            return isValid
        }
        return false
    }
    
    // MARK: - Handle user interaction
    func fieldDidResign(type: DateFieldType, str: String?) {
        populate()
        let isValid = validate()
        if let nextField = textFieldAfter(type: type) {
            nextField.text = str
            nextField.becomeFirstResponder()
        } else {
            viewDelegate?.textFieldFor(type: type)?.resignFirstResponder()
            if isValid { viewModelDelegate?.birthdayViewDidResign() }
        }
    }
    
    func backspaceInEmptyField(type: DateFieldType) {
        if let field = viewDelegate?.textFieldBefore(type: type) {
            field.wasBackspacedInto = true
            field.becomeFirstResponder()
        }
    }
    
    func textFieldAfter(type: DateFieldType) -> BirthdayValidatableTextField? {
        if let nextField = viewDelegate?.textFieldAfter(type: type) {
            if nextField.validateFromSuperview() {
                return textFieldAfter(type: nextField.fieldType)
            } else {
                return nextField
            }
        } else {
            return nil
        }
    }
}

extension BirthdayViewModel {
    enum DateFieldType: String, CaseIterable {
        case day = "Day"
        case month = "Month"
        case year = "Year"
        
        var str: String { rawValue }
    }
}
