//
//  NewMessageController.swift
//  firebase-chat
//
//  Created by MacBookPro on 12/27/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var ref: DatabaseReference!
    var users = [ChatUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.title = "New Message"
        
        // fetch users
        fetchUser()
    }
    
    func fetchUser() {
        self.ref = Database.database().reference()
        
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = ChatUser()
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }

    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let chatUser = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(chatUser: chatUser)
        }
    }
}



