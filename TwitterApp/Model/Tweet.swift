//
//  Tweet.swift
//  TwitterApp
//
//  Created by Sergey on 12/19/20.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetID: String
    var likes: Int
    let retweets: Int
    var timestamp: Date!
//    let uid: String
    var user: User
    var didLike = false
    var replyingTo: String?
    
    var isReplied: Bool {
        replyingTo != nil
    }
    
    init(user: User, tweetID: String, dictionary: [String: Any]) {
        self.user = user
        self.tweetID = tweetID
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
//        self.uid = dictionary["uid"] as? String ?? ""
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
