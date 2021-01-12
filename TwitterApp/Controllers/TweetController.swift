//
//  TweetController.swift
//  TwitterApp
//
//  Created by Sergey on 12/23/20.
//

import UIKit

private let headerIdentifier = "TweetHeader"
private let reuseIdentifier = "TweetCell"

class TweetController: UICollectionViewController {
    
    //MARK: - Propetries
    
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchReplies()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    //MARK: - API
    
    func fetchReplies() {
        print("Tweet caption is \(tweet.tweetID)")
        TweetServices.shared.fetchReplies(forTweet: tweet) { [weak self] (replies) in
            self?.replies = replies
        }
    }
    
    //MARK: - Selectors
    
    
    //MARK: - Helpers
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
}

//MARK: - Datasource

extension TweetController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        return cell
    }
    
}

//MARK: - Delegate

extension TweetController {
    
    
    
}

//MARK: - UICollectionView Header

extension TweetController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TweetHeader
        header.delegate = self
        header.tweet = tweet
        return header
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.size(forWidth: view.frame.size.width).height
        return CGSize(width: view.frame.size.width, height: captionHeight + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 120)
    }
    
}

//MARK: - TweetHeaderDelegate

extension TweetController: TweetHeaderDelegate {
    
    func showActionSheet() {
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            UserServices.shared.checkIfUserIsFollowed(uid: tweet.user.uid) { [weak self] (isFollowed) in
                guard var user = self?.tweet.user else { return }
                user.isFollowed = isFollowed
                self?.showActionSheet(forUser: user)
            }
        }
    }
    
}

//MARK: - ActionSheetLauncherDelegate

extension TweetController: ActionSheetLauncherDelegate {
    
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserServices.shared.followUser(uid: user.uid) { (error, reference) in
                print("follow user \(user.username)")
            }
        case .unfollow(let user):
            UserServices.shared.unfollowUser(uid: user.uid) { (error, reference) in
                print("unfollow user \(user.username)")
            }
        case .report:
            print("Report tweet")
        case .delete:
            print("Delete tweet")
        }
    }
    
}
