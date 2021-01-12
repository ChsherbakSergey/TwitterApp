//
//  TweetServices.swift
//  TwitterApp
//
//  Created by Sergey on 12/18/20.
//

import Firebase

struct TweetServices {
    
    static let shared = TweetServices()
    
    public func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : Any]
        switch type {
        case .tweet:
                REF_TWEETS.childByAutoId().updateChildValues(values) { (error, reference) in
                guard let tweetID = reference.key else { return }
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId().updateChildValues(values) { (error, reference) in
                guard let replyKey = reference.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    public func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            REF_USER_TWEETS.child(followingUid).observe(.childAdded) { (snapshot) in
                let tweetId = snapshot.key
                self.fetchTweet(withTweetId: tweetId) { (tweet) in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        REF_USER_TWEETS.child(currentUid).observe(.childAdded) { (snapshot) in
            let tweetId = snapshot.key
            self.fetchTweet(withTweetId: tweetId) { (tweet) in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    public func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetId: tweetID) { (tweet) in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    public func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> Void) {
        REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            //Fetching user
            UserServices.shared.fetchUser(uid: uid) { (user) in
                //Fetching tweets
                let tweet = Tweet(user: user, tweetID: tweetId, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    public func fetchReplies(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var replies = [Tweet]()
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyId = snapshot.key
                //Fetching user
                UserServices.shared.fetchUser(uid: uid) { (user) in
                    //Fetching tweets
                    let reply = Tweet(user: user, tweetID: replyId, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    public func fetchReplies(forTweet tweet: Tweet, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            //Fetching user
            UserServices.shared.fetchUser(uid: uid) { (user) in
                //Fetching tweets
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    public func fetchLikes(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetId = snapshot.key
            self.fetchTweet(withTweetId: tweetId) { (likedTweet) in
                var tweet = likedTweet
                tweet.didLike = true
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    public func likeTweet(tweet: Tweet, completion: @escaping (DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        if tweet.didLike {
            //Remove like
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (error, reference) in
                REF_TWEET_LIKES.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            // Add like
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { (error, reference) in
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    public func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    
}


