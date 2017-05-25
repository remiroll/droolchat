//
//  DetailViewController.swift
//  Photos-DucTran
//
//  Created by Duc Tran on 1/23/17.
//  Copyright © 2017 Developers Academy. All rights reserved.
//

import UIKit

var selectedPostID : String!

class DetailViewController: UIViewController
{
    @IBOutlet weak var categoryImageView: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryImageView.image = image
        navigationItem.title = "Photo"
    }

}
