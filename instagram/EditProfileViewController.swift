//
//  EditProfileViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/29/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePicture(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func choosePicture(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let editedImage = info[UIImagePickerControllerEditedImage] as?UIImage
        if editedImage != nil {
            profilePicView.image = editedImage
        } else {
            profilePicView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let user = PFUser.current()!
        if profilePicView.image != nil {
            user["picture"] = Post.getPFFileFromImage(image: profilePicView.image)
            user.saveInBackground()
        }
        
        dismiss(animated: true)
    }
}
