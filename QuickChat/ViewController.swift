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
import AudioToolbox


var userPageID: String!

class ViewController: UIViewController, UIViewControllerTransitioningDelegate  {
  
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
    
    
    
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.customization()
    setup()
    fetchPosts()
    menuButton.layer.cornerRadius = menuButton.frame.size.width / 2
    
   

    
//    if let userID = FIRAuth.auth()?.currentUser?.uid{
//        
//        //User name etc
//        //databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
//            databaseRef.child("users").child(userID).child("credentials").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
//        
//            
//            let dictionary = snapshot.value as? NSDictionary
//            
//            let display = dictionary?["name"] as? String ?? "Display Name"
//            if let profileImageURL = dictionary?["profilePicLink"] as? String{
//                
//                let url = URL(string: profileImageURL)
//                
//                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//                    if error != nil{
//                        print(error!)
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        self.profileImageView.image = UIImage(data: data!)
//                    }
//                }).resume()
//            }
//            
//            self.displayNameText.text = display
//        }) { (error) in
//            print(error.localizedDescription)
//            return
//        }
//        
//       
//        
//        
//        }
    
    
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
        let navigationTitleFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont, NSForegroundColorAttributeName: UIColor.white]
        // notification setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToUserMesssages(notification:)), name: NSNotification.Name(rawValue: "showUserMessages"), object: nil)
        
        //right bar button
        let icon = UIImage.init(named: "compose")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(FollowUsersTableViewController.showContacts))
        
        self.navigationItem.rightBarButtonItem = rightButton
        //left bar button image fetching
        self.navigationItem.leftBarButtonItem = self.leftButton
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            User.info(forUserID: id, completion: { [weak weakSelf = self] (user) in
                let image = user.profilePic
                let contentSize = CGSize.init(width: 30, height: 30)
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
    
    
    
    //Shows Chat viewcontroller with given user
    func pushToUserMesssages(notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? User {
            self.selectedUser = user
            self.performSegue(withIdentifier: "segue", sender: self)
        }
    }
    
    func playSound()  {
        var soundURL: NSURL?
        var soundID:SystemSoundID = 0
        let filePath = Bundle.main.path(forResource: "newMessage", ofType: "wav")
        soundURL = NSURL(fileURLWithPath: filePath!)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "segue" {
//            let vc = segue.destination as! ChatVC
//            vc.currentUser = self.selectedUser
//        }
//    }

    
    
    
    
    
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menu" {
        let secondVC = segue.destination as! SecondViewController
        secondVC.transitioningDelegate = self
        secondVC.modalPresentationStyle = .custom
        }
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
        
        for post in posts {
            
            if post.catagory == "Breakfast" {
                breakPosts.append(post)
                
            }
            
            if post.catagory == "Lunch" {
                lunchPosts.append(post)
            }
            
            if post.catagory == "Dinner" {
                dinnerPosts.append(post)
            }
            
            if post.catagory == "Snacks" {
                snackPosts.append(post)
            }
            
        
        }
        
          self.glidingView.reloadData()
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
    let section = glidingView.expandedItemIndex
    
    if section == 0  {
        return breakPosts.count
    }

    
    if section == 1 {
        return lunchPosts.count
    }
    
    if section == 2 {
        return dinnerPosts.count
    }
   
    if section == 3 {
        return snackPosts.count
    }
    
    return 0
  }
    
    
    //post sections
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    let section = glidingView.expandedItemIndex
    var post: String!
    
    

    
    //Displays post's image
    //cell.imageView.downloadImage(from: self.posts[indexPath.row].pathToImage)
    

    
    //Sets cells post id to the one in the array
    //cell.postID = self.posts[indexPath.row].postID
    

    

    

    
    if section == 0  {
        post =  breakPosts[indexPath.row].pathToImage
    }
    
    if section == 1 {
        post =  lunchPosts[indexPath.row].pathToImage
    }
    
    if section == 2 {
        post =  dinnerPosts[indexPath.row].pathToImage
    }
    
    if section == 3 {
        post =  snackPosts[indexPath.row].pathToImage
    }
    
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
extension ViewController: GlidingCollectionDatasource {
  
  func numberOfItems(in collection: GlidingCollection) -> Int {
    return cats.count
  }
  
  func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
    return "– " + cats[index]
  }
  
}
