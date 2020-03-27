//
//  Post.swift
//  InstagramCloe
//
//  Created by Apple on 10.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

//we can have access to all the good stuff on database from post section and use them like caption , creationdata..

import Foundation
import Firebase

class Post {
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    //adding user parameter so we wont have to fetch user everytime we click the profile // we got two errors after implementing user variable to init func. we will add the missing argument to feedvc so we will fetch user //we added it also because each post has user associated with it so it makes sense to initialize each post with the user who made that post 
    var user: User?
    var didLike = false
    //this is gonna keep track of whether or not user likes post or no we will set it to true if we go into database section (user-likes) and  see that user has liked the particular post
    
    init(postId: String!,user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
               if let caption = dictionary["caption"] as? String {
                   self.caption = caption
               }
               
               if let likes = dictionary["likes"] as? Int {
                   self.likes = likes
               }
               
               if let imageUrl = dictionary["imageUrl"] as? String {
                   self.imageUrl = imageUrl
               }
               
               if let ownerUid = dictionary["ownerUid"] as? String {
                   self.ownerUid = ownerUid
               }
               
               if let creationDate = dictionary["creationDate"] as? Double {
                   self.creationDate = Date(timeIntervalSince1970: creationDate)
               }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //update: unwrap post id to work with firebase
        guard let postId = self.postId else { return
            
        }
        if addLike {
            
            //
            
            
            //updates user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { (err, ref) in
                
                //send noifications to server
                self.sendLikeNotificationToServer()
                //now we gonna go to post-likes structure and say post1 has been liked by such and such
                //updates post-likes structure
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid:1]) { (err, ref) in
                   
                    self.likes = self.likes + 1
                    self.didLike = true //this two will not be set until our database structure is updated
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes) //it's gonna go to our post section then postid we lookin at then find likes thing and set value for lkes. //we added this lineof code to both of them because if we put that outside of completion blocks before these comletion thing gets finished this line will be completed..
                  
            //so with this completion block we make sure these last two lines of code doesnt get set until postid and currentuid thing gets updated on database.
                }
            }
        } else {
            
            // observe database for notification id to remove
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                
                
                //notification id to remove from server
                guard let notificationID = snapshot.value as? String else { return }
                
                // remove notification from server
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue { (err, ref) in
                    //remove like from user-like structure
                    USER_LIKES_REF.child(currentUid).child(self.postId).removeValue { (err, ref) in
                        //remove user from post-like structure
                        POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { (err, ref) in
                            guard self.likes > 0 else { return }
                            self.likes = self.likes - 1
                            self.didLike = false
                            completion(self.likes)
                            
                            POSTS_REF.child(self.postId).child("likes").setValue(self.likes) //it's gonna go to our post section then postid we lookin at then find likes thing and set value for lkes.//we added this lineof code to both of them because if we put that outside of completion blocks before these comletion thing gets finished this line will be completed..
                        }
                    }
                }
            }
        }
//        print("this post has \(likes) likes")
    }
    
    func sendLikeNotificationToServer() {
        
        //we def need current users id so we can tell who that not. is from
               guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        
         //only send notification if like is for post that is not current user's.
        if currentUid != self.ownerUid {
            
            //notifivation values
            let values = ["checked" :0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId": postId] as [String: Any]
            
            
            // notification database referance
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            
            
            //upload notification values to database
            notificationRef.updateChildValues(values) { (err, ref) in
                
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
                //it's gonna take this notref. weve created and it's gonna give us the key which created by childbyautoid guy upstairs and we gonna store that value in our database in our user-likes section
            }
        }
        
    }
    
}
