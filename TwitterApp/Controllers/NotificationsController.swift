//
//  NotificationsController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Show navigation bar
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK: - API
    
    private func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { [weak self] (notifications) in
            self?.refreshControl?.endRefreshing()
            self?.notifications = notifications
            self?.checkIfUserIsFollowed(notification: notifications)
        }
    }
    
    func checkIfUserIsFollowed(notification: [Notification]) {
        for (index, notification) in notifications.enumerated() {
            if case .follow = notification.type {
                let user = notification.user
                UserServices.shared.checkIfUserIsFollowed(uid: user.uid) { [weak self] (isFollowed) in
                    self?.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    //MARK: - Selectors
    
    @objc private func handleRefresh() {
        print("Fuck")
        refreshControl?.endRefreshing()
    }
    
    
    //MARK: - Helpers
    
    ///Sets up the initial UI
    private func configureUI() {
        //Background color of the main view
        view.backgroundColor = .systemBackground
        //Set up navigation bar title
        navigationItem.title = "Notifications"
        //Register tableView cell
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
}

//MARK: - UITableViewDataSource

extension NotificationsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK: - UITableViewDelegate

extension NotificationsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = notifications[indexPath.row]
        guard let tweetId = notification.tweetId else { return }
        TweetServices.shared.fetchTweet(withTweetId: tweetId) { [weak self] (tweet) in
            let controller = TweetController(tweet: tweet)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

//MARK: - NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        if user.isFollowed {
            //Handle Unfollow
            UserServices.shared.unfollowUser(uid: user.uid) { (error, reference) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            //Handle Follow
            UserServices.shared.followUser(uid: user.uid) { (error, reference) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
    
}
