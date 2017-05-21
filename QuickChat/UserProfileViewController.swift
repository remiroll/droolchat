//
//  ProfilesViewController.swift
//  GlidingCollection
//
//  Created by Student on 24/04/2017.
//  Copyright © 2017 Ramotion Inc. All rights reserved.
//

import UIKit
import GlidingCollection
import Firebase


class UserProfileViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    
    
    var collectionView: UICollectionView!
    var cats = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    var posts = [Post]()
    
    var breakPosts = [Post]()
    var lunchPosts = [Post]()
    var dinnerPosts = [Post]()
    var snackPosts = [Post]()
    
    var following = [String]()

    
    
    
    //@IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameText: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var otherUser:NSDictionary?
    
    let loggedInUser = FIRAuth.auth()?.currentUser//store the auth details of the logged in user
    var loggedInUserData:NSDictionary? //the users data from the database will be stored in this variable
    var user = [User]()
    var databaseRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchPosts()

        
        
        
        
        
        
        //create a reference to the firebase database
        databaseRef = FIRDatabase.database().reference()
        
        //add an observer for the logged in user
        databaseRef.child("users").child(self.loggedInUser!.uid).observe(FIRDataEventType.value, with: { (snapshot) in
            
            print("VALUE CHANGED IN USERS")
            self.loggedInUserData = snapshot.value as? NSDictionary
            //store the key in the users data variable
            self.loggedInUserData?.setValue(self.loggedInUser!.uid, forKey: "uid")
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //add an observer for the user who's profile is being viewed
        //When the followers count is changed, it is updated here!
        //need to add the uid to the user's data
        databaseRef.child("users").child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            let uid = self.otherUser?["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            //add the uid to the profile
            self.otherUser?.setValue(uid, forKey: "uid")
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //check if the current user is being followed
        //if yes, Enable the UNfollow button
        //if no, Enable the Follow button
        
        
        databaseRef.child("users").child(self.loggedInUser!.uid).child("following").child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                self.followButton.setTitle("Unfollow", for: .normal)
                print("You are following the user")
                
            }
            else
            {
                self.followButton.setTitle("Follow", for: .normal)
                print("You are not following the user")
            }
            
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
        
        
        
        self.displayNameText.text = self.otherUser?["full name"] as? String
        // Do any additional setup after loading the view.
        
        self.profileImageView.downloadImage(from: self.otherUser?["urlToImage"] as! String) as? UIImage
        
    }
    

    
    @IBAction func didTapFollow(_ sender: AnyObject) {
        
        
        let followersRef = "users/" + (self.loggedInUserData?["uid"] as! String) + "/" + "followers/" + (self.otherUser?["uid"] as! String)
        let followingRef = "users/" + (self.loggedInUserData?["uid"] as! String) + "/" + "following/" + (self.otherUser?["uid"] as! String)
        
        
        if(self.followButton.titleLabel?.text == "Follow")
        {
            print("follow user")
            
            let followersData = ["usersID": self.otherUser?["full name"] as! String]
            
            let followingData = ["usersID": self.otherUser?["full name"] as! String]
            
            //"urlToImage":self.otherUser?["urlToImage"] != nil ? self.loggedInUserData?["urlToImage"] as! String : ""
            let childUpdates = [followersRef:followersData,
                                followingRef:followingData]
            
            
            databaseRef.updateChildValues(childUpdates)
            
            print("data updated")
            
            
            
            
            //update following count under the logged in user
            //update followers count in the user that is being followed
            let followersCount:Int?
            let followingCount:Int?
            if(self.otherUser?["followersCount"] == nil)
            {
                //set the follower count to 1
                followersCount=1
            }
            else
            {
                followersCount = self.otherUser?["followersCount"] as! Int + 1
            }
            
            //check if logged in user  is following anyone
            //if not following anyone then set the value of followingCount to 1
            if(self.loggedInUserData?["followingCount"] == nil)
            {
                followingCount = 1
            }
                //else just add one to the current following count
            else
            {
                
                followingCount = self.loggedInUserData?["followingCount"] as! Int + 1
            }
            
            databaseRef.child("users").child(self.loggedInUser!.uid).child("followingCount").setValue(followingCount!)
            databaseRef.child("users").child(self.otherUser?["uid"] as! String).child("followersCount").setValue(followersCount!)
            
            
        }
        else
        {
            databaseRef.child("users").child(self.loggedInUserData?["uid"] as! String).child("followingCount").setValue(self.loggedInUserData!["followingCount"] as! Int - 1)
            databaseRef.child("users").child(self.otherUser?["uid"] as! String).child("followersCount").setValue(self.otherUser!["followersCount"] as! Int - 1)
            
            let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.loggedInUserData?["uid"] as! String)"
            let followingRef = "following/" + (self.loggedInUserData?["uid"] as! String) + "/" + (self.otherUser?["uid"] as! String)
            
            
            let childUpdates = [followingRef:NSNull(),followersRef:NSNull()]
            databaseRef.updateChildValues(childUpdates)
            
            
        }
        
    }

    func fetchPosts(){
        
        //no uid source in firebase
       
        let uid = self.otherUser?["uid"] as! String
        //let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
            
        
        
        //databaseRef.child("users").child(self.otherUser?["uid"] as! String,
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
extension UserProfileViewController {
    
    func setup() {
        setupGlidingCollectionView()
        //loadImages()
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
    
    
    

    
//    func loadImages() {
//        for item in items {
//            let imageURLs = FileManager.default.fileUrls(for: "jpeg", fileName: item)
//            var images: [UIImage?] = []
//            for url in imageURLs {
//                guard let data = try? Data(contentsOf: url) else { continue }
//                let image = UIImage(data: data)
//                images.append(image)
//            }
//            self.images.append(images)
//        }
//    }
    
}







// MARK: - CollectionView 🎛
extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
    
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    
    let section = glidingView.expandedItemIndex
    var post: String!
    
    
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = glidingView.expandedItemIndex
        let item = indexPath.item
        print("Selected item #\(item) in section #\(section)")
    }
    
    
}





// MARK: - Gliding Collection 🎢
extension UserProfileViewController: GlidingCollectionDatasource {
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return cats.count
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "– " + cats[index]
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
