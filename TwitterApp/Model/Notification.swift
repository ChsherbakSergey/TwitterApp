//
//  Notification.swift
//  TwitterApp
//
//  Created by Sergey on 12/25/20.
//

import UIKit

enum NotificationType: Int {
    case follow 
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    
    var tweetId: String?
    var timestamp: Date!
    var user: User
    var tweet: Tweet?
    var type: NotificationType!
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
//        self.tweet = tweet
        
        if let tweetId = dictionary["tweetId"] as? String {
            self.tweetId = tweetId
        }
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
    
}
