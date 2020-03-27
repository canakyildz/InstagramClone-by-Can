//
//  SearchPostCell.swift
//  InstagramCloe
//
//  Created by Apple on 16.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class SearchPostCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var post: Post? {
        
        didSet {
            
            print("did set post")
            guard let imageUrl = post?.imageUrl else { return }
            postImageView.loadImage(with: imageUrl)
            //so now we need to set our post and when we set it it will give us that didset stuff
        }
    }

    
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        
       return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(postImageView)
               postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
