//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

protocol BirthdayValidatableTextFieldDelegate: AnyObject {
    func colorChanged(tag: Int, color: UIColor)
}

public class BirthdayValidatableTextField: UITextField {
    var defaultColor: UIColor = .tungsten
    var selectedColor: UIColor = .white
    var errorColor: UIColor = .lostRed
    var validate: (String?) -> Bool = { _ in return false }
    var fieldDidResign: (BirthdayViewModel.DateFieldType, String?) -> Void = { _, _ in return }
    var maxCharacters: Int = 2
    var fieldType: BirthdayViewModel.DateFieldType = .day
    var backspaceInEmptyField: (BirthdayViewModel.DateFieldType) -> Void = { _ in return }
    var shouldZeroPad: Bool = true
    var correctColor: UIColor = .tungsten
    
    var fieldDelegate: BirthdayValidatableTextFieldDelegate?
    
    var wasBackspacedInto: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        isUserInteractionEnabled = true
        borderStyle = .none
        layer.borderColor = defaultColor.cgColor
        layer.borderWidth = 1.75
        layer.cornerRadius = 5
        delegate = self
        textAlignment = .center
        textColor = .white
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tintColor = TriumphCommon.colors.TRIUMPH_PRIMARY_COLOR
    }
    
    @discardableResult override public func resignFirstResponder() -> Bool {
        wasBackspacedInto = false
        return super.resignFirstResponder()
    }
}

extension BirthdayValidatableTextField: UITextFieldDelegate {
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if shouldZeroPad && !(text?.isEmpty ?? true) {
            if (text?.count ?? 0) < maxCharacters {
                if let text = text {
                    let padded = String(repeating: "0", count: maxCharacters - text.count)
                    self.text = padded + text
                }
            }
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        respondToChange()
    }
    
    @discardableResult override public func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            if !wasBackspacedInto { text = "" }
            UIView.animate(withDuration: 0.2, animations: { [self] in
                fieldDelegate?.colorChanged(tag: self.tag, color: selectedColor)
                layer.borderColor = selectedColor.cgColor
            })
            return true
        }
        return false
    }
    
    @objc public func textFieldDidChange() {
        if text?.count == maxCharacters {
            fieldDidResign(fieldType, nil)
            respondToChange()
        } else {
            revertToSelected()
        }
    }
    
    // revert year to selected (from incorrect) if characters are less than max
    // unneccesary if field will dismiss once everything has been filled out,
    // and tapping will cause field to clear.
    func revertToSelected() {
        UIView.animate(withDuration: 0.2, animations: { [self] in
            layer.borderColor = selectedColor.cgColor
        })
        fieldDelegate?.colorChanged(tag: self.tag, color: selectedColor)
    }
    
    func respondToChange() {
        var changedColor = defaultColor
        if (!(text?.isEmpty ?? false)) {
            changedColor = validate(text) ? correctColor : errorColor
            UIView.animate(withDuration: 0.2, animations: { [self] in
                layer.borderColor = changedColor.cgColor
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { [self] in
                layer.borderColor = defaultColor.cgColor
            })
        }
        fieldDelegate?.colorChanged(tag: self.tag, color: changedColor)
    }
    
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if ((string.count - range.length) + (textField.text?.count ?? 0)) > maxCharacters {
            fieldDidResign(fieldType, string)
            respondToChange()
            return false
        }
        return true
    }
    
    override public func deleteBackward() {
        if text == "" {
            backspaceInEmptyField(fieldType)
        } else {
            super.deleteBackward()
        }
    }
    
    func validateFromSuperview() -> Bool {
        return validate(text)
    }
}
