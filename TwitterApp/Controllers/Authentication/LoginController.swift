//
//  LoginController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    //MARK: - Properties
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "TwitterLogo")
        return imageView
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"), textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Email")
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(loginButtonIsTapped), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAnAccountButton: UIButton = {
        let button = Utilities().attributedButton("Don't have an acoount?", "  Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Position of the logo imageView
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        //Position of the stackView with email and password fields
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 24, paddingRight: 32)
        //Height and corner radius of login button
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.layer.cornerRadius = 5
        //Position of the don't have an account button
        dontHaveAnAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingRight: 40)
    }
    
    //MARK: - Selectors
    
    @objc private func loginButtonIsTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 6 else { return }
        //Log in a user
        AuthServices.shared.loginUserIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                print("DEBUF: Error login the user in: \(error.localizedDescription)")
                return
            }
            print("DEBUG: Successfully logged the user in!")
//            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow}) else { return }
//            guard let tab = window.rootViewController as? MainTabBarController else { return }
//            tab.authenticateUserAndConfigureUI()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleShowSignUp() {
        let vc = RegistrationController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Helpers
    
    ///Sets up the initial UI
    private func configureUI() {
        //Background color of the main view
        view.backgroundColor = .twitterBlue
        //Set up and hide navigation bar
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        //Adding subviews
        addAsSubview()
    }
    
    private func addAsSubview() {
        //Adding subviews
        view.addSubview(logoImageView)
        view.addSubview(stack)
        view.addSubview(dontHaveAnAccountButton)
    }
    
}
