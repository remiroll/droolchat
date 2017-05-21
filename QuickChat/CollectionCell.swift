//
//  CollectionCell.swift
//  GlidingCollection
//
//  Created by Abdurahim Jauzee on 07/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import Firebase


class CollectionCell: UICollectionViewCell {
  
  @IBOutlet var imageView: UIImageView!
  
    var postID: String!
    var postsUserID: String!

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
}



