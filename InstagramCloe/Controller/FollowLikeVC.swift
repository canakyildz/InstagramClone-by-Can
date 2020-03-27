//
//  FollowVC.swift
//  InstagramCloe
//
//  Created by Apple on 7.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowLikeVC: UITableViewController, FollowCellDelegate {
    //MARK: - Properties
    
    //since boolean variables only can check if someting true or false, to get to keep tracking of a lot of values like; what kinda view mode in or you gota make something involving a lot of custom types it's good to use enumeration, you can make a structure including a lot of types
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following //we have to put a default case here or if we dont have it, it will say switch must be exhaustive and we cant exhaust all the integers that exists in mathmetical universe so for this case we will say default. we cant say default: break. too we gotta say default: self =..
                //so what's happening here is it's to keep track of what view mode we are in. we casted it as a int value because we will give these cases numbers like 0 1 2  and we will initiliaze this enum with some int value that we will get from the previous vcontroller we have to set the value of enum so then we can load the correct data in our app. //now we gotta create instance for this enum. it was upstairs was definition of enum. now we need an actual value downstairs
            }
        }
    }
    
    var postId: String?
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell class
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
       
        
        
            
            //configure nav title
            configureNavigationTitle()
            
            //fetch users
            fetchUsers()
            
        
        //clear sep lines
        tableView.separatorColor = .clear
        

        
        
    }
    //MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        cell.delegate = self
        
        cell.user = users[indexPath.row]
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    //MARK: - FollowCellDelegate Protocol
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            
            user.unfollow()
            
            //configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
        } else {
            
            user.follow()
            
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
            
        }
    }
    // MARK: - Handlers
    func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .Followers: navigationItem.title = "Followers"
        case .Following: navigationItem.title = "Following"
        case .Likes:     navigationItem.title = "Likes"
            //we dont need default because our switch is exhousted we go thru all the cases in our enum. it was based on index: int before so we had to add default
        }
    }
    
    //MARK: -API
    
    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil } //because weve given databasereference return value upstairs, we have to reutnr to something when we give function a return value
        
        switch viewingMode {
        case .Followers: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes:     return POST_LIKES_REF //that's cuz we looking at what users've liked a particular post. so we didnt go with user_likes_ref.
        }
    }
    
    func fetchUser(with uid: String) {
        Database.fetchUser(with: uid) { (user) in
            
            self.users.append(user)
            
            self.tableView.reloadData()
        }
        
    }
    
    func fetchUsers() {
        
        guard let ref = getDatabaseReference() else { return }
        guard let viewingMode = self.viewingMode else { return }
        
        //we will use enum instead of boolean variables.
        
        switch viewingMode {
        case .Followers, .Following:
            guard let uid = self.uid else { return }

            ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    self.fetchUser(with: uid)
                    
                    
                }
            }
            
        case .Likes:
            guard let postId = self.postId else { return }
            
            ref.child(postId).observe(.childAdded) { (snapshot) in
                
                let uid = snapshot.key
                self.fetchUser(with: uid)
            }
            
    
        }
        
        
        
    }
}
