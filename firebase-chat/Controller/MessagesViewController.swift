//
//  ViewController.swift
//  firebase-chat
//
//  Created by MacBookPro on 12/27/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessagesViewController: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // user not logged in
        if Auth.auth().currentUser?.uid == nil {
            let loginController = LoginController()
            present(loginController, animated: false, completion: nil)
        }
    }

    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print("Error: \(String(describing: logoutError))")
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    

}

