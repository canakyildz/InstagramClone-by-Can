//
//  CommentVC.swift
//  InstagramCloe
//
//  Created by Apple on 14.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var comments = [Comment]() //we used it then we gonna fetchcomments from database then use this array to populate them comments down there homie.
    var post: Post?
    
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        containerView.addSubview(postButton)
        postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, widht: 50, height: 0) //we did add widht to avoid weird shit
        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, widht: 0, height: 0)
        
        
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0.5)
        
        containerView.backgroundColor = .white
        
        return containerView
        //instead adding this to subview we will go and use input accessory view to this collectionview, when we go down there //cmd+k
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment.."
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true //this means collection view will always move up and down regardless
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        //navigation title
        navigationItem.title = "Comments"
        
        //register cell class
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //fetch comments
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) { //we want to hide nav bar. so it will be good to hide it initially
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) { //this is gonna get called when this func gets cancelled..
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
    get {
        return containerView
       }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //dynamically size
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        //create a dummy cell //this is how we control dynamically sizing our cell
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.row]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
        //let est. line is gonna make it so that if we have to layout this cell with the constraints it needs to for the height and weight,then height max thing comes which is gonna be 
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.row]
        
        return cell
    }
    
    // MARK: - Handlers
    @objc func handleUploadComment() {
        
        guard let postId = self.post?.postId else { return }
        guard let commentText = commentTextField.text else { return } //thats gonna be the commenttext in database dict.
        guard let uid = Auth.auth().currentUser?.uid else { return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": commentText,
                      "creationDate": creationDate,
                      "uid": uid] as [String: Any]
        
        //we did make it a completion block so we wanna make sure that our database values get updated before we clear comment text. say that stuff didnt happen in order or somestuff,it might accidentally upload comment text as being nothing.
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.uploadCommentNotificationToServer()
            self.commentTextField.text = nil
        } //we do that cuz we go to comments and we go to postid so then we add comment with auto id
    }
    
    func fetchComments() {
        
        //we will go to our comment structure and go into postid then get all the comments associated with all that post. //we used childadded because ! we wanna observe everytime a comment is added to the structure so we can see it being updated in real time. //this guardlet postid thing means! we are checking to make sure that this postid exists and we are storing it in postId(guard let "postid" if it doesnt it will return. // if you force unwrapping it and it didnt find a postid app would crash.
        guard let postId = self.post?.postId else { return }
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid) { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                print("user that commented is \(comment.user?.username)")
                self.collectionView?.reloadData()
            }
            
        }
    }
    
    func uploadCommentNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post?.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //notifivation values
        let values = ["checked" :0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": COMMENT_INT_VALUE,
                      "postId": postId] as [String: Any]
        
        // upload comment notification to server
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }
    
}
