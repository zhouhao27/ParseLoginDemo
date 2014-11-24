//
//  BlogViewController.swift
//  User
//
//  Created by Zhou Hao on 23/11/14.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

import UIKit

class BlogViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,LoginViewControllerDelegate, RegisterViewControllerDelegate {

    var comments = [Comment]()
    var prototypeCell : CommentCell?
    lazy var user = User()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didChangePreferredContentSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        self.prototypeCell = getPrototypeCell()
        
        showLogout(true)
        
        if isLoggedIn() {
            
            // linked to facebook
            if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
                requestFacebookInfo()
            } else {
                requestUserInfo()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func getPrototypeCell() -> CommentCell
    {
        if prototypeCell == nil
        {
            prototypeCell = self.tableView.dequeueReusableCellWithIdentifier("commentCell") as? CommentCell
        }
        return prototypeCell!
    }
    
    @IBAction func onWriteComment(sender: AnyObject) {
        
        if isLoggedIn() {
            let alertView = UIAlertView(title: "Post Comment", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            alertView.tag = 2;
            alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView.show()
        } else {
            // not logged in, register
            let popin = LoginViewController(nibName: "LoginViewController", bundle:nil)
            popin.delegate = self
            popup(popin)
        }
    }
    
    func onLogout(sender : AnyObject) {
        PFUser.logOut()
        showLogout(false)
    }
    
    func isLoggedIn() -> Bool {
        
        return PFUser.currentUser() != nil && PFUser.currentUser().isAuthenticated()
    }
    
    func popup(popin : UIViewController) {
        //Customize transition if needed
        popin.setPopinTransitionStyle(.Snap)
        
        //Add options
        //popin.setPopinOptions(.DisableAutoDismiss)
        
        //Customize transition direction if needed
        popin.setPopinTransitionDirection(.Top)
        
        //Create a blur parameters object to configure background blur
        let blurParameters = BKTBlurParameters()
        blurParameters.alpha = 1
        blurParameters.radius = 5.0
        blurParameters.saturationDeltaFactor = 1.0
        blurParameters.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.60)
        popin.setBlurParameters(blurParameters)
        
        //Add option for a blurry background
        popin.setPopinOptions(popin.popinOptions()|BKTPopinOption.BlurryDimmingView)
        
        //Present popin on the desired controller
        //Note that if you are using a UINavigationController, the navigation bar will be active if you present
        // the popin on the visible controller instead of presenting it on the navigation controller
        self.navigationController?.presentPopinController(popin, animated:true, completion:{
        })
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    
        if alertView.tag == 2 && buttonIndex == 1 {
            
            if let alertTextField = alertView.textFieldAtIndex(0) {
                
                if !alertTextField.text.isEmpty {
                    var comment = Comment()
                    comment.user = self.user.name
                    comment.comment = alertTextField.text
                    comment.image = self.user.imgUrl
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func didChangePreferredContentSize(notification : NSNotification) {

        self.tableView.reloadData()
    }

    func onRegistered(viewController : RegisterViewController) {
        self.navigationController?.dismissCurrentPopinControllerAnimated(true,completion: {
            self.requestUserInfo()
            self.showLogout(true)
        })
    }
    
    func onRegister(loginViewController : LoginViewController) {
        
        self.navigationController?.dismissCurrentPopinControllerAnimated(true,completion: {
            let popin = RegisterViewController(nibName: "RegisterViewController", bundle:nil)
            popin.delegate = self
            self.popup(popin)
        })
    }
    
    func onFacebookLogin(loginViewController : LoginViewController) {
        
        // TODO: need to study why?
        self.navigationController?.popViewControllerAnimated(false)
        self.navigationController?.dismissCurrentPopinControllerAnimated(true,completion: {
            self.showLogout(true)
            self.requestFacebookInfo()
        })
    }
    
    func requestFacebookInfo() {
        
        let request = FBRequest.requestForMe()
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if error == nil {
                if let userData = result as? NSDictionary {
                    
                    let facebookId = userData["id"] as String
                    self.user.name = userData["name"] as String
                    //                        self._fbuser.location = userData["location"]["name"] as String
                    self.user.gender = userData["gender"] as String
                    self.user.imgUrl = NSURL(string: NSString(format: "https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId))
                    self.user.isFacebookUser = true
                }
                
            } else {
             
                if let userInfo = error.userInfo {
                
                    if let type: AnyObject = userInfo["error"] {
                        
                        if let msg = type["type"] as? String {
                            if msg == "OAuthException" { // Since the request failed, we can check if it was due to an invalid session
                                println("The facebook session was invalidated")
                                self.onLogout("")
                                return
                            }
                        }
                    }
                }
                
                println("Some other error: \(error)")
            }
        })
    }
    
    func requestUserInfo() {
        
        if let pfUser = PFUser.currentUser() {
            
            user.name = pfUser.username
            user.isFacebookUser = false
            user.imgUrl = nil
        }
        
    }
    
    func onLogin(loginViewController : LoginViewController) {
        self.navigationController?.dismissCurrentPopinControllerAnimated(true,completion: {
            self.showLogout(true)
            self.requestUserInfo()
        })
    }
    
    func showLogout(show : Bool) {
        if show {
            if isLoggedIn() {
                
                // show logout icon
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "onLogout:")
            }
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func configureCell(cell : UITableViewCell, forRowAtIndexPath indexPath : NSIndexPath) {

        if cell.isKindOfClass(CommentCell) {
            
            let commentCell = cell as CommentCell
            if let comment = self.comments[indexPath.row] as Comment? {
                commentCell.lblComment.text = comment.comment
                commentCell.lblUserName.text = comment.user
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.comments.count == 0 {
            return 44.0
        } else {
            
            configureCell(self.prototypeCell!, forRowAtIndexPath:indexPath)
            
            // Need to set the width of the prototype cell to the width of the table view
            // as this will change when the device is rotated.
            
            self.prototypeCell!.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell!.bounds));
            
            self.prototypeCell!.layoutIfNeeded()
            
            let size = self.prototypeCell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            return size.height+1;
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.comments.count > 0 {
            return self.comments.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.comments.count == 0 {        
            let cell = tableView.dequeueReusableCellWithIdentifier("firstCommentCell") as UITableViewCell
            cell.textLabel.text = "No comment yet.Please be the first to comment."
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as CommentCell
            configureCell(cell, forRowAtIndexPath: indexPath)
            
            if let comment = self.comments[indexPath.row] as Comment? {
                if comment.image != nil {
                
                    let urlRequest = NSURLRequest(URL: comment.image!)
                
                    // Run network request asynchronously
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler: { (response, data, connectionError) -> Void in
                        
                        if connectionError == nil && data != nil {
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.imgUser.image = UIImage(data: data)
                            })
                        }
                    })
                }
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Comments"
    }
    
}

