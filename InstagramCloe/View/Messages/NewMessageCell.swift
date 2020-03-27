//
//  NewMessageCell.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase


class NewMessageCell: UITableViewCell {

    
    // MARK: - Properties
    
    var user: User? {
        
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            textLabel?.text = username
            detailTextLabel?.text = fullname
        }
        
    }
    
    let profileImageView: CustomImageView = {
              let iv = CustomImageView()
              iv.clipsToBounds = true
              iv.contentMode = .scaleAspectFill
              iv.backgroundColor = .lightGray
              
             return iv
          }()
    
// MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, widht: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        textLabel?.text = "Joker"
        detailTextLabel?.text = "Heath Ledger"

        
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
}
