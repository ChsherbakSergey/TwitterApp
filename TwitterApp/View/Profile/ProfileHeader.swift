//
//  ProfileHeader.swift
//  TwitterApp
//
//  Created by Sergey on 12/21/20.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func handleDismissController()
    func handleEditProfileFollow(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilterOptions)
}

class ProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    weak var delegate: ProfileHeaderDelegate?
    
    var user: User? {
        didSet { configure() }
    }
    
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissController), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.text = "The great investment you can do is to invest in yourself!"
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()

    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Position of the container view with back button
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        //Position of the profile imageview
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor, paddingTop: -24, paddingLeft: 8)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        //Position of the edit profile follow button
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 12)
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        //Position of the filter bar
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
    }
    
    //MARK: - API
    
    
    //MARK: - Selectors
    
    @objc private func handleDismissController() {
        delegate?.handleDismissController()
    }
    
    @objc private func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc private func handleFollowersTapped() {
        
    }
    
    @objc private func handleFollowingTapped() {
        
    }
    
    //MARK: - Helpers
    
    //Configures necessary information for the viewModel
    func configure() {
        guard let user = user else { return }
        let viewModel = ProfileHeaderViewModel(user: user)
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        fullNameLabel.text = user.fullName
        usernameLabel.text = viewModel.usernameString
    }
    
    ///Sets the UI of the view
    private func configureUI() {
        //Adding subviews
        addAsASubview()
        //Creating infoStackView
        let userInfoStack = UIStackView(arrangedSubviews: [fullNameLabel, usernameLabel, bioLabel])
        userInfoStack.axis = .vertical
        userInfoStack.distribution = .fillProportionally
        userInfoStack.spacing = 4
        addSubview(userInfoStack)
        userInfoStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        //Creating follow stack
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.distribution = .fillEqually
        followStack.spacing = 8
        addSubview(followStack)
        followStack.anchor(top: userInfoStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        //Set Delegates
        setDelegates()
    }
    
    private func addAsASubview() {
        addSubview(containerView)
        addSubview(profileImageView)
        addSubview(editProfileFollowButton)
        addSubview(filterBar)
    }
    
    private func setDelegates() {
        filterBar.delegate = self
    }
    
}

//MARK: - ProfileFilterViewDelegate Implementation

extension ProfileHeader: ProfileFilterViewDelegate {
    
    func filterView(_ view: ProfileFilterView, didSelect indexPath: Int) {
        guard let filter = ProfileFilterOptions(rawValue: indexPath) else { return }
        delegate?.didSelect(filter: filter)
    }

}
