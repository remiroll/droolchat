//
//  FeedViewController.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 06/05/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//

import UIKit
import Firebase


class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var FeedCollectionView: UICollectionView!

    var posts = [Post]()
    var user = [User]()
    var following = [String]()
    
    var ref: FIRDatabaseReference?
    var databaseHandle: FIRDatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up the database reference
        ref = FIRDatabase.database().reference()
        
        
        observePosts()
        self.customization()
        
        
    }
    
    
    @IBAction func dismissSecondVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    var items = [Conversation]()
    var selectedUser: User?
    
    //MARK: Methods
    func customization()  {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //NavigationBar customization
        let navigationTitleFont = UIFont(name: "Amatic-Bold", size: 24)!
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont, NSForegroundColorAttributeName: UIColor.white]
        

    }
    

    
    

    

    func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        FIRDatabase.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                let name = data["name"]!
                let email = data["email"]!
               
                let link = URL.init(string: data["profilePicLink"]!)
                
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name, email: email, id: forUserID, profilePic: profilePic!)
                        completion(user)
                        
                        //let userToShow = User(name: name, id: userID, profilePic: profilePic)
                        //self.user.append()
                    }
                }).resume()
            }
        })
    }
    
    
    
     func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void) {
        
        databaseHandle = ref?.child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            if let data = snapshot.value as? [String: String] {
                let name = data["name"]!
                let email = data["email"]!
                let link = URL.init(string: data["profilePicLink"]!)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name, email: email, id: id, profilePic: profilePic!)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    
    func observePosts() {
        
        //let uid = FIRAuth.auth()!.currentUser!.uid
        //observeUsers()
        observePostsChildRemoved()
        
        databaseHandle = ref?.child("posts").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let post = Post(snapshot: snapshot)
                
               
                // post.timestamp = dictionary["timestamp"] as! NSNumber
                post.likes = dictionary["likes"] as! Int
                post.pathToImage = dictionary["pathToImage"] as! String
                post.postID = dictionary["postID"] as! String
                post.userID = dictionary["userID"] as! String
                post.desc = dictionary["description"] as! String
                post.title = dictionary["title"] as! String
                
                
                self.posts.append(post)
                
                
                self.attemptReloadOfTable()
            }
            
            
            
        })
        
    }
    
//    func fetchPosts(){
//        
//        let uid = FIRAuth.auth()!.currentUser!.uid
//        let ref = FIRDatabase.database().reference()
//        
//        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
//            
//            for snapshot in snap.children {
//                guard let snapshot = snapshot as? FIRDataSnapshot else { continue }
//                let post = Post(snapshot: snapshot)
//                
//                if uid == post.userID {
//                    self.posts.append(post)
//                }
//                
//                self.posts.append(post)
//                
//                self.sortPosts()
//                
//                self.glidingView.reloadData()
//                self.collectionView.reloadData()
//                
//                self.posts.removeAll()
//            }
//        })
//    }
    
    func observePostsChildRemoved() {
        //
        databaseHandle = ref?.child("posts").observe(.childRemoved, with: { (snapshot) in
        
            print("\(snapshot.key) is the key")
            print("deleted")
            var postsIndex: Int!
            
            for i in 0...self.posts.count-1{
                print(self.posts[i].postID)
            
                if self.posts[i].postID == snapshot.key{
                    print(i)
                    postsIndex = i
                    
                }
            
            }
            
         self.posts.remove(at: postsIndex)
            
        self.attemptReloadOfTable()
        
        
        })
        
    }
    
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
//        self.posts.sort(by: { (post1, post2) -> Bool in
//            
//            return post1.timestamp.intValue > post2.timestamp.intValue
//        })
        
        DispatchQueue.main.async(execute: {
            self.FeedCollectionView.reloadData()
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        //Sets Authors display name to post
//        print(user.count)
//        for x in 0...user.count-1 {
//            if posts[indexPath.row].userID == user[x].id {
//                cell.authorLabel.text = self.user[x].name
//                
//            }
//        }
        
        //Displays post's image
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        
        //Displays amount of likes on post
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) "
        
        //Sets cells post id to the one in the array
        cell.postID = self.posts[indexPath.row].postID
        
        //Displays post's title
        cell.titleLabel.text = self.posts[indexPath.row].title
        
        cell.descLabel.text = self.posts[indexPath.row].desc
        

        
        //Shows either like or unlike button depending on if user has liked the post
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == FIRAuth.auth()!.currentUser!.uid {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        //Sets posts user profile image
//        for i in 0...user.count-1 {
//            
//            if posts[indexPath.row].userID == user[i].id {
//                
//                cell.imageView.downloadImage(from: user[i].imgPath)
//            }
//        }
//
        //Checks if user has liked the post
        cell.checkIfLiked()

        //cell.contentView.layer.backgroundColor = UIColor.clear.cgColor
       
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
//        cell.layer.cornerRadius = 5

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        selectedPostID = self.posts[indexPath.row].postID
        
        
        
        performSegue(withIdentifier: "postPage", sender: self)
        
    }

    
//    @IBAction func mePressed(_ sender: Any) {
//        let Puid = FIRAuth.auth()?.currentUser?.uid
//        
//        userPageID = Puid
//        performSegue(withIdentifier: "userPage", sender: self)
//    }
//    
//    @IBAction func ProfilePicPressed(_ sender: Any) {
//        performSegue(withIdentifier: "userPage", sender: self)
//    }
//    @IBAction func usernamePressed(_ sender: Any) {
//        performSegue(withIdentifier: "userPage", sender: self)
//    }
   

}
