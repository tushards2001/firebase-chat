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

class MessagesViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // new message button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timestamp = dictionary["timestamp"] as? String
                    message.toId = dictionary["toId"] as? String
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return Int(message1.timestamp!)! > Int(message2.timestamp!)!
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (timer) in
                        DispatchQueue.main.async {
                            print("reload table data")
                            self.tableView.reloadData()
                        }
                    })
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer:Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    func checkIfUserIsLoggedIn() {
        // user not logged in
        if Auth.auth().currentUser?.uid == nil {
            let loginController = LoginController()
            present(loginController, animated: false, completion: nil)
        } else {
            fetchUserAndSetNavBarTitle()
        }
    }
    
    func fetchUserAndSetNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let chatUser = ChatUser()
                chatUser.name = dictionary["name"] as? String
                chatUser.email = dictionary["email"] as? String
                chatUser.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setupNavBarWithUser(chatUser: chatUser)
                //self.navigationItem.title = dictionary["name"] as? String
                //print(self.navigationItem.title!)
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(chatUser: ChatUser) {
        messages.removeAll()
        messagesDictionary.removeAll()
        self.tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = UIColor.red
        
        // container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        
        if let profileImageUrl = chatUser.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        // ios9 constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = chatUser.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1, constant: 0)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        /*let tap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
        self.view.addGestureRecognizer(tap)*/
        
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    func showChatControllerForUser(chatUser: ChatUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.chatUser = chatUser
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print("Error: \(String(describing: logoutError))")
        }
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = self.messages[indexPath.row]
        cell.message = message
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let chatUser = ChatUser()
            chatUser.id = chatPartnerId
            chatUser.name = dictionary["name"] as? String
            chatUser.email = dictionary["email"] as? String
            chatUser.profileImageUrl = dictionary["profileImageUrl"] as? String
            
            self.showChatControllerForUser(chatUser: chatUser)
        }, withCancel: nil)
        
        
    }
    

}

