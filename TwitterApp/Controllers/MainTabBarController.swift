//
//  MainTabBarController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabBarController: UITabBarController {
    
    //MARK: - Properties
    
    private var butonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            print("DEBUG: Did set user in the main tab")
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonIsTapped), for: .touchUpInside)
        return button   
    }()
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
        fetchUser()
        congigureViewControllers()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Position of the action button
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = actionButton.frame.size.height / 2
    }
    
    //MARK: - API
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async { [weak self] in
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true, completion: nil)
            }
        } else {
            //TODO: It must be called from here
//            congigureViewControllers()
//            configureUI()
//            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.shared.fetchUser(uid: uid) { [weak self] (user) in
            self?.user = user
        }
    }
    
    //MARK: - Selectors
    
    @objc private func actionButtonIsTapped() {
        
        let controller: UIViewController
        
        switch butonConfig {
        case .message:
            controller = ExploreController(config: .messages)
        case .tweet:
            guard let user = user else { return }
            controller = UploadTweetController(user: user, config: .tweet)
        }
        
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func congigureViewControllers() {
        
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNav = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController(config: .userSearch)
        let exploreNav = templateNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let notificationsNav = templateNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        
        let conversations = ConversationsController()
        let conversationsNav = templateNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        viewControllers = [feedNav, exploreNav, notificationsNav, conversationsNav]
    }
    
    ///Creates and configures navigationController for provided rootViewController
    private func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        return nav
    }
    
    ///Sets up the initial UI
    private func configureUI() {
        self.delegate = self
        //Adding sunviews
        view.addSubview(actionButton)
    }

}

//MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? "mail" : "new_tweet"
        actionButton.setImage(UIImage(named: imageName), for: .normal)
        butonConfig = index == 3 ? .message : .tweet
    }
    
}
