//
//  DetailViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/28/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var post: PFObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionLabel.text = post!["caption"] as? String
        
        if let image = post!["media"] as? PFFile {
            image.getDataInBackground { (imageData: Data!, error: Error?) in
                if (imageData) != nil {
                    self.photoView.image = UIImage(data: imageData)
                } else {
                    print("image loading error here:")
                    print(error?.localizedDescription as Any)
                }
            }
        }
        
        if let date = post?.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: date)
            timeLabel.text = dateString
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
