//
//  LoginViewController.swift
//  User
//
//  Created by Zhou Hao on 24/11/14.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func onRegister(loginViewController : LoginViewController)
    func onFacebookLogin(loginViewController : LoginViewController)
    func onLogin(loginViewController : LoginViewController)
}

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var delegate : LoginViewControllerDelegate?
    
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignin(sender: AnyObject) {

        if txtUser.text.isEmpty {
            self.lblStatus.text = "User can't be empty!"
            txtUser.becomeFirstResponder()
            return
        }
        
        PFUser.logInWithUsernameInBackground(txtUser.text, password: txtPassword.text, block: { (success, error) -> Void in
            
            if error != nil {
                
                let msg = error.userInfo!["error"] as String
                self.lblStatus.text = msg
                
            } else {
                if self.delegate != nil {
                    self.delegate!.onLogin(self)
                }
            }
        })
        
    }

    @IBAction func onRegister(sender: AnyObject) {
        
        if self.delegate != nil {
            self.delegate!.onRegister(self)
        }
        
    }
    
    // The developers of this app have not set up this app properly for Facebook Login?
    // http://stackoverflow.com/questions/21329250/the-developers-of-this-app-have-not-set-up-this-app-properly-for-facebook-login
    // https://parse.com/tutorials/integrating-facebook-in-ios
    // https://parse.com/tutorials/login-and-signup-views#subclass
    @IBAction func onFacebookLogin(sender: AnyObject) {
        
        // Set permissions required from the facebook user account
        let permissionsArray = [ "user_about_me", "user_relationships", "user_location"]
        
        // Login PFUser using Facebook
        PFFacebookUtils.logInWithPermissions(permissionsArray, block: { (theUser, error) -> Void in
            
            //[_activityIndicator stopAnimating]; // Hide loading indicator
            if theUser == nil {
                var errorMessage = ""
                if error == nil {
                    errorMessage = "Uh oh. The user cancelled the Facebook login."
                } else {
                    errorMessage = error.localizedDescription
                }
                
                self.lblStatus.text = errorMessage
                
            } else {
                
                if theUser.isNew {
                    println("User with facebook signed up and logged in!")
                } else {
                    println("User with facebook logged in!")
                }
                
                if self.delegate != nil {
                    self.delegate!.onFacebookLogin(self)
                }
                
                //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
            }
        })
    }
    
}
