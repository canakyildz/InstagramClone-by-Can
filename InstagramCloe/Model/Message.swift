//
//  Message.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
// imagine if we didnt write this class out,everytime we wanted to sort of get some of these attributes wed have to write code like this we have to be retrieving information from our database like this wheras when we now want to construct a message all we have to do is pass in a dictionary that we get back from our database and then we have access to all these attributes below.

import Foundation
import Firebase

class Message {
    
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        
    }
    //we writing this function to this class because we are following mvc.
    func getChatPartnerId() -> String {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return ""}
        
        //if the message is from current user then our chat partner id is gonna be the person that message is to, (toId).If otherwise chatpartner is gonna be fromId
        //so we have a message beetwn batman and joker. we tryna figure out who it is we are talking to; if message is from myself(joker) then it's gonna return BATMAN as my chatpartner. other way,it would return to me(joker/fromid) because message was from joker.
        if fromId == currentUid {
            return toId
        } else {
            return fromId
        }
        
    }
    
}
