//
//  DetailViewController.swift
//  Photos-DucTran
//
//  Created by Duc Tran on 1/23/17.
//  Copyright © 2017 Developers Academy. All rights reserved.
//

import UIKit
import Firebase



class DetailViewController: UIViewController

{
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameText: UILabel!
    
    
    let loggedInUser = FIRAuth.auth()?.currentUser//store the auth details of the logged in user
    var loggedInUserData:NSDictionary? //the users data from the database will be stored in this variable
    var user = [User]()
    var databaseRef:FIRDatabaseReference!
    var image: UIImage!
    var otherUser:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
     
        
        
        

        
        //applying overall shadow to image
//        categoryImageView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.8).cgColor
//        categoryImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        categoryImageView.layer.shadowOpacity = 1.0
//        categoryImageView.layer.shadowRadius = 8.0
//        profileImageView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.8).cgColor
//        profileImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
//        profileImageView.layer.shadowOpacity = 1.0
//        profileImageView.layer.shadowRadius = 10
//        profileImageView.layer.shadowPath = UIBezierPath(rect: profileImageView.bounds).cgPath
        
        
        
        categoryImageView.image = image
        navigationItem.title = "Photo"
        
        self.fetchUsers()
        self.fetchUserInfo()
        
        
    }
    
    func fetchUsers()  {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            User.downloadAllUsers(exceptID: id, completion: {(user) in
                DispatchQueue.main.async {
//                    self.items.append(user)
//                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    //Downloads current user credentials
    func fetchUserInfo() {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            User.downloadAllUsers(exceptID: id, completion: {[weak weakSelf = self] (user) in
                DispatchQueue.main.async {
                    weakSelf?.displayNameText.text = user.name
                    //weakSelf?.emailLabel.text = user.email
                    weakSelf?.profileImageView.image = user.profilePic
                    weakSelf = nil
                }
            })
        }
    }
    

}

