//
//  ProfileViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/28/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    var userPosts: [PFObject] = []
    @IBOutlet weak var profilePicView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        loadUserPosts()
        usernameLabel.text = PFUser.current()?.username
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(userPosts.count)
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let currPost = userPosts[indexPath.row]
        
        //getting and converting image from PFFile to UIimage
        if let image = currPost["media"] as? PFFile {
            image.getDataInBackground { (imageData: Data!, error: Error?) in
                if (imageData) != nil {
                    cell.imageView.image = UIImage(data: imageData)
                } else {
                    print("image loading error here:")
                    print(error?.localizedDescription as Any)
                }
            }
        }
        return cell
    }

    
    func loadUserPosts() {
        let user = PFUser.current()
        if let image = user?["picture"] as? PFFile {
            image.getDataInBackground { (imageData: Data!, error: Error?) in
                if (imageData) != nil {
                    self.profilePicView.image = UIImage(data: imageData)
                } else {
                    print("image loading error here:")
                    print(error?.localizedDescription as Any)
                }
            }
        }

        let query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: user!)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.userPosts = posts
                self.collectionView.reloadData()
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        // Reload the tableView now that there is new data
        loadUserPosts()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell {
            if let indexPath = collectionView.indexPath(for: cell) {
                let post = userPosts[indexPath.row]
                let detailVC = segue.destination as! DetailViewController
                detailVC.post = post
            }
        }
        
    }
}
