//
//  ProfileHeaderViewModel.swift
//  TwitterApp
//
//  Created by Sergey on 12/21/20.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: User
    
    var followersString: NSAttributedString? {
        return attributedText(with: user.stats?.followers ?? 0, text: "Followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(with: user.stats?.following ?? 0, text: "Following")
    }
    
    var usernameString: String {
        return "@\(user.username)"
    }
    
    var actionButtonTitle: String {
        //if user is the current user then set it to "Edit Profile" otherwise figure out the following data
        if user.isCurrentUser {
            return "Edit Profile"
        }
        if user.isFollowed && !user.isCurrentUser {
//            return "Follow"
            return "Following"
        }
        if user.isFollowed {
            return "Following"
        }
//        return "Loading"
        return "Follow"
    }
    
    init(user: User) {
        self.user = user
    }
    
    fileprivate func attributedText(with value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
}
