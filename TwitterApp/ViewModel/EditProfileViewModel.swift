//
//  EditProfileViewModel.swift
//  TwitterApp
//
//  Created by Sergey on 1/14/21.
//

import UIKit

enum EditProfileOptions: Int, CaseIterable {
    case fullName
    case username
    case bio
    
    var description: String {
        switch self {
        case .fullName: return "Name"
        case .username: return "Username"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var titleText: String {
        return option.description
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullName: return user.fullName
        case .bio: return user.bio
        }
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
    
}
