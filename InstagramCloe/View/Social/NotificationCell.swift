//
//  NotificationCell.swift
//  InstagramCloe
//
//  Created by Apple on 15.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        
        didSet {
            
            guard let user = notification?.user else { return }
            guard let username = user.username else { return }
            guard let notificationMessage = notification?.notificationType.description else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            // configure notificatino type
            configureNotificationType()
            
            
            
            profileImageView.loadImage(with: profileImageUrl)
            
            notificationLabel.text = "\(username)\(notificationMessage)"
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        
       return iv
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(postTap)
        
       return iv
    }()
    
    // MARK: - Handlers
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    func configureNotificationLabel() {
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let username = user.username else { return }
        let notificationMessage = notification.notificationType.description
        guard let notificationDate = getNotificationTimeStamp() else { return }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(notificationDate). ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        notificationLabel.attributedText = attributedText

    }
    
    func configureNotificationType() {
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        
        var anchor: NSLayoutXAxisAnchor!
        
        if notification.notificationType != .Follow {
            
            //notification type is comment or like
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, widht: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            anchor = postImageView.leftAnchor


        } else {
            
            //notification type is follow
            
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, widht: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                   followButton.layer.cornerRadius = 3
            anchor = followButton.leftAnchor
            
            user.checkIfUserIsFollowed { (followed) in
                
                if followed {
                    //configure follow button for followed user
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                
                    
                    
                } else {
                    //configure follow button for non followed user
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    
                    
                    
                    
                }
                
                
            }
        }
        
        addSubview(notificationLabel)
        notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: anchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, widht: 0, height: 0)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func getNotificationTimeStamp() -> String? {
        
        guard let notification = self.notification else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1 //this is gonna make it 1h 1w 1m 1s..
        dateFormatter.unitsStyle = .abbreviated // kısaltma
        let now = Date()
        return dateFormatter.string(from: notification.creationDate, to: now)
        
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
    
        

        
}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}
}
