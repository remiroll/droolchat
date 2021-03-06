//
//  PostPageViewController.swift
//
//  PostCell.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 25/04/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//

//

import UIKit
import Firebase

var selectedPostID : String!

class PostPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var photoSub: UIView!
    
    
    
    var barBtn: UIBarButtonItem!
    
    var items = [Conversation]()
    var selectedUser: User?
    
    var postID : String!
    let ref = FIRDatabase.database().reference()
    var posts = [Post]()
    var user = [User]()
    
    var liked: Bool!
    
    let uid = FIRAuth.auth()!.currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.tableFooterView = UIView()
        
        //barBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserPageViewController.buttonMethod))
        fetchSinglePost(postID: selectedPostID)
//      retrieveUser()
        
        postImageView.layer.shadowColor = UIColor.lightGray.cgColor
        postImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        postImageView.layer.shadowRadius = 2.0
        postImageView.layer.shadowOpacity = 1.0
        postImageView.layer.masksToBounds = false
        postImageView.layer.shadowPath = UIBezierPath(roundedRect: postImageView.bounds, cornerRadius: postImageView.layer.cornerRadius).cgPath
        postImageView.layer.cornerRadius = 5
        
                let transparentPixel = UIImage(named: "TransparentPixel")
                UINavigationBar.appearance().setBackgroundImage(transparentPixel, for: UIBarMetrics.default)
                UINavigationBar.appearance().shadowImage = transparentPixel
                UINavigationBar.appearance().backgroundColor = UIColor.clear
                UINavigationBar.appearance().isTranslucent = true
        
        //postImageView.layer.cornerRadius).cgPath
        //photoSub.layer.cornerRadius = 5

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
 
    func buttonMethod() {
        
        let alertController = UIAlertController(title: nil, message: "To edit or delete your post select on of the below...", preferredStyle: .actionSheet)
        //CANCEL BTN
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        //EDIT TITLE BTN
        let editTitleAction = UIAlertAction(title: "Edit Title", style: .default) { action in
            
            let alert = UIAlertController(title: "Edit Title",
                                          message: "Enter your new title...",
                                          preferredStyle: .alert)
            // Submit button
            let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                // Get 1st TextField's text
                let newTitleTextField = alert.textFields![0]
                
                self.titleLbl.text = newTitleTextField.text!
                
                self.updatePost(newDescription: self.descriptionLbl.text!, newTitle: newTitleTextField.text!)
               
            })
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            
            // Add 1 textField and customize it
            alert.addTextField { (textField: UITextField) in
                textField.keyboardAppearance = .dark
                textField.keyboardType = .default
                textField.autocorrectionType = .default
                textField.placeholder = "Type something here"
                textField.clearButtonMode = .whileEditing
            }
            
            // Add action buttons and present the Alert
            alert.addAction(submitAction)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)


        }
        alertController.addAction(editTitleAction)
        
        //EDIT DESCRIPTION BTN
        let editDescriptionAction = UIAlertAction(title: "Edit Description", style: .default) { action in
            
            let alert = UIAlertController(title: "Edit Description",
                                          message: "Enter your new description...",
                                          preferredStyle: .alert)
            // Submit button
            let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                // Get 1st TextField's text
                let newDescTextField = alert.textFields![0]
                
                self.descriptionLbl.text = newDescTextField.text!
                
                self.updatePost(newDescription: newDescTextField.text!, newTitle: self.titleLbl.text!)
            })
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            
            // Add 1 textField and customize it
            alert.addTextField { (textField: UITextField) in
                textField.keyboardAppearance = .dark
                textField.keyboardType = .default
                textField.autocorrectionType = .default
                textField.placeholder = "Type something here"
                textField.clearButtonMode = .whileEditing
            }
            
            // Add action buttons and present the Alert
            alert.addAction(submitAction)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        alertController.addAction(editDescriptionAction)
        
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive) { action in
            let DeleteAlertController = UIAlertController(title: "Are You Sure?", message: "Press delete if you still want to delete this post.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            DeleteAlertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.ref.child("posts").child(self.posts[0].postID).removeValue()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedVC")
                self.present(vc, animated: true, completion: nil)
                
            }
            DeleteAlertController.addAction(OKAction)
            
            self.present(DeleteAlertController, animated: true) {
                // ...
            }
        }
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    
    
    
    func updatePost(newDescription: String, newTitle: String){
        let feed = ["userID" : uid,
                    "pathToImage" : posts[0].pathToImage,
                    "likes" : posts[0].peopleWhoLike.count,
                    "title" : newTitle,
                    "description" : newDescription,
                    "date" : posts[0].timestamp,
                    "postID" : posts[0].postID] as [String : Any]
        
        
        
        ref.child("posts").child(posts[0].postID).updateChildValues(feed)
        
        

        
        
        
        
        
    }
    
    func fetchSinglePost(postID: String) {
        ref.child("posts/\(postID)").observeSingleEvent(of: .value, with: { (snap) in
            let post = Post(snapshot: snap)
            
            self.postImageView.image(fromUrl: post.pathToImage)
            self.titleLbl.text = post.title
            self.descriptionLbl.text = post.desc
           
            
        
            self.ref.child("users/\(post.userID!)").observeSingleEvent(of: .value, with: { (userSnapshot) in
        
                let snapshotValue = userSnapshot.value as! [String: AnyObject]
                let credentials = snapshotValue["credentials"] as! [String:AnyObject]
                let name = credentials["name"] as! String
                self.userLbl.text = name
                
                
                //self.profileImageView.downloadImage(from: self.user[0].imgPath!)
                
                
            })
        })
    }
    
    
    
    func setData(){
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        titleLbl.text = posts[0].title
        navigationItem.title = posts[0].title
        userLbl.text = user[0].name
        
        //Displays post's date
        let timeStampDate = NSDate(timeIntervalSince1970: self.posts[0].timestamp.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateLbl.text = dateFormatter.string(from: timeStampDate as Date)
        
        //descriptionLbl.text = posts[0].desc
        postImageView.downloadImage(from: self.posts[0].pathToImage!)
        likeLbl.text = "\(posts[0].likes!) Likes"
        
        
        if uid != posts[0].userID {
            navigationItem.rightBarButtonItems = []
        }else{
            navigationItem.rightBarButtonItems = [barBtn]
        }
        
        checkIfLiked()

    }


    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
  
       
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }// end didSelectRow function
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        
        
        if self.liked == true {
            unlike()
        }else{
            like()
        }
        
    }
    
    
    
    func like(){
        let ref = FIRDatabase.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.posts[0].postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let post = snapshot.value as? [String : AnyObject] {
                let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)" : FIRAuth.auth()!.currentUser!.uid]
                ref.child("posts").child(self.posts[0].postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    
                    if error == nil {
                        ref.child("posts").child(self.posts[0].postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let properties = snap.value as? [String : AnyObject] {
                                if let likes = properties["peopleWhoLike"] as? [String : AnyObject] {
                                    let count = likes.count
                                    self.likeLbl.text = "\(count) Likes"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.posts[0].postID).updateChildValues(update)
                                    
                                    
                                    self.likeBtn.setImage(UIImage(named: "unlike1-1"), for: .normal)
                                    self.liked = true
                                }
                            }
                        })
                    }
                })
            }
            
            
        })
        
        ref.removeAllObservers()
        
    }
    
    func unlike(){
        let ref = FIRDatabase.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.posts[0].postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let properties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                    for (id,person) in peopleWhoLike {
                        if person as? String == FIRAuth.auth()!.currentUser!.uid {
                            ref.child("posts").child(self.posts[0].postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.posts[0].postID).observeSingleEvent(of: .value, with: { (snap) in
                                        if let prop = snap.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.likeLbl.text = "\(count) Likes"
                                                ref.child("posts").child(self.posts[0].postID).updateChildValues(["likes" : count])
                                            }else {
                                                self.likeLbl.text = "0 Likes"
                                                ref.child("posts").child(self.posts[0].postID).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })
                            
                            
                            self.likeBtn.setImage(UIImage(named: "like1"), for: .normal)
                            self.liked = false
                            
                            
                        }
                    }
                }
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    func checkIfLiked(){
        ref.child("posts").child(self.posts[0].postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let properties = snapshot.value as? [String : AnyObject]
            if let peopleWhoLike = properties?["peopleWhoLike"] as? [String : AnyObject] {
                
                for (_,person) in peopleWhoLike {
                    if person as? String == FIRAuth.auth()!.currentUser!.uid {
                        self.likeBtn.setImage(UIImage(named: "unlike1-1"), for: .normal)
                        self.liked = true
                        
                    }else{
                        self.likeBtn.setImage(UIImage(named: "like1"), for: .normal)
                        self.liked = false
                        
                    }
                    
                }
                
            }else{
                self.likeBtn.setImage(UIImage(named: "like1"), for: .normal)
                self.liked = false
            }
            
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let vc = segue.destination as! ChatVC
            vc.currentUser = self.selectedUser
        }
    }
    
    @IBAction func messageUser(_ sender: Any) {
        
    }





}

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        guard imgURL != nil else { return }
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}
