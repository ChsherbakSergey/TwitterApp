//
//  UploadTweetController.swift
//  TwitterApp
//
//  Created by Sergey on 12/18/20.
//

import UIKit
import SDWebImage

class UploadTweetController: UIViewController {
    
    //MARK: - Properties
    
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var tweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private let captionTextView = CaptionTextView()
    
    private lazy var imageCaptionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 12
        return stack
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Replying to @joker"
        label.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        return label
    }()
    
    //MARK: - Life cycle
    
    init(user: User, config: UploadTweetConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Position of the stack view with profile image view and the caption text view
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
    }
    
    //MARK: - Selectors
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleUploadTweet() {
        guard let caption = captionTextView.text, !caption.isEmpty else { return }
        TweetServices.shared.uploadTweet(caption: caption, type: config) { [weak self] (error, reference) in
            if let error = error {
                //TODO: Alert with error message
                print("DEBUG: Failed to upload tweet with error: \(error.localizedDescription)")
                return
            }
            
            if case .reply(let tweet) = self?.config {
                NotificationService.shared.uploadNotification(type: .reply, tweet: tweet)
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - API
    
    //MARK: - Helpers
    
    ///Sets up Initial UI
    private func configureUI() {
        //Background color of the main view
        view.backgroundColor = .white
        //Set up navigation bar
        configureNavigationBar()
        //Adding subviews
        addAsSubview()
        //Set image to profile image view
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        tweetButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        replyLabel.isHidden = !viewModel.shouldShowReplyButton
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
    }
    
    ///Adds subviews
    private func addAsSubview() {
        view.addSubview(profileImageView)
//        view.addSubview(imageCaptionStack)
        view.addSubview(stack)
    }
    
    ///Sets navigation bar
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        //Set up navigation bar items
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .twitterBlue
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tweetButton)
    }
    
}

