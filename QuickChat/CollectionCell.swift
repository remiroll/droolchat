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

    override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
}



