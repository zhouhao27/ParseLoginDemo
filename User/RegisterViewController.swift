//
//  RegisterViewController.swift
//  User
//
//  Created by Zhou Hao on 24/11/14.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

import UIKit

protocol RegisterViewControllerDelegate {
 
    func onRegistered(viewController : RegisterViewController)

}

class RegisterViewController: UIViewController {

    var delegate : RegisterViewControllerDelegate?
    
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRepassword: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRegister(sender: AnyObject) {
        
        if txtUser.text.isEmpty {
            showAlert("User name can't be empty!")
            txtUser.becomeFirstResponder()
            return
        }
        
        if txtEmail.text.isEmpty {
            showAlert("Email can't be empty!")
            txtEmail.becomeFirstResponder()
            return
        }

        if txtPassword.text.isEmpty || txtRepassword.text.isEmpty || txtPassword.text != txtRepassword.text {
            showAlert("Password is empty or doesn't match password confirmation!")
            txtPassword.becomeFirstResponder()
            return
        }
        
        // register
        var user = PFUser()
        user.username = self.txtUser.text
        user.email = self.txtEmail.text
        user.password = self.txtPassword.text
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            
            if (error != nil) {
                let msg = error.userInfo!["error"] as String
                self.showAlert(msg)
            } else {
                
                if self.delegate != nil {
                    self.delegate!.onRegistered(self)
                }
            }
        }
    }

    func showAlert(message : String) {
        
        self.lblStatus.text = message
        self.containerView.transform = CGAffineTransformIdentity
        UIView.animateWithDuration(0.1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

            self.containerView.transform = CGAffineTransformMakeTranslation(0, 10)
            
        }) { (finished) -> Void in
            
            self.containerView.transform = CGAffineTransformIdentity
        }
    }
}
