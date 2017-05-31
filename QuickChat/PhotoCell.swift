//
//  PhotoCell.swift
//  Photos-DucTran
//
//  Created by Duc Tran on 1/23/17.
//  Copyright © 2017 Developers Academy. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell
{
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
//        photoImageView.layer.cornerRadius = 5
//        photoImageView.clipsToBounds = true
        photoImageView.layer.borderWidth = 6.0
        photoImageView.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.1).cgColor


    }

    
    var imageName: String! {
        didSet {
            photoImageView.image(fromUrl: imageName)
        }
    }
}
