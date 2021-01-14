//
//  ProfileController.swift
//  TwitterApp
//
//  Created by Sergey on 12/20/20.
//

import UIKit
import Firebase

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            collectionView.reloadData()
        }
    }
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets:
            return tweets
        case .replies:
            return replies
        case .likes:
            return likedTweets
        }
    }
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
        fetchLikedTweets()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Hide navigation bar
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - API
    
    func fetchTweets() {
        TweetServices.shared.fetchTweets(forUser: user) { [weak self] (tweets) in
            self?.tweets = tweets
            self?.collectionView.reloadData()
        }
    }
    
    func fetchLikedTweets() {
        TweetServices.shared.fetchLikes(forUser: user) { [weak self] (tweets) in
            self?.likedTweets = tweets
        }
    }
    
    func fetchReplies() {
        TweetServices.shared.fetchReplies(forUser: user) { [weak self] (tweets) in
            self?.replies = tweets
        }
    }
    
    func checkIfUserIsFollowed() {
        UserServices.shared.checkIfUserIsFollowed(uid: user.uid) { [weak self] (isFollowed) in
            self?.user.isFollowed = isFollowed
            self?.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserServices.shared.fetchUserStats(uid: user.uid) { [weak self] (stats) in
            self?.user.stats = stats
            self?.collectionView.reloadData()
        }
    }
    
    //MARK: - Selectors
    
    
    //MARK: - Helpers
    
    ///Sets the UI of the view
    private func configureUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        //Background color of the main view
        collectionView.backgroundColor = .white
        //Register a cell and a header
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }

}

//MARK: - Delegate and Datasource

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = currentDataSource[indexPath.row]
        let controller = TweetController(tweet: tweet)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - UICollectionView Header

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.delegate = self
        header.user = user
        return header
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 310
        
        if user.bio != nil {
            height += 50
        }
        
        return CGSize(width: view.frame.size.width, height: height)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.size.width, height: 120)
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.frame.size.width).height + 72
        if currentDataSource[indexPath.row].isReplied {
            height += 20
        }
        
        return CGSize(width: view.frame.size.width, height: height)
    }
    
}

//MARK: - ProfileHeaderDelegate 

extension ProfileController: ProfileHeaderDelegate {
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleDismissController() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        
        if user.isFollowed {
            UserServices.shared.unfollowUser(uid: user.uid) { [weak self] (error, reference) in
                self?.user.isFollowed = false
                self?.collectionView.reloadData()
            }
        } else {
            UserServices.shared.followUser(uid: user.uid) { [weak self] (error, reference) in
                guard let self = self else { return }
                self.user.isFollowed = true
                self.collectionView.reloadData()
                NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
            }
        }
    }
    
}

//MARK: - EditProfileControllerDelegate

extension ProfileController: EditProfileControllerDelegate {
    
    func controller(_ controller: EditProfileController, wantsToUpdateUser user: User) {
        self.user = user
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Signed out the user")
        } catch {
            print("DEBUG: Error signing the user out")
        }
    }
    
}
