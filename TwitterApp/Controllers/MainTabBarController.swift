//
//  MainTabBarController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    //MARK: - Properties
    
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
//        logUserOut()
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
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Signed out the user")
        } catch {
            print("DEBUG: Error signing the user out")
        }
    }
    
    //MARK: - Selectors
    
    @objc private func actionButtonIsTapped() {
        guard let user = user else { return }
        let nav = UINavigationController(rootViewController: UploadTweetController(user: user, config: .tweet))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func congigureViewControllers() {
        
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNav = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController()
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
        //Adding sunviews
        view.addSubview(actionButton)
    }

}
