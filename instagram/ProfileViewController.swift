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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        loadUserPosts()
        usernameLabel.text = PFUser.current()?.username
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
        
        //getting and converting image
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
