//
//  RegistrationController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    private lazy var profilePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"), textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
        return view
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: fullNameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = Utilities().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Email")
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Password")
        //TODO: set it
//        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Full Name")
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = Utilities().textField(withPlaceholder: "Username")
        return textField
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullNameContainerView, usernameContainerView, registrationButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private let registrationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(registrationButtonIsTapped), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAnAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an acoount?", "  Log In")
        button.addTarget(self, action: #selector(handleShowLoginScreen), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Position of the profile photo button
        profilePhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        profilePhotoButton.setDimensions(width: 128, height: 128)
        profilePhotoButton.layer.cornerRadius = profilePhotoButton.frame.size.height / 2
        profilePhotoButton.layer.masksToBounds = true
        //Position of the stackView with email, password, fullname and username fields
//        stack.anchor(top: profilePhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 24, paddingRight: 32)
        stack.anchor(top: profilePhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 24, paddingRight: 32)
        //Height and corner radius of login button
        registrationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registrationButton.layer.cornerRadius = 5
        //Position of the already have an account button
        alreadyHaveAnAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingRight: 40)
    }
    
    //MARK: - Selectors
    
    @objc private func handleAddProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func registrationButtonIsTapped() {
        guard let profileImage = profileImage else {
            //TODO: Alert that have to select an image
            print("DEBUG: Please select a profile image")
            return
        }
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 6,
              let fullName = fullNameTextField.text, !fullName.isEmpty,
              let username = usernameTextField.text?.lowercased(), !username.isEmpty else { return }
        let credentials = AuthCredentials(email: email, password: password, fullName: fullName, username: username, profileImage: profileImage)
        //Register a new user
        AuthServices.shared.registerUser(credentials: credentials) { [weak self] (error, reference) in
//            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow}) else { return }
//            guard let tab = window.rootViewController as? MainTabBarController else { return }
//            tab.authenticateUserAndConfigureUI()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleShowLoginScreen() {
        navigationController?.popViewController(animated: true)
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
        //Set up imagePicker
        setImagePicker()
    }
    
    ///Adds Subviews to the view
    private func addAsSubview() {
        view.addSubview(profilePhotoButton)
        view.addSubview(stack)
        view.addSubview(alreadyHaveAnAccountButton)
    }
    
    ///Sets Image Picker
    private func setImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
}

//MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate Implementation

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        //set profile image to have this image to upload it when the user register
        self.profileImage = profileImage
        profilePhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        profilePhotoButton.layer.borderColor = UIColor.white.cgColor
        profilePhotoButton.layer.borderWidth = 2
        dismiss(animated: true, completion: nil)
    }
    
}
