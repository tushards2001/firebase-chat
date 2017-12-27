//
//  ViewController.swift
//  firebase-chat
//
//  Created by MacBookPro on 12/27/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesViewController: UITableViewController {
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // new message button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        // user not logged in
        if Auth.auth().currentUser?.uid == nil {
            let loginController = LoginController()
            present(loginController, animated: false, completion: nil)
        } else {
            self.ref = Database.database().reference()
            
            let uid = Auth.auth().currentUser?.uid
            ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
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
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    

}

