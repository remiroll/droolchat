//
//  SecondViewController.swift
//  drool-chat
//
//  Created by Alexander Lorimer on 19/02/2017.
//  Copyright © 2017 Alexander Lorimer. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var following = [String]()
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var loggedInUserData:NSDictionary?
    var listFollowers = [NSDictionary?]()//store all the followers
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var swipeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!

    let transition = CircularTransition()




    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customization()

 
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "feed" {
            let secondVC = segue.destination as! UINavigationController
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
        }
        if segue.identifier == "chat" {
            let secondVC = segue.destination as! MesVC
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
           
            //transition.circle = chatButton.backgroundColor
        }
        if segue.identifier == "post" {
            let secondVC = segue.destination as! UploadViewController
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
        }
        if segue.identifier == "swipe" {
            let secondVC = segue.destination as! ViewController
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
        }
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
    

    



    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBOutlet weak var numberFollowing: UIButton!
    @IBOutlet weak var numberFollowers: UIButton!
    

    

    

}
