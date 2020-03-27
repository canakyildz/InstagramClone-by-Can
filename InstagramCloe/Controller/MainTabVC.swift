//
//  MainTabVCViewController.swift
//  InstagramCloe
//
//  Created by Apple on 3.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController,UITabBarControllerDelegate {
    
    // MARK: - Properties
    let dot = UIView()
    var notificationIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //delegate
        self.delegate = self
        
        //configure view controllers
        
        configureViewControllers()
        
        // configure notificaion dot
        configureNotificationDot()
        
        // observe notificitaions
        observeNotifications()
        
        //user validation
        checkIfUserIsLogged()
        
        

        // Do any additional setup after loading the view.
    }
    //function to create new controllers that exist within tab bar controller
    func configureViewControllers() {
        
        // home feed controller
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // search feed controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
        
        // select image controller
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        // notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC())
        
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //view controller to be added to tab controller
        viewControllers = [feedVC, searchVC, selectImageVC,notificationVC,userProfileVC]
        
        //tab bar tint color
        tabBar.tintColor = .black
        
    }
    //construct navigation controller
       
       func constructNavController(unselectedImage: UIImage,selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
           
           //constract nav controller
           
           let navController = UINavigationController(rootViewController: rootViewController)
           navController.tabBarItem.image = unselectedImage
           navController.tabBarItem.image = selectedImage
           navController.navigationBar.tintColor = .black
           return navController
       }
    
    func configureNotificationDot() {
        //for phone size issues n changes.
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height == 1920 {
                // configure dot for iphone x
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            self.view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    // MARK: - UITabBarController
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            
            return false
        } else if index == 3 {
            dot.isHidden = true
            //we only wanna set these guys to checked once we only select index 3.
            return true
        }
        return true
    }
    
   
    func checkIfUserIsLogged() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
           return
        }
    }
    
    func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let checked = snapshot.value as? Int else { return }
                    
                    if checked == 0 { //we will append our notid if not is not checked to array.
                    // if we were to just write line of code in checked  here to check them to set them to checked that's not gonna work cuz it's gonna set our notification to checked before we check them. so we want them to set checked once we view that notification view controller.

                        self.dot.isHidden = false
                    } else {
                        self.dot.isHidden = true
                    }
                })
            })
        }
    }

            
    

}

            
