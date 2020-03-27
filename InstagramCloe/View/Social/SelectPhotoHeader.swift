//
//  SelectPhotoHeader.swift
//  InstagramCloe
//
//  Created by Apple on 8.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class SelectPhotoHeader: UICollectionViewCell {
    
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
       return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
