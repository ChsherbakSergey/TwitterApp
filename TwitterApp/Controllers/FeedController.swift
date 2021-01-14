//
//  FeedController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            print("DEBUG: Did Set user in the feed tab")
            configureLeftBarButton()
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Show navigation bar
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - API
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        TweetServices.shared.fetchTweets { [weak self] (tweets) in
            self?.tweets = tweets.sorted(by: {$0.timestamp > $1.timestamp})
            self?.checkIfUserLikedTweets()
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { (tweet) in
            TweetServices.shared.checkIfUserLikedTweet(tweet) { (didLike) in
                guard didLike == true else { return }
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    //MARK: - Selectors
    
    @objc private func handleRefresh() {
        fetchTweets()
    }
    
    @objc private func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Helpers
    
    ///Sets up the initial UI
    private func configureUI() {
        //Background color of the main view
        view.backgroundColor = .systemBackground
        //Register Collection view cell
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //Background color of the collection view
        collectionView.backgroundColor = .white
        //Set up the image logo in the navigation bar
        let image = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        image.contentMode = .scaleAspectFit
        image.setDimensions(width: 44, height: 44)
        navigationItem.titleView = image
        //Profile button in the navigation bar
        //Creating refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
    }
    
    //Sets up the navigation user profile button
    private func configureLeftBarButton() {
        guard let user = user else { return }
        let profileImageView = UIImageView()
        profileImageView.isUserInteractionEnabled = true
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
}

//MARK: - DataSource

extension FeedController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
}

//MARK: - Delegate

extension FeedController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let tweet = tweets[indexPath.row]
        let controller = TweetController(tweet: tweet)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.size.width).height
        return CGSize(width: view.frame.size.width, height: height + 70)
    }
    
}

//MARK: - TweetCellDelegate

extension FeedController: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        TweetServices.shared.likeTweet(tweet: tweet) { (error, reference) in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            //Upload like notification
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user, type: .like, tweetID: tweet.tweetID)
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserServices.shared.fetchUser(withUsername: username) { [weak self] (user) in
            let controller = ProfileController(user: user)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
