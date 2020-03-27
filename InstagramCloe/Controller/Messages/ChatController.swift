//
//  ChatController.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import Foundation
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var user: User? //we need that user cuz in that chat controller its gonna be associated with antoher user so also messages will be populated beetwen users
    var messages = [Message]()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, widht: 50, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(messageTextField)
        messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 4, widht: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0.5)
        
        return containerView
    }()
    
    let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message.."
        return tf
    }()
 
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        configureNavigationBar()
        
        observeMessages()
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
    }
    
    override var inputAccessoryView: UIView? { //sumtin we doin instead of doing it in viewdidload as traditionally.
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80 //place holder value,dont worry.it will be given as estimateframefortext....
        
        let message = messages[indexPath.row]
        
        height = estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.message = messages[indexPath.row]
        
        configureMessage(cell: cell, message: messages[indexPath.row])
        
        return cell
    }
    
    // MARK: - Handlers
    @objc func handleSend() {
        uploadMessageToServer()
        //once we hit that send button we want the field to be blink.
        messageTextField.text = nil
        
    }
    @objc func handleInfoTapped() {
        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    func estimateFrameForText(_ text: String) -> CGRect {
        //what needs to happen is we need to dynamically control size of our chatcells.thats gonna be handled in our layout collection viewlayout function upstairs.we gonna write this out function called estimateframefortext then we will create a cgsize using rectangle thats created from this function
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil) //text parameter we pass in from func.
        
        
    }
    
    func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
        
        if message.fromId == currentUid {
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
        }
        
    }
    
    func configureNavigationBar() {
        guard let user = self.user else { return }
        
        navigationItem.title = user.username
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        
    }
    
    // MARK: - API
    
    func uploadMessageToServer() {
        
        guard let messageText = messageTextField.text else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return} //fromId
        guard let user = self.user else { return } //toId
        let creationDate = Int(Date().timeIntervalSince1970)
        
        // UPDATE: - Safely unwrapped uid to work with Firebase 5
        guard let uid = user.uid else { return }
        
        let messageValues = ["creationDate": creationDate,
                             "fromId": currentUid,
                             "toId": user.uid,
                             "messageText": messageText] as [String: Any]
        //lets write some stuff to structure these values to firebase
        
        let messageRef = MESSAGES_REF.childByAutoId()
        // UPDATE: - Safely unwrapped messageKey to work with Firebase 5
        guard let messageKey = messageRef.key else { return }
        
        messageRef.updateChildValues(messageValues) //now tricky moments.
        //we will have a messages ref in firebase,then it will have some messageid, it will have messagetext with a string value; it will have fromid,toid with some values. !! But we also will have user-messages structure there, in there we will have user and inside it;another user who current user is contacting to; then messageids. THAT THING will happen for both of users.
        //cuz message involves two people,we need to have a user-message section and we need to upload that message to both message sections when we send a message.
        USER_MESSAGES_REF.child(currentUid).child(user.uid).updateChildValues([messageKey: 1])
        USER_MESSAGES_REF.child(user.uid).child(currentUid).updateChildValues([messageKey: 1])

    }
    
    func observeMessages() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = self.user?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            
            let messageId = snapshot.key
            self.fetchMessage(withMessageId: messageId)
        }
        
    }
    
    func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            self.collectionView.reloadData()
        }
    }
    
    
    
}
