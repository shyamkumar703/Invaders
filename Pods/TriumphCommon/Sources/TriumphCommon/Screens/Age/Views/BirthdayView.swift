// Copyright © TriumphSDK. All rights reserved.

import UIKit

class BirthdayView: UIView {
    
    var model: BirthdayViewModel? = {
        let model = BirthdayViewModel()
        return model
    }()
    
    private lazy var monthTextStack: UIStackView = {
        return dateFieldFactory(type: .month, placeholder: "10", tag: 1)
    }()
    
    private lazy var dayTextStack: UIStackView = {
        return dateFieldFactory(type: .day, placeholder: "01", tag: 2)
    }()
    
    private lazy var yearTextStack: UIStackView = {
        return dateFieldFactory(type: .year, placeholder: "1998", tag: 3)
    }()
    
    private lazy var outerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(monthTextStack)
        stack.addArrangedSubview(dayTextStack)
        stack.addArrangedSubview(yearTextStack)
        return stack
    }()
    
    func dateFieldFactory(type: BirthdayViewModel.DateFieldType, placeholder: String, tag: Int = 0) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 2
        
        // text field
        let textField = BirthdayValidatableTextField()
        textField.placeholder = placeholder
        textField.fieldType = type
        textField.fieldDelegate = self
        if type == .year { textField.maxCharacters = 4 }
        textField.tag = tag
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 32)
        
        if let model = model {
            textField.fieldDidResign = model.fieldDidResign(type:str:)
            textField.backspaceInEmptyField = model.backspaceInEmptyField(type:)
          
            switch type {
            case .day:
                textField.validate = model.validateDay(str:)
            case .month:
                textField.validate = model.validateMonth(str:)
            case .year:
                textField.validate = model.validateYear(str:)
            }
        }
        
        // label
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.text = type.str
        label.tag = 0
        label.textColor = .tungsten
        
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(label)
        stack.tag = tag
        return stack
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        model?.viewDelegate = self
        backgroundColor = .clear
        addSubview(outerStack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leftAnchor.constraint(equalTo: leftAnchor),
            outerStack.rightAnchor.constraint(equalTo: rightAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            dayTextStack.widthAnchor.constraint(equalToConstant: 65),
            monthTextStack.widthAnchor.constraint(equalTo: dayTextStack.widthAnchor)
        ])
    }
    
    func enableKeyboard() {
        getTextFieldFromStack(stack: monthTextStack)?.becomeFirstResponder()
    }
    
    func dismissFirstResponder() {
        outerStack.arrangedSubviews
            .compactMap({ $0 as? UIStackView })
            .compactMap({ getTextFieldFromStack(stack: $0) })
            .filter({ $0.isFirstResponder })
            .first?
            .resignFirstResponder()
    }
}

extension BirthdayView: BirthdayViewDelegate {
    func textFieldFor(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField? {
        switch type {
        case .day:
            return getTextFieldFromStack(stack: dayTextStack)
        case .month:
            return getTextFieldFromStack(stack: monthTextStack)
        case .year:
            return getTextFieldFromStack(stack: yearTextStack)
        }
    }
    
    func getTextFieldFromStack(stack: UIStackView) -> BirthdayValidatableTextField? {
        return stack.arrangedSubviews.filter({ $0.tag != 0 }).first as? BirthdayValidatableTextField
    }
    
    func getLabelFromStack(stack: UIStackView?) -> UILabel? {
        if let stack = stack {
            return stack.arrangedSubviews.filter({ $0.tag == 0 }).first as? UILabel
        }
        return nil
    }
    
    func getStackWithTag(tag: Int) -> UIStackView? {
        return outerStack.arrangedSubviews.filter({ $0.tag == tag }).first as? UIStackView
    }
    
    func textFieldAfter(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField? {
        switch type {
        case .month:
            return getTextFieldFromStack(stack: dayTextStack)
        case .day:
            return getTextFieldFromStack(stack: yearTextStack)
        case .year:
            return nil
        }
    }
    
    func textFieldBefore(type: BirthdayViewModel.DateFieldType) -> BirthdayValidatableTextField? {
        switch type {
        case .month:
            return nil
        case .day:
            return getTextFieldFromStack(stack: monthTextStack)
        case .year:
            return getTextFieldFromStack(stack: dayTextStack)
        }
    }
    
    func colorChanged(tag: Int, color: UIColor) {
        getLabelFromStack(stack: getStackWithTag(tag: tag))?.textColor = color
    }
}
