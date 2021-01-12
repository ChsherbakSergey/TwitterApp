//
//  ConversationsController.swift
//  TwitterApp
//
//  Created by Sergey on 12/16/20.
//

import UIKit

class ConversationsController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    //MARK: - Helpers
    
    ///Sets up the initial UI
    private func configureUI() {
        //Background color of the main view
        view.backgroundColor = .systemBackground
        //Set up navigation bar title
        navigationItem.title = "Messages"
    }
    
}
