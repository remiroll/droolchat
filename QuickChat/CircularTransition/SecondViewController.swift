//
//  SecondViewController.swift
//  CircularTransition
//
//  Created by Training on 26/08/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController {
    
    var following = [String]()
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    var listFollowers = [NSDictionary?]()//store all the followers


    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       dismissButton.layer.cornerRadius = dismissButton.frame.size.width / 2
        
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        self.databaseRef.child("users").child(self.loggedInUser!.uid).observe(.value, with: { (snapshot) in
            
            let snapshot = snapshot.value as! [String: AnyObject]
          
            
            if(snapshot["followersCount"] !== nil)
            {
                self.numberFollowers.setTitle("\(snapshot["followersCount"]!)", for: .normal)
            }
            
            if(snapshot["followingCount"] !== nil)
            {
                self.numberFollowing.setTitle("\(snapshot["followingCount"]!)", for: .normal)
            }
            
            
            
            
           
        })
        
        
        
        
        
        
        
    }

    @IBAction func dismissSecondVC(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var numberFollowing: UIButton!
    @IBOutlet weak var numberFollowers: UIButton!
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        
        if(segue.identifier == "showFollowingTableViewController")
        {
            let showFollowingTableViewController = segue.destination as! ShowFollowingTableViewController
            showFollowingTableViewController.users = self.loggedInUser as? FIRUser
            
        }
        else if(segue.identifier == "showFollowersTableViewController")
        {
            let showFollowersTableViewController = segue.destination as! ShowFollowersTableViewController
            showFollowersTableViewController.users = self.loggedInUser as? FIRUser
            
        }
    }
    

}
