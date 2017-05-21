//
//  ShowFollowingTableViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 10/10/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import Firebase
class ShowFollowingTableViewController: UITableViewController {

    var users:FIRUser?
    var databaseRef = FIRDatabase.database().reference()
    var listFollowing = [NSDictionary?]()
    
    
    @IBOutlet var followingTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get all the users the signed in user is following
        databaseRef.child("users").child(self.users!.uid).child("following").observe(.childAdded, with: { (snapshot) in
            
        //databaseRef.child("following").child(self.users!.uid).queryOrdered(byChild: "full name").observe(.childAdded, with: { (snapshot) in
        
            
            
        let snapshot = snapshot.value as? NSDictionary
        
        //add the users to the array
        self.listFollowing.append(snapshot)
    
        self.followingTableView.insertRows(at: [IndexPath(row:self.listFollowing.count-1,section:0)], with: UITableViewRowAnimation.automatic)

        }) { (error) in
            print(error.localizedDescription)
        }
     
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let users = listFollowing[indexPath.row]
                let controller = segue.destination as? UserProfileViewController
                controller?.otherUser = users
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.listFollowing.count
    }

    //dismiss the modal and move back to the meViewController
    @IBAction func didTapDismiss(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
   
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followingUserCell", for: indexPath)

        print(self.listFollowing[indexPath.row]!)
        
        cell.textLabel?.text = self.listFollowing[indexPath.row]?["usersID"] as? String
        //cell.detailTextLabel?.text = "@"+(self.listFollowing[indexPath.row]?["handle"] as? String)!
        
        return cell
    }

    
}
