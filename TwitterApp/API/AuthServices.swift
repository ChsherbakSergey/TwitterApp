//
//  AuthServices.swift
//  TwitterApp
//
//  Created by Sergey on 12/17/20.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullName: String
    let username: String
    let profileImage: UIImage
}

struct AuthServices {
    
    static let shared = AuthServices()
    
    ///Log in the user
    public func loginUserIn(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    ///Register a new user and write data to Database
    public func registerUser(credentials: AuthCredentials, completion: @escaping (Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let fullName = credentials.fullName
        let username = credentials.username
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        //Register a new user
        let storageRef = STORAGE_PROFILE_IMAGES.child(fileName)
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                    guard let uid = result?.user.uid else { return }
                    let values = ["email": email, "username": username, "fullName": fullName, "profileImageUrl": profileImageUrl]
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                }
                //TODO: Send Email Verification
//                Auth.auth().currentUser?.sendEmailVerification(completion: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
            }
        }
    }
    
}
