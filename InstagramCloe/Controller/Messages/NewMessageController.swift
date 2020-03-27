//
//  NewMessageController.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessageController: UITableViewController {
    
    // MARK. - Properties
    var users = [User]()
    var messagesController: MessagesController?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure navigation bar
        configureNavigationBar()
        
        //register cell
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchUsers()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count 
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
    
    cell.user = users[indexPath.row]
    
    return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row] //we have this let user thing here because we want to pass a user to chatcontroller (we had a user variable under properties mark so )
            self.messagesController?.showChatController(forUser: user) //we need to pass a value into that messageController variable up there.
            
        }
    }
    // MARK: - Handlers
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
      func configureNavigationBar() {
          navigationItem.title = "New Message"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
          
      }
    
    // MARK: - API
       
       func fetchUsers() {
           USER_REF.observe(.childAdded) { (snapshot) in
               let uid = snapshot.key
               
               if uid != Auth.auth().currentUser?.uid {
                   Database.fetchUser(with: uid, completion: { (user) in
                       self.users.append(user)
                       self.tableView.reloadData()
                   })
               }
           }
       }
      
    
}
