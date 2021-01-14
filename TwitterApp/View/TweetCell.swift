//
//  TweetCell.swift
//  TwitterApp
//
//  Created by Sergey on 12/20/20.
//

import UIKit
import SDWebImage
import ActiveLabel

protocol TweetCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
}

class TweetCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .red
        //Tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()

    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc private func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc private func handleRetweetTapped() {
    }
    
    @objc private func handleLikeButtonTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc private func handleShareTapped() {
        
    }
    
    //MARK: - Helpers
    
    ///Sets Initial UI
    private func configureUI() {
        
        let captionsStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionsStack.axis = .vertical
        captionsStack.distribution = .fillProportionally
        captionsStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionsStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        //Creating stack for actions
        let actionsStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionsStack.axis = .horizontal
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 72
        contentView.addSubview(actionsStack)
        //Position of the actions stack view
        actionsStack.centerX(inView: self)
        actionsStack.anchor(bottom: contentView.bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        contentView.addSubview(underlineView)
        //Position of the underlineView
        underlineView.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, height: 1)
    }
    
    ///Configures cell's data
    private func configure() {
        guard let tweet = tweet else { return }
        let viewModel = TweetViewModel(tweet: tweet)
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = viewModel.userInfoText
        captionLabel.text = tweet.caption
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { (username) in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
    
}
