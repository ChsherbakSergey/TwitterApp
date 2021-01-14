//
//  EditProfileCell.swift
//  TwitterApp
//
//  Created by Sergey on 1/14/21.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    //MARK: - Properties
    
    weak var delegate: EditProfileCellDelegate?
    
    var viewModel: EditProfileViewModel? {
        didSet {
            configure()
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 14)
        textField.textAlignment = .left
        textField.textColor = .twitterBlue
        textField.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return textField
    }()
    
    let bioTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .twitterBlue
        textView.placeholderLabel.text = "Bio"
        return textView
    }()
    
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureInitialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc private func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }
    
    //MARK: - Helpers
    
    private func configureInitialUI() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 12, paddingLeft: 16)
        contentView.addSubview(infoTextField)
        infoTextField.anchor(top: contentView.topAnchor, left: titleLabel.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        contentView.addSubview(bioTextView)
        bioTextView.anchor(top: contentView.topAnchor, left: titleLabel.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }
    
}
