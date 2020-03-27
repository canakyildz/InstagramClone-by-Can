//
//  FeedCell.swift
//  InstagramCloe
//
//  Created by Apple on 12.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

//modal view controler system requires this as next;
//we have been going through MVC system,creating protocols to handle actions for those buttons that are associated with each cell so we can handle the actions in our view controller files instead of view files. we have FeedVC,we want to handle these actions in that controller. So we will create protocol (feedcelldelegate), after that we want to create a new MARK (feedcelldelegate protocol) of course after adding FeedCellDelegate to our class.Into that section of mark we will be adding these subs of the protocol we've created and right after that we will jump into our feedcell and call our delegate as creating -> var delegate:  FeedCellDelegate? (right under class) and add action to these buttons.
//after adding target to our buttons we made sure to connect our handlers with main functions in FeedVC with that example of code

// MARK: - Handlers
//   @objc func handleUsernameTapped() {
//       delegate?.handleUsernameTapped(for: self) //this one is very key here. we wont write function features in the feedcell but only delegate.
//   }



import UIKit
import Firebase

class FeedCell: UICollectionViewCell {
    
    var delegate: FeedCellDelegate? //a bridge that connects feedcell and feedvc
    
    var post: Post? {
        
        didSet {
            
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageUrl = post?.imageUrl else { return }
            guard let likes = post?.likes else { return }
            
            Database.fetchUser(with: ownerUid) { (user) in //this function fetchuser comes handy here and why we have to set the post owneruid or set that as a value on our database so we can get these users' information that's associated with the particular post
                
                self.profileImageView.loadImage(with: user.profileImageUrl)
                self.usernameButton.setTitle(user.username, for: .normal)
                self.configurePostCaption(user: user)
                
            }
            
            postImageView.loadImage(with: imageUrl)
            likesLabel.text = "\(likes) likes"
            
            configureLikeButton()
            
            
            
        }
        
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
       return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        
    return button
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("°°°", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        
        //add gesture recognizer for double tab to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(likeTap)
        
       return iv
    }()
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"),for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)

        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"),for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)

        return button
    }()
    
    let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"),for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        return button
    }()
    
    let savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"),for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "3 likes"
        
        //add gesture recofnizer to label
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Username", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " Some test caption for now", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        label.attributedText = attributedText
        return label
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(optionsButton)
        optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, widht: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        
        configureActionButtons()
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, widht: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, widht: 0, height: 0)
        
    }
    
    // MARK: - Handlers
    
    @objc func handleUsernameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }
    
    func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    
    func configurePostCaption(user: User?) {
        guard let post = self.post else { return }
        guard let caption = post.caption else { return }
        
        let attributedText = NSMutableAttributedString(string: user!.username, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " \(caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        captionLabel.attributedText = attributedText
        
    }
    @objc func handleDoubleTapToLike() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    
    func configureActionButtons() {
        
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 120, height: 50)
        
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, widht: 20, height: 24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
