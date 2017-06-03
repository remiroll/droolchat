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




class ViewController: UIViewController, UIViewControllerTransitioningDelegate  {
  
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var menuButton: UIButton!
    let transition = CircularTransition()



   
    var collectionView: UICollectionView!
    var cats = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    var posts = [Post]()
    var following = [String]()
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    
    var usersPost: [[Post]] = []
    var postAuthor = [String]()
    
    
    
    
    
  override func viewDidLoad(){
    super.viewDidLoad()
    setup()
    fetchPosts()
    
    self.customization()
    menuButton.layer.cornerRadius = menuButton.frame.size.width / 2
    

    
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
                let secondVC = segue.destination as! SecondViewController
                secondVC.transitioningDelegate = self
                secondVC.modalPresentationStyle = .custom
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
    
    
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.showProfile))
        return button
    }()
    var items = [Conversation]()
    var selectedUser: User?
    
    //MARK: Methods
    func customization()  {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //NavigationBar customization
        let navigationTitleFont = UIFont(name: "ArialRoundedMTBold", size: 17)!
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont, NSForegroundColorAttributeName: UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)]
        
        // notification setup
//        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToUserMesssages(notification:)), name: NSNotification.Name(rawValue: "showUserMessages"), object: nil)
        
        //        //right bar button
        //let icon = UIImage.init(named: "")?.withRenderingMode(.alwaysOriginal)
        //let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ViewController.viewDidLoad))
        
        //self.navigationItem.rightBarButtonItem = rightButton
        //left bar button image fetching
        self.navigationItem.leftBarButtonItem = self.leftButton
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            User.info(forUserID: id, completion: { [weak weakSelf = self] (user) in
                let image = user.profilePic
                let contentSize = CGSize.init(width: 35, height: 35)
                UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                let _  = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14).addClip()
                image.draw(in: CGRect(origin: CGPoint.zero, size: contentSize))
                let path = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14)
                path.lineWidth = 2
                UIColor.white.setStroke()
                path.stroke()
                let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
                UIGraphicsEndImageContext()
                DispatchQueue.main.async {
                    weakSelf?.leftButton.image = finalImage
                    weakSelf = nil
                }
            })
        }
    }
    
    
    //Shows profile extra view
    func showProfile() {
        let info = ["viewType" : ShowExtraView.profile]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
        self.inputView?.isHidden = true
    }
    
    //Shows contacts extra view
    func showContacts() {
        let info = ["viewType" : ShowExtraView.contacts]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
    }
    
    
    
//    //Shows Chat viewcontroller with given user
//    func pushToUserMesssages(notification: NSNotification) {
//        if let user = notification.userInfo?["user"] as? User {
//            self.selectedUser = user
//            self.performSegue(withIdentifier: "segue", sender: self)
//        }
//    }

    
    
    
    func fetchPosts(){
        
        //let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
            
            for snapshot in snap.children {
                guard let snapshot = snapshot as? FIRDataSnapshot else { continue }
                let post = Post(snapshot: snapshot)
                
//                if uid == post.userID {
//                    self.posts.append(post)
//                }
                
                self.posts.append(post)
                
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
extension ViewController {
  
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
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    _ = glidingView.expandedItemIndex
    
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
   // let section = glidingView.expandedItemIndex
    

    
    //selectedPostID = self.posts[indexPath.row].postID
    
    //performSegue(withIdentifier: "postPage", sender: nil)

    
    

    
  }
  

    
}




// MARK: - Gliding Collection 🎢
extension ViewController: GlidingCollectionDatasource {
  
  func numberOfItems(in collection: GlidingCollection) -> Int {
    return posts.count
  }
  
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return postAuthor[index]
  }
  
}
