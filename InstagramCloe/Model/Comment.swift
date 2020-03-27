//
//  Comment.swift
//  InstagramCloe
//
//  Created by Apple on 14.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//


//we do construct comment custom object so everytime we fetch a comment we go to database construct our comment programmmatically using a custom object we are gonna create and it's gonna have these 3 guys as attributes(commenttext creationdate uid [in database comments->postid->commentid->] that way everytime we populate a cell we can create our datasource array that's gonna be filled with comments and then tell our code to fill each cell with comment that we're gonna get from that array and we will populate that array by fetching all that information from database just like user and post.
//everytime you wanna construct something that includes different type of attributes yo uwanna create an object/modal.

import Foundation
import Firebase



class Comment {
    
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    init(user: User,dictionary: Dictionary<String, AnyObject>) { //stuff upstairs besides user will be handled by dictionary.
        
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            //to set this user you gotta use this "uid" , we used dictionary to set our user//upd.
            self.uid = uid
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText

        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
}
