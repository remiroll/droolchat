//
//  SecondViewController.swift
//  CircularTransition
//
//  Created by Training on 26/08/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var following = [String]()
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    var listFollowers = [NSDictionary?]()//store all the followers
    




    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        
//        
//        let secondVC = segue.destination as! NavVC
//        secondVC.transitioningDelegate = self
//        secondVC.modalPresentationStyle = .custom
//        
//
//    }
//    
//
//    
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .present
//        transition.startingPoint = feedButton.center
//        transition.circleColor = feedButton.backgroundColor!
//        
//
//        
//        return transition
//    }
//    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .dismiss
//        transition.startingPoint = feedButton.center
//        transition.circleColor = feedButton.backgroundColor!
//        
//
//        
//        return transition
//    }


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var numberFollowing: UIButton!
    @IBOutlet weak var numberFollowers: UIButton!
    

    

    

}
