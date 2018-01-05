//
//  Message.swift
//  firebase-chat
//
//  Created by MacBookPro on 1/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import FirebaseAuth

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: String?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
