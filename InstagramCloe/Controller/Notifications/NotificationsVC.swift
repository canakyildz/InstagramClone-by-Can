//
//  NotificationsVC.swift
//  InstagramCloe
//
//  Created by Apple on 3.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController , NotificationCellDelegate{
    
    
    // MARK: - Properties
    var timer: Timer?

    var notifications = [Notification]() // () is to initialize it.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //clear seperator lines
        tableView.separatorColor = .clear
        
        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //naigation title
        navigationItem.title = "Notifications"
        
        // fetch notifications
        fetchNotifications()
        
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        //dequeuereusablecell: maintaing a queue in our table/collection view everytime cell goes out of view, that cell is dequeued it becomes requeued only when its about to come back to dequeued view. like moving it down up..
        cell.notification = notifications[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // MARK: - NotificationCellDelegate Protocol
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            user.unfollow()
            //configure follow button for non followed user
            cell.followButton.configure(didFollow: false)
            
        } else {
            user.follow()
            cell.followButton.configure(didFollow: true)
            
                       
            
            
        }
        
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        guard let notification = cell.notification else { return }
        
        if notification.notificationType == .Comment {
            let commentController = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
            commentController.post = post
            navigationController?.pushViewController(commentController, animated: true)
        } else {
            let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
            feedController.viewSinglePost = true
            feedController.post = post
            navigationController?.pushViewController(feedController, animated: true)
        }
    }
    
    // MARK: - Handlers
   
    
   @objc func handleSortNotifications() {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }
    func handleReloadTable() {
           self.timer?.invalidate()
           self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
       }
    
   // MARK: - API
    
        func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let notificationId = snapshot.key
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                Database.fetchUser(with: uid, completion: { (user) in
                    
                    // if notification is for post
                    if let postId = dictionary["postId"] as? String {
                        Database.fetchPost(with: postId, completion: { (post) in
                            let notification = Notification(user: user, post: post, dictionary: dictionary)
//                            if notification.notificationType == .Comment {
//                                self.getCommentData(forNotification: notification)
//                            }
                            self.notifications.append(notification)
                            self.handleReloadTable()
                        })
                    } else {
                        let notification = Notification(user: user, dictionary: dictionary)
                        self.notifications.append(notification)
                        self.handleReloadTable()
                    }
                })
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
            })
        }
    }
}
