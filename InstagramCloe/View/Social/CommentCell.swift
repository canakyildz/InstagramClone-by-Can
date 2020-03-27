//
//  CommentCell.swift
//  InstagramCloe
//
//  Created by Apple on 14.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        
        didSet {
            
            //lets fill the data now. profileimg , commenttext,username..
            guard let user = comment?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            guard let username = user.username else { return }
            guard let commentText = comment?.commentText else { return }
            guard let timestamp = getCommentTimeStamp() else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedText.append(NSAttributedString(string: " \(timestamp). ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            commentTextView.attributedText = attributedText
            
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        
       return iv
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        return tv
    }()
    
    func getCommentTimeStamp() -> String? {
        
        guard let comment = self.comment else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1 //this is gonna make it 1h 1w 1m 1s..
        dateFormatter.unitsStyle = .abbreviated // kısaltma
        let now = Date()
        return dateFormatter.string(from: comment.creationDate, to: now)
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 40, height: 40)
       
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, widht: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
