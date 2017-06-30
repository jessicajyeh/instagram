//
//  PhotoTakerViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/27/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import MBProgressHUD

class PhotoTakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    let alertController = UIAlertController(title: "Error: Cannot share post", message: "Please choose an image", preferredStyle: .alert)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        // vc.sourceType = UIImagePickerControllerSourceType.camera
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
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let editedImage = info[UIImagePickerControllerEditedImage] as?UIImage
        if editedImage != nil {
            photoView.image = editedImage
        } else {
            photoView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func onPost(_ sender: Any) {
        if photoView.image == nil {
            present(alertController, animated: true)
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let sizeImage = resizeImage(image: photoView.image!, newWidth: 800)
            photoView.image = sizeImage
            Post.postUserImage(image: photoView.image, withCaption: captionField.text) { (success: Bool, error: Error?) in
                if error == nil {
                    print("posting image")
                    self.dismiss(animated: true, completion: nil)
                    MBProgressHUD.hide(for: self.view, animated: true)
                } else {
                    print(error?.localizedDescription as Any)
                    print("erroring")
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeToScreenSize(image: UIImage)->UIImage{
        let screenSize = self.view.bounds.size
        return resizeImage(image: image, newWidth: screenSize.width)
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }

}
