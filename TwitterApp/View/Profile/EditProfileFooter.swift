//
//  EditProfileFooter.swift
//  TwitterApp
//
//  Created by Sergey on 1/14/21.
//

import UIKit

protocol EditProfileFooterDelegate: class {
    func handleLogout()
}

class EditProfileFooter: UIView {
    
    //MARK: - Properties
    
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureInitialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc private func handleLogout() {
        delegate?.handleLogout()
    }
    
    //MARK: - Helpers
    
    private func configureInitialUI() {
        addSubview(logoutButton)
        logoutButton.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 16, paddingRight: 16)
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.centerY(inView: self)
    }
    
}
