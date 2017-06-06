//
//  HeaderView.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 19/02/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var category: PhotoCategory! {
        didSet {
            categoryLabel.text = category.title
            //categoryImageView.image = UIImage(named: category.categoryImageName)
        }
    }
    
}















