//
//  FeedViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/27/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var feedPosts: [PFObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        refresh()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        //lTimer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
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
        cell.captionLabel.text = currPost["caption"] as? String
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
                //detailVC.photoView = post[""]
                detailVC.post = post
            }
        }
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        
        // Configure session so that completion handler is executed on main UI thread
//        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
//        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
//            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            refresh()
            tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        //}
        //task.resume()
    }
}
