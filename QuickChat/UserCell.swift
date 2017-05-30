//
//  UserCell.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 23/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var userID: String!
    
    
    @IBAction func followBtnPressed(_ sender: Any) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.userID {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.userID).child("followers/\(ke)").removeValue()
                        
                        //self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                        
                        
                        self.followBtn.setImage(UIImage(named: "username"), for: .normal)
                    }
                }
                
            }
            
            if !isFollower {
                let following = ["following/\(key)" : self.userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.userID).updateChildValues(followers)
                
                //self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                self.followBtn.setImage(UIImage(named: "gender"), for: .normal)
                
                
            }
        })
        
        ref.removeAllObservers()
    }
    
    func checkFollowing() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.userID {
                        //self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        self.followBtn.setImage(UIImage(named: "gender"), for: .normal)
                    }
                    
                }
            }
        })
        ref.removeAllObservers()
    }

}
