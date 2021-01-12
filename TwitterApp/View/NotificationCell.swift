//
//  NotificationCell.swift
//  TwitterApp
//
//  Created by Sergey on 12/26/20.
//

import UIKit

protocol NotificationCellDelegate: class {
    func didTapProfileImage(_ cell: NotificationCell)
    func didTapFollow(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    //MARK: - Propertries
    
    weak var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        didSet{
            configure()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 40, height: 40)
        imageView.layer.cornerRadius = 40 / 2
        //Tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    
    
    
    //MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        delegate?.didTapProfileImage(self)
    }
    
    @objc private func handleFollowTapped() {
        delegate?.didTapFollow(self)
    }
    
    //MARK: - Helpers
    
    ///Sets Initial UI
    private func configureUI() {
//        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
//        stack.isUserInteractionEnabled = true
//        stack.axis = .horizontal
//        stack.spacing = 8
//        stack.alignment = .center
//        addSubview(stack)
//        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
//        stack.anchor(right: rightAnchor, paddingRight: 12)
        contentView.addSubview(profileImageView)
        profileImageView.centerY(inView: self)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12)
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.setDimensions(width: 92, height: 32)
        followButton.layer.cornerRadius = 32 / 2
        followButton.anchor(right: rightAnchor, paddingRight:  12)
        contentView.addSubview(notificationLabel)
        notificationLabel.centerY(inView: self)
        notificationLabel.anchor(left: profileImageView.rightAnchor, right: followButton.leftAnchor, paddingLeft: 8, paddingRight: 8)
        
    }
    
    public func configure() {
        guard let notification = notification else { return }
        let viewModel = NotificationViewModel(notification: notification)
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
        notificationLabel.attributedText = viewModel.notoficationText
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
    
    
}
