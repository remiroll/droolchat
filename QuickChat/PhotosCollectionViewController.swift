//
//  PhotosCollectionViewController.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 19/02/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//


import UIKit
import Firebase

class PhotosCollectionViewController: UICollectionViewController, UIViewControllerTransitioningDelegate
{
    


    
    var photoCategories = PhotoCategory.fetchPhotos()
    var posts = [Post]()
    var following = [String]()
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    
    var foodPosts = [Post]()
    var recipePosts = [Post]()
    var videoPosts = [Post]()
    var favouritePosts = [Post]()
    
    
    struct Storyboard {
        static let photoCell = "PhotoCell"
        static let headerView = "HeaderView"
        static let showDetailSegue = "ShowDetail"
        
        static let leftAndRightPaddings: CGFloat = 2.0
        static let numberOfItemsPerRow: CGFloat = 3.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewWidth = collectionView?.frame.width
        let itemWidth = (collectionViewWidth! - Storyboard.leftAndRightPaddings) / Storyboard.numberOfItemsPerRow
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
  
        
        
        
        fetchPosts()
            }
    
    @IBAction func dismissSecondVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.showProfile))
        return button
    }()
    var items = [Conversation]()
    var selectedUser: User?
    

    
    
    //Shows Chat viewcontroller with given user
    func pushToUserMesssages(notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? User {
            self.selectedUser = user
            self.performSegue(withIdentifier: "segue", sender: self)
        }
    }
    
    func fetchPosts(){
        PhotosLibrary.fetchPosts { (sortedPhotos) in
            self.photoCategories = sortedPhotos
            
            self.collectionView?.reloadData()
        }
    }
    
    func sortPosts() {
        
        for post in posts {
            
            if post.catagory == "Food" {
                foodPosts.append(post)
                
            }
            
            if post.catagory == "Recipes" {
                recipePosts.append(post)
            }
            
            if post.catagory == "Videos" {
                videoPosts.append(post)
            }
            
            if post.catagory == "Favourites" {
                favouritePosts.append(post)
            }
            
            
        }
        
       // self.collectionView.reloadData()
    }

    
    

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoCategories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoCategories[section].imageNames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.photoCell, for: indexPath) as! PhotoCell
        let photoCategory = photoCategories[indexPath.section]
        let imageNames = photoCategory.imageNames
        let imageName = imageNames[indexPath.item]
        
        cell.imageName = imageName
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Storyboard.headerView, for: indexPath) as! HeaderView
        let category = photoCategories[indexPath.section]
        
        headerView.category = category
        
        return headerView
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {

        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        self.performSegue(withIdentifier: Storyboard.showDetailSegue, sender: cell.photoImageView.image)
    }
    
 
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Storyboard.showDetailSegue {
            let detailVC = segue.destination as! DetailViewController
            detailVC.image = sender as! UIImage
        }
     
//        if segue.identifier == "menu" {
//            let secondVC = segue.destination as! SecondViewController
//            secondVC.transitioningDelegate = self
//            secondVC.modalPresentationStyle = .custom
//        }
        
    }
    
}

extension UIImageView {
    public func image(fromUrl urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let theTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let response = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: response)
                }
            }
        }
        theTask.resume()
    }
}



















