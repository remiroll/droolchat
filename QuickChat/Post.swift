//
//  Post.swift
//  InstagramLike
//
//  Created by Vasil Nunev on 13/12/2016.
//  Copyright © 2016 Vasil Nunev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Post: NSObject {

    
    var author: String!
    var catagory: String!
    var pathToImage: String!
    var linkToImage: UIImage?
    var userID: String!
    var postID: String!
    
    var peopleWhoLike: [String] = [String]()
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        author = snapshotValue["author"] as! String
        userID = snapshotValue["userID"] as! String
        pathToImage = snapshotValue["pathToImage"] as! String
        catagory = snapshotValue["Catagory"] as! String
        postID = snapshotValue["postID"] as! String
    }
    
    
}
