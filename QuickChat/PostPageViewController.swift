//
//  PostPageViewController.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello (i7240992) on 05/04/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
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
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    var barBtn: UIBarButtonItem!
    
    var postID : String!
    let ref = FIRDatabase.database().reference()
    var posts = [Post]()
    var user = [User]()
    var postRecipe = [RecipeItem]()
    var liked: Bool!
    
    let uid = FIRAuth.auth()!.currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        barBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserPageViewController.buttonMethod))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        retrieveUser()
        
        
        
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
        
        
        
        for i in 0...postRecipe.count-1{
            let key1 = ref.child("posts").childByAutoId().key
            let recipe = ["itemName" : postRecipe[i].itemName, "amount" : postRecipe[i].amount, "fraction" : postRecipe[i].fraction, "RID" : key1] as [String : Any]
            
            let recipeFeed = ["\(key1)" : recipe]
            
            ref.child("posts").child(posts[0].postID).child("recipe").setValue(recipeFeed)
        }
        
        
        
        
        
    }
    
    func fetchPost(){
        
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            
            let postsSnap = snap.value as! [String : AnyObject]
            self.posts.removeAll()
            
            for (_,post) in postsSnap {
                if let postsID = post["postID"] as? String {
                    
                  
                    if selectedPostID == postsID {
                        
                        let posst = Post()
                        if let likes = post["likes"] as? Int, let title = post["title"] as? String, let description = post["description"] as? String, let timestamp = post["timestamp"] as? NSNumber, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let userID = post["userID"] as? String {
                            
                            posst.likes = likes
                            posst.title = title
                            posst.desc = description
                            posst.timestamp = timestamp
                            posst.pathToImage = pathToImage
                            posst.postID = postID
                            posst.userID = userID
                            
                            if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                for (_,person) in people {
                                    posst.peopleWhoLike.append(person as! String)
                                }
                            }
                            print(posst)
                            self.posts.append(posst)
                        }
                        
                        self.ref.child("posts").child(postsID).child("recipe").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            let recipeSnap = snap.value as! [String : AnyObject]
                            self.postRecipe.removeAll()
                            
                             for (_,recipe1) in recipeSnap {
                                let rec = RecipeItem()
                                
                                if let itemName = recipe1["itemName"] as? String, let amount = recipe1["amount"] as? String, let fraction = recipe1["fraction"] as? String {
                                    
                                    rec.itemName = itemName
                                    rec.amount = amount
                                    rec.fraction = fraction
                                    
                                    self.postRecipe.append(rec)
                                    
                                }
                               self.tableView.reloadData()
                            }

                            
                            
                        })
                        
                    }
                    
                    
                    //self.collectionView.reloadData()
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    
    func setData(){
        profileImageView.downloadImage(from: self.user[0].imgPath!)
        titleLbl.text = posts[0].title
        navigationItem.title = posts[0].title
        userLbl.text = user[0].fullName
        
        //Displays post's date
        let timeStampDate = NSDate(timeIntervalSince1970: self.posts[0].timestamp.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateLbl.text = dateFormatter.string(from: timeStampDate as Date)
        
        descriptionLbl.text = posts[0].desc
        postImageView.downloadImage(from: self.posts[0].pathToImage!)
        likeLbl.text = "\(posts[0].likes!) Likes"
        
        
        if uid != posts[0].userID {
            navigationItem.rightBarButtonItems = []
        }else{
            navigationItem.rightBarButtonItems = [barBtn]
        }
        
        checkIfLiked()

    }

    func retrieveUser(){
       
        fetchPost()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            
            for (_, value) in users {
                
                if let uid = self.posts[0].userID {
                    
                    let userToShow = User()
                    if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let userID = value["uid"] as? String {
                        if userID == uid {
                        
                            userToShow.fullName = fullName
                            userToShow.imgPath = imagePath
                            userToShow.userID = uid
                        
                            self.user.append(userToShow)
                        }
                    }
                    
                }
                
            }
            //self.FeedCollectionView.reloadData()
            self.setData()
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(postRecipe.count)
        
        return postRecipe.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let pointSize: CGFloat = 14.0
        let string = "\(postRecipe[indexPath.row].amount!) \(postRecipe[indexPath.row].itemName!)"
        
        let attribString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize), NSForegroundColorAttributeName: UIColor.black])
        attribString.addAttributes([NSFontAttributeName: UIFont.fractionFont(ofSize: pointSize)], range: (string as NSString).range(of: postRecipe[indexPath.row].fraction!))
        cell.textLabel?.attributedText = attribString
        cell.textLabel?.sizeToFit()

        
       
        
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
    
    @IBAction func addToShoppingPressed(_ sender: Any) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        
        if (postRecipe.count != 0){
            for i in 0...postRecipe.count-1{
                let key = ref.child("users").child(uid).child("itemsList").childByAutoId().key
            
                let newItem = ManualAddedItem()
            
                let newItemName = postRecipe[i].itemName
                let completion = false
            
                newItem.itemName = newItemName
                newItem.completion = completion
                newItem.id = newItemName
            
                let item: [String : Any] = ["name" : newItemName!, "completion" : completion, "listID" : key]
                let itemsList = ["\(key)" : item]
            
                ref.child("users").child(uid).child("manuallyAddedItems").updateChildValues(itemsList)
                
                let alertController = UIAlertController(title: "Done", message: "Recipe added to your shopping list", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            
           
            
            }
        }
    }





}
