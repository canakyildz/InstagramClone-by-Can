//
//  MessagesCell.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {
    
    // MARK: - Properties
    
    var message: Message? {
        
        didSet {
            guard let messageText = message?.messageText else { return }
            detailTextLabel?.text = messageText
            
            if let seconds = message?.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timestampLabel.text = dateFormatter.string(from: seconds)
            }
            
            configureUserData()
        }
        
    }
    
    let profileImageView: CustomImageView = {
           let iv = CustomImageView()
           iv.clipsToBounds = true
           iv.contentMode = .scaleAspectFill
           iv.backgroundColor = .lightGray
           
          return iv
       }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.text = "2h"
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        //since its a subtitle cell we dont need to create labels for whats gonna be added for our actual message (for now).(main text will be username and detailtextlabel will be actual message
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, widht: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, widht: 0, height: 0)
        
        textLabel?.text = "Joker"
        detailTextLabel?.text = "Some test label to see what it looks like."
    }
    override func layoutSubviews() { //this is how we position our cells text label and detail text label
        super.layoutSubviews()
        
        
        textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    func configureUserData() {
        
        guard let chatPartnerId = message?.getChatPartnerId() else { return }
        //so now we have who we talking to now then; we will take that userid we just got back and get our user's information
        
        Database.fetchUser(with: chatPartnerId) { (user) in
            
            self.profileImageView.loadImage(with: user.profileImageUrl)
            self.textLabel?.text = user.username
        }
        
    }
    

}


