//
//  User.swift
//  TwitterApp
//
//  Created by Sergey on 12/18/20.
//

import Foundation
import Firebase

struct User {
    let email: String
    let fullName: String
    let username: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false
    var stats: UserRelationsStats?
    
    var isCurrentUser: Bool { Auth.auth().currentUser?.uid == uid }
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
    }
}

struct UserRelationsStats {
    let followers: Int
    let following: Int
}
