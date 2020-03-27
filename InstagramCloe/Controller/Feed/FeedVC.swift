//
//  FeedVC.swift
//  InstagramCloe
//
//  Created by Apple on 3.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//
//to see posts of users who you follow, 2 ways; but we will go with one thing for pagination(to limit the loaded posts so when you go bottom you will be loading by time,just to avoid fetching all the posts from database and stuff.

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    
    
    
 
    

    // MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false //this is to create a logic to see if user wants to check a single post or whole feed /to avoid creating another vc for it.
    var post: Post? //so that we can pass the post that we click on to this viewcontroller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        

        

        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //configure button
        configureNavigationBar()
        
        //conf. fetch posts
        if !viewSinglePost {
            fetchPosts()
        }
        updateUserFeeds()
        
        //conf refresh controler
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

        // Do any additional setup after loading the view.
    }

    
    // MARK: UICollectionViewLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8//adding 8 , 40 , 8 height to cell
        height += 50
        height += 60
        return CGSize(width: width, height: height)
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post

            }
        } else {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - FeedCellDelegate Protocol
    
    
    
    func handleUsernameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return } //now we can have access to user that we want to send over from the post we have in our cell whch is the guy FeedCell-> -> var post: Post? didset ... we are able to access that post variable because we are using that input parameter (for cell: FeedCell) so we have access to that post via the cell that we are taking as input parameter there. for -cell:- is = -cell-.post
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user //passed this user value that we getting from this post that's in the line.
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
     
     func handleOptionsTapped(for cell: FeedCell) {
         print("handle options tapped")
     }
     
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        if post.didLike {
            //handle unlike post
            //where we gonna handle if the user has already liked the post,if we liked post already then we wanna remove the like
            if !isDoubleTap { //we dont want it to unlike post when doubletapped.
                post.adjustLikes(addLike: false) { (likes) in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                }

            }
        } else {
            //handle like post
            post.adjustLikes(addLike: true) { (likes) in
            cell.likesLabel.text = "\(likes) likes"
            cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
        }
        
        guard let likes = post.likes else { return } //we do it like that to avoid Optional thingy
        
    }
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
     
    func handleConfigureLikeButton(for cell: FeedCell) {
    
    guard let post = cell.post else { return }
    guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(postId) {
                
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                
            }
            }
            }
    
     func handleCommentTapped(for cell: FeedCell) {
        //grap our postid
        guard let post = cell.post else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    
    // MARK: - Handlers
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        fetchPosts()
        collectionView?.reloadData()
    }
    
    @objc func handleShowMessages() {
        
        let messageController = MessagesController()
        navigationController?.pushViewController(messageController, animated: true)
    }
    
//    func updateLikeStructures(with postId: String, addLike: Bool) { // we need that post id so we added it as a parameter//addlike has been added later to check liked or removing it.
//        
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//        //we gonna go in user-likes->current user's id and add postid there to say yea batman liked that post
//        if addLike {
//            
//        } else {
//             //we also need to keep tracking of whether or not user adding like to post or removing post on database so we added addlike boolean to updatelikestructures function.
//        }
//    }
    
    func configureNavigationBar() {
        
        if !viewSinglePost {
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain , target: self,action: #selector(handleShowMessages))
        
        self.navigationItem.title = "Feed"
    }
    
    @objc func handleLogout() {
        
        //declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //add alert logout action
        alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
            do {
                //attempt sign out
                try Auth.auth().signOut()
                
                //present login controller
                let loginVC = LoginVC()
                
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } catch {
                //handle error
                print("failed to sign out")
                
            }
        }))
        //cancel alert
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
   // MARK: - API
    
    func updateUserFeeds() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followingUserId = snapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { (snapshot) in
                
                let postId = snapshot.key
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            }
        }
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
        
    }
    
    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                
                self.posts.sort { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                }
                
                //stop refreshing
                self.collectionView?.refreshControl?.endRefreshing()
                self.collectionView?.reloadData()
            }
                }
                }
    
}
