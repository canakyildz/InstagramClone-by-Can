//
//  Protocols.swift
//  InstagramCloe
//
//  Created by Apple on 7.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
    
}

protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol Printable {
    
    var description: String { get } //when we conform to this protocol in our enum, we're gonna have to implement this description variable and it's going to require us to get a string
}

