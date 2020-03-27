//
//  FollowCell.swift
//  InstagramCloe
//
//  Created by Apple on 7.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

class FollowLikeCell: UITableViewCell {
    //MARK: - Properties
    
    var delegate: FollowCellDelegate?
    
    var user: User? {
        
        didSet {
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            self.textLabel?.text = username
            
            self.detailTextLabel?.text = fullname
            
            // hide follow button for current user
            if user?.uid == Auth.auth().currentUser?.uid {
                followButton.isHidden = true
            }
            
            user?.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    //configure follow button for followed user
                    self.followButton.configure(didFollow: true)
                    
                } else {
                    //configure follow button for non followed user
                    self.followButton.configure(didFollow: false)
                    
                }
            })
        }
    }
    
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
       return iv
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Handlers
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
        
    }
    //MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, widht: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        
        textLabel?.text = "Username"
        detailTextLabel?.text = "Full name"
        
        self.selectionStyle = .none
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
