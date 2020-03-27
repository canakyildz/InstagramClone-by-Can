//
//  UploadPostVC.swift
//  InstagramCloe
//
//  Created by Apple on 3.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase


class UploadPostVC: UIViewController, UITextViewDelegate {
    //added uitextviewdelegate so we have access to some functions of  the textview

    // MARK: - Properties
    
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        
       return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure view components
        configureViewComponents()
        
        //load ımage
        loadImage()
        
        //text view delegate(this is telling that this view controller is gonna be the delegate for handling everything that associated with this captiontextview
        captionTextView.delegate = self
        
        view.backgroundColor = .white
        
        
        

        
    }
    // MARK: - UITextView
    //everytime our txtvvew has some kind of change happen like user deleting/adding text in
    func textViewDidChange(_ textView: UITextView) {
        
        shareButton.isEnabled = false
        
        guard !textView.text.isEmpty else {
            
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
            //whenever textview is empty it's gonna make sure that button is disabled and color
            
        } // with ! this is gonna make sure that our textview isnt empty
    
        //that textview did change can be called after delegate,so when we print (textview.text) this textview is our captiontextview. delegate makes it known as cpttextview
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    // MARK: - Handler
    
    func updateUserFeeds(with postId: String) {
        
        //current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //getting our database values
        let values = [postId: 1] //values that we will update in our firebase
        
        //need to update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        //update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    @objc func handleSharePost() {
        
        // paramaters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //same process as uploading userprofileimg to database
        //image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        
        //creation date //how long ago post was made? we will construct this creationDate to do so.
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //upload storage
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // handle error
            if let error = error {
                print("Failed to upload image to storage with error", error.localizedDescription)
                return
            }
            
           storageRef.downloadURL(completion: { (url, error) in
                guard let imageUrl = url?.absoluteString else { return }
                
                // post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
            // post id
            let postId = POSTS_REF.childByAutoId()
          guard let postKey = postId.key else { return }
            
            // upload information to database
            postId.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
            // uptade user-post structure
                let userPostsRef = USER_POSTS_REF.child(currentUid)
                userPostsRef.updateChildValues([postKey: 1])
                //post id is the first value below "posts" structure
                
                //update user-feed structure
                self.updateUserFeeds(with: postKey)
                
            // return to home feed
            self.dismiss(animated: true, completion: {
                self.tabBarController?.selectedIndex = 0
                })
            })
            })
        }
        
        
    }
    
    func configureViewComponents() {
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, widht: 100, height: 100)
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, widht: 0, height: 100)
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, widht: 0, height: 40)
    }
    func loadImage() {
        
        guard let selectedImage = self.selectedImage else { return }
        
        photoImageView.image = selectedImage
    }
}
