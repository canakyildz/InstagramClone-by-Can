//
//  MessagesVC.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessageCell"

class MessagesController: UITableViewController {
    
    // MARK. - Properties
    
    var messages = [Message]()
    var users = [User]() //store all of our users in array. and we inittted it.
    var messagesDictionary = [String: Message]() // using this to make it so that even tho we have two messages or how many messages we have with user,we anna have the last message.
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure navigation bar
        configureNavigationBar()
        
        //register cell
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch messages
        fetchMessages()
    
    }
    
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        
        cell.message = messages[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnetId = message.getChatPartnerId()
        Database.fetchUser(with: chatPartnetId) { (user) in
            self.showChatController(forUser: user)
            //we got the message that is associated with a particular row which is being selected and then we go and see who our chatpartnerid is. we need a user to pass into chatcontroller so we fetch our user with that chatpartnerid which is toId. and we show the chatcontroller for that user in our completion.
        }
        
    }
    
    // MARK: - Handlers
    @objc func handleNewMessage() {
         let newMessageController = NewMessageController()
               newMessageController.messagesController = self
         let navigationController = UINavigationController(rootViewController: newMessageController)
         self.present(navigationController, animated: true, completion: nil)
       }
    
    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user // this user is the user we are passing in from our function(for user user: User)
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
    
    
    // MARK: - API
    
    func fetchMessages() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let uid = snapshot.key
            
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { (snapshot) in
                print(snapshot)
                
                let messageId = snapshot.key
                //we will use helper function to take these messageIds and then go to message structure and construct
                
                self.fetchMessage(withMessageId: messageId)
            }
        }
        
    }
    
    //we created a messagesdictionary because thats gonna give us the correct system to sort of consolidate all the message that we have with one useer and we are gonna associate all those messages with a single key which will be chatpartnerid and the value for that key is gonna be =message
    //now we dont have duplicate thing.thats because we have that messagesdictionary and key inside it.so then we construct an array that contains all the messages under one chatpartnerId and as last object of our array it displays last message.
    func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            self.messagesDictionary[chatPartnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            self.tableView.reloadData()
            //look, that messagesdictionary part is confusing. take a look at it later on.
        }
    }
    
    
    
   
}


