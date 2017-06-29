//
//  FeedViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/27/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var feedPosts: [PFObject] = []
    var isMoreDataLoading = false
    var currLimit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refresh()
        
        //creating refreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name("logoutNotfication"), object: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let currPost = feedPosts[indexPath.row]
        
        //setting the image
        if let image = currPost["media"] as? PFFile {
            image.getDataInBackground { (imageData: Data!, error: Error?) in
                if (imageData) != nil {
                    cell.photoView.image = UIImage(data: imageData)
                } else {
                    print("image loading error here:")
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
        //setting the caption
        cell.captionLabel.text = currPost["caption"] as? String
        
        //setting the user
        let user = currPost["author"] as? PFUser
        cell.usernameLabel.text = user?.username
        cell.usernameLabel2.text = user?.username
        
        //setting the date
        if let date = currPost.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: date)
            cell.dateLabel.text = dateString
        }
        return cell
    }

    func refresh() {
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                self.feedPosts = posts
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                let post = feedPosts[indexPath.row]
                let detailVC = segue.destination as! DetailViewController
                detailVC.post = post
            }
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        // Reload the tableView now that there is new data
        refresh()
        tableView.reloadData()
            
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let query = PFQuery(className: "Post")
                query.includeKey("author")
                query.addDescendingOrder("createdAt")
                
                //increasing query limit
                currLimit += 20
                query.limit = currLimit
                
                //making new query
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let posts = posts {
                        self.feedPosts = posts
                        self.tableView.reloadData()
                        self.isMoreDataLoading = false
                    } else {
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
}
