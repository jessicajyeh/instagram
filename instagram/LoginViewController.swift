//
//  LoginViewController.swift
//  instagram
//
//  Created by Jessica Yeh on 6/27/17.
//  Copyright © 2017 Jessica Yeh. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    
    let existsAlertController = UIAlertController(title: "Account already exists for this username.", message: "Please try again", preferredStyle: .alert)
    
    let incorrectAlertController = UIAlertController(title: "Invalid username/password", message: "Please retry", preferredStyle: .alert)
    
    let emptyFieldAlertController = UIAlertController(title: "Username or password field is empty", message: "Please enter text", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        existsAlertController.addAction(OKAction)
        incorrectAlertController.addAction(OKAction)
        emptyFieldAlertController.addAction(OKAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: Error?) in
            if user != nil {
                print("logged in")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }

    @IBAction func onSignUp(_ sender: Any) {
        let newUser = PFUser()
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("yay new user")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print(error?.localizedDescription as Any)
                if error?._code == 202 {
                    self.present(self.existsAlertController, animated: true)
                } else if error?._code == 200 || error?._code == 201 {
                    self.present(self.emptyFieldAlertController, animated: true)
                } else if error?._code == 101 {
                    self.present(self.incorrectAlertController, animated: true)
                }
            }
            
        }
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
