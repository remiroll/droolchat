//
//  ViewController.swift
//  GlidingCollectionDemo
//
//  Created by Abdurahim Jauzee on 04/03/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import GlidingCollection
import Firebase


var userPageID: String!

class GlidingViewController: UIViewController, UIViewControllerTransitioningDelegate  {
  
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var menuButton: UIButton!
    let transition = CircularTransition()
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameText: UILabel!
    @IBOutlet weak var FeedCollectionView: UICollectionView!

   
    var collectionView: UICollectionView!
    var cats = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    var posts = [Post]()
    var breakPosts = [Post]()
    var lunchPosts = [Post]()
    var dinnerPosts = [Post]()
    var snackPosts = [Post]()
    var following = [String]()
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    
    var usersPost: [[Post]] = []
    var postAuthor = [String]()
    
    
    
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    fetchPosts()
    menuButton.layer.cornerRadius = menuButton.frame.size.width / 2
    
   

    
    if let userID = FIRAuth.auth()?.currentUser?.uid{
        
        //User name etc
        databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
        
            let dictionary = snapshot.value as? NSDictionary
            
            let display = dictionary?["full name"] as? String ?? "Display Name"
            if let profileImageURL = dictionary?["urlToImage"] as? String{
                
                let url = URL(string: profileImageURL)
                
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data!)
                    }
                }).resume()
            }
            
            self.displayNameText.text = display
        }) { (error) in
            print(error.localizedDescription)
            return
        }
        
       
        
        
        }
    
    
  }
    
    
    
    
    
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
//        let secondVC = segue.destination as! SecondViewController
//        secondVC.transitioningDelegate = self
//        secondVC.modalPresentationStyle = .custom
   }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = menuButton.center
        transition.circleColor = menuButton.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = menuButton.center
        transition.circleColor = menuButton.backgroundColor!
        
        return transition
    }
    
    
    

    
    
    func fetchPosts(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
            
            for snapshot in snap.children {
                guard let snapshot = snapshot as? FIRDataSnapshot else { continue }
                let post = Post(snapshot: snapshot)
                
                if uid == post.userID {
                    self.posts.append(post)
                }
                
               self.sortPosts()
               
               self.glidingView.reloadData()
               self.collectionView.reloadData()
               
               self.posts.removeAll()
            }
        })
    }
    
    
    
    
    
    func sortPosts() {
        
        var count: Int = -1
        
        for post in posts {
            
            count = count+1
            
            usersPost.append([Post]())
            
            for postt in posts {
                
                if post.userID == postt.userID {
                    
                    usersPost[count].append(postt)
                    
                    postAuthor.append(post.author)
                    
                    
                    
                }
                
            }
            
        }
        self.collectionView.reloadData()
        self.glidingView.reloadData()
        self.posts.removeAll()
    }
    
}






// MARK: - Setup
extension GlidingViewController {
  
  func setup() {
    setupGlidingCollectionView()

  }
  
   func setupGlidingCollectionView() {
    glidingView.dataSource = self
    
    let nib = UINib(nibName: "CollectionCell", bundle: nil)
    collectionView = glidingView.collectionView
    collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = glidingView.backgroundColor
  }
  
}

// MARK: - CollectionView 🎛
extension GlidingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let section = glidingView.expandedItemIndex
    
   return usersPost.count
  }
    
    
    //post sections
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    let section = glidingView.expandedItemIndex
    var post: String!
    
    

     post =  usersPost[section][indexPath.row].pathToImage
    

    

       cell.imageView.downloadImage(from: post)
    cell.contentView.clipsToBounds = true
    
    let layer = cell.layer
    let config = GlidingConfig.shared
    layer.shadowOffset = config.cardShadowOffset
    layer.shadowColor = config.cardShadowColor.cgColor
    layer.shadowOpacity = config.cardShadowOpacity
    layer.shadowRadius = config.cardShadowRadius
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    return cell
  }
    
    
  //when image is clicked
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let section = glidingView.expandedItemIndex
    

    
    //selectedPostID = self.posts[indexPath.row].postID
    
    performSegue(withIdentifier: "postPage", sender: nil)

    
    
    
    
    //let item = posts[indexPath.item]
    //let data = posts[indexPath.row]
    //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
    //cell.imageView.downloadImage(from: self.posts[indexPath.row].pathToImage)
    //infoImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
    
    
    
    
    
    //print("Selected item #\(item) in section #\(section)")
    
  
    
  }
  

    
}




// MARK: - Gliding Collection 🎢
extension GlidingViewController: GlidingCollectionDatasource {
  
  func numberOfItems(in collection: GlidingCollection) -> Int {
    return posts.count
  }
  
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return postAuthor[index]
  }
  
}
