//
//  Extensions.swift
//  InstagramCloe
//
//  Created by Apple on 1.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            //handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
            
        } else {
            //handle unfollow user //dont get it confused,self thing here refers to uIButton.
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}


extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor? ,paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, widht: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
            
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
            
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            
        }
        if widht != 0 {
            widthAnchor.constraint(equalToConstant: widht).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
//will be stored on local storage(instead of loading image again again)

    
    

extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return } //saying: we have this dictionary that we got back as our snapshot.value and we are casting this as a dictionary of type string and anyobject. so when we say  dictionary["ownerUid"] is going database and saying look at this dictionary (of a particular post) and give me the value for this ownerUid key
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { (user) in //after storing that value in that ownerUid constant,then we are fetching associated user(with: ownerUid  for that post with that fetchuser function and then fetching our post down here in the completion block. and init'ing it with user

                
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                completion(post)
            }
        }
    }
}
