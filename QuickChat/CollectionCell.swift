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
  
  
//    @IBOutlet weak var userimageView: UIImageView!
//    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
  
    var postID: String!
    var postsUserID: String!

     override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        //imageView = CGSize(width: round(UIScreen.main.bounds.width * 0.80), height: round(UIScreen.main.bounds.height * 0.45))
    }
    
    
    
    
//    
//    func getPostsUserID(){
//        
//        let ref = FIRDatabase.database().reference()
//        
//        //let key = ref.child("users").child("barcode").key
//        
//        ref.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let itemsSnap = snapshot.value as? [String : AnyObject] {
//                
//                for (_,value) in itemsSnap {
//                    
//                    if let pUserID = value["userID"] as? String, let postIDs = value["postID"] as? String{
//                        if postIDs == self.postID{
//                            userPageID = pUserID
//                            //print(userPageID)
//                        }
//                    }
//                }
//            }
//            
//        })
//        ref.removeAllObservers()
//        
//        
//        
//    }
}



