//
//  PostCell.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 24/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import Firebase
import IBAnimatable

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postID: String!
    var postsUserID: String!
    
    
    @IBAction func likePressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        let ref = FIRDatabase.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let post = snapshot.value as? [String : AnyObject] {
                let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)" : FIRAuth.auth()!.currentUser!.uid]
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    
                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let properties = snap.value as? [String : AnyObject] {
                                if let likes = properties["peopleWhoLike"] as? [String : AnyObject] {
                                    let count = likes.count
                                    self.likeLabel.text = "\(count)"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                    
                                    self.likeBtn.isHidden = true
                                    self.unlikeBtn.isHidden = false
                                    self.likeBtn.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
            
            
        })
        
        ref.removeAllObservers()
    }
    
    
    @IBAction func unlikePressed(_ sender: Any) {
        self.unlikeBtn.isEnabled = false
        let ref = FIRDatabase.database().reference()
        
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let properties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                    for (id,person) in peopleWhoLike {
                        if person as? String == FIRAuth.auth()!.currentUser!.uid {
                            ref.child("posts").child(self.postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                        if let prop = snap.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.likeLabel.text = "\(count)"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                            }else {
                                                self.likeLabel.text = "0"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })
                            
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            break
                            
                        }
                    }
                }
            }
            
        })
        ref.removeAllObservers()
    }
    
    func checkIfLiked(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let properties = snapshot.value as? [String : AnyObject]
            if let peopleWhoLike = properties?["peopleWhoLike"] as? [String : AnyObject] {
                
                for (_,person) in peopleWhoLike {
                    if person as? String == FIRAuth.auth()!.currentUser!.uid {
                        self.likeBtn.isHidden = true
                        self.unlikeBtn.isHidden = false
                        self.likeBtn.isEnabled = true
                        
                    }else{
                        self.likeBtn.isHidden = false
                        self.unlikeBtn.isHidden = true
                        self.unlikeBtn.isEnabled = true
                        
                    }
                    
                }
                
            }else{
                self.likeBtn.isHidden = false
                self.unlikeBtn.isHidden = true
                self.unlikeBtn.isEnabled = true

            }
            
            
        })
    }
    
    func getPostsUserID(){
        
        let ref = FIRDatabase.database().reference()
        
            //let key = ref.child("users").child("barcode").key
            
            ref.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let itemsSnap = snapshot.value as? [String : AnyObject] {
                    
                    for (_,value) in itemsSnap {
                        
                        if let pUserID = value["userID"] as? String, let postIDs = value["postID"] as? String{
                            if postIDs == self.postID{
                                userPageID = pUserID
                                //print(userPageID)
                            }
                        }
                    }
                }
                
            })
            ref.removeAllObservers()
        
        
        
    }
    
  
    @IBAction func profilePicPressed(_ sender: Any) {
        print("done")
        getPostsUserID()
        
        
        
    }
    
    @IBAction func usernamePressed(_ sender: Any) {
        print("done")
        getPostsUserID()
        
    }
}

