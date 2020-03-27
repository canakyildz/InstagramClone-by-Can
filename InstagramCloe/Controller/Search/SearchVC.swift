//
//  SearchVC.swift
//  InstagramCloe
//
//  Created by Apple on 3.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController , UISearchBarDelegate , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
  
    
    // MARK: - Properties

    
    var users = [User]()
    var searchBar = UISearchBar()
    var filteredUsers = [User]()
    var inSearchMode = false
    var collectionView: UICollectionView!
    var collectionViewEnabled = true
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cel lclasses
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //seperator insts
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        
        //configure search bar
        configureSearchBar()
        
        // configure collection view
        configureCollectionView()
        
        //fetch posts
        fetchPosts()
        
        //fetch users
        fetchUsers()
        

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {// #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredUsers.count
        } else {
           return users.count
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: User! //thats going to be set whether or not we are in search mode.
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        //create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userprofile vc
        userProfileVC.user = user
        
        //push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        var user: User! //thats going to be set whether or not we are in search mode.
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.user = user
        return cell
    }
    
    // MARK: - UICollectionView
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        tableView.addSubview(collectionView)
        
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        tableView.separatorColor = .clear
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3 // 2 seperator and 3 squares.
        return CGSize(width: width, height: width)//to make it square
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchPostCell
        cell.post = posts[indexPath.row]
        return cell
      }
      
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
                     feedVC.viewSinglePost = true
                     
                     feedVC.post = posts[indexPath.row]
                     
                     navigationController?.pushViewController(feedVC, animated: true)
    }
    
    
    
    
    // MARK: - Handlers
   
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //wanna add a cancel button so user can exit search bar
        searchBar.showsCancelButton = true
        
        collectionView.isHidden = true
        collectionViewEnabled = false
        
        tableView.separatorColor = .lightGray
        //table view reload guy
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //handle search text change
        
        let searchText = searchText.lowercased()
        
        //determine if user searching or not(insearchmode) //if theres text then it's true
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            tableView.reloadData() //cuz if we delete all the text in search,we wanna reload the tableview with original users array.
        } else {
            inSearchMode = true
            //filter filteredusers by username
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText) //?
                
            })
            tableView.reloadData()
        }
 
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        inSearchMode = false //when we click cancel button we wanna make sure we outta it.
        searchBar.text = nil
        
        collectionViewEnabled = true
        collectionView.isHidden = false
        
        tableView.separatorColor = .clear
        
    }

    
    //MARK: - API
    
    func fetchUsers() {
        //childadded ekledigim data structerindeki her datayı alıyor. yani tüm kullanıcıları bulmamızı sağlar
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            //uid
            let uid = snapshot.key

            Database.fetchUser(with: uid) { (user) in
                
                self.users.append(user)
                
                self.tableView.reloadData()
            }
        
    }
}
    
    func fetchPosts() {
        posts.removeAll()
        
        POSTS_REF.observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
                
            }
        }
    }
}
