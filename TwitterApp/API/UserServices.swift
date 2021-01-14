//
//  UserServices.swift
//  TwitterApp
//
//  Created by Sergey on 12/18/20.
//

import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

struct UserServices {
    
    static let shared = UserServices()
    
    public func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snaphot) in
            guard let dictionary = snaphot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    public func fetchUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        REF_USERS.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    public func followUser(uid: String, completion: @escaping (DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { (error, reference) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    public func unfollowUser(uid: String, completion: @escaping (DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { (error, reference) in
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    public func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    public func fetchUserStats(uid: String, completion: @escaping (UserRelationsStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let followers = snapshot.children.allObjects.count
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                let following = snapshot.children.allObjects.count
                let stats = UserRelationsStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
    
    public func saveUserData(user: User, completion: @escaping (DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["fullName": user.fullName, "username": user.username, "bio": user.bio ?? ""]
        
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    public func updateProfileImage(image: UIImage, comletion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let filename = NSUUID().uuidString
        let reference = STORAGE_PROFILE_IMAGES.child(filename)
        reference.putData(imageData, metadata: nil) { (metadate, error) in
            reference.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteURL else { return }
                let values = ["profileImageUrl": profileImageUrl]
                REF_USERS.child(uid).updateChildValues(values) { (error, reference) in
                    comletion(url)
                }
            }
        }
    }
    
    func fetchUser(withUsername username: String, completion: @escaping (User) -> Void) {
        REF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { (snapshot) in
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
    
}
