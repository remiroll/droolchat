//
//  Post.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 13/04/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Post: NSObject {

    var title: String!
    var desc: String!
    var author: String!
    var catagory: String!
    var timestamp: NSNumber!
    var likes: Int!
    var pathToImage: String!
    var linkToImage: UIImage?
    var userID: String!
    var postID: String!
    
    var peopleWhoLike: [String] = [String]()
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        author = snapshotValue["author"] as! String
        userID = snapshotValue["userID"] as! String
        likes = snapshotValue["likes"] as? Int
        pathToImage = snapshotValue["pathToImage"] as! String
        catagory = snapshotValue["Catagory"] as! String
        postID = snapshotValue["postID"] as! String
        desc = snapshotValue["description"] as! String
        title = snapshotValue["title"] as! String
    }
    
    
}
