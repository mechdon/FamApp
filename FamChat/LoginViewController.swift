//
//  ViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 13/8/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

// Declare public variables outside of class
var User: String = ""
var Id: String = ""
var userImage:PFFile?
var userUIImage:UIImage?
var userId: String = ""

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // Textfield outlets for userEmail and Password
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    // Declare variable
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var uuid = NSUUID().UUIDString
        
       }
    
    override func viewDidAppear(animated: Bool) {
        
        // Check if user has signed in previously
        if PFUser.currentUser() != nil {
            
            User = PFUser.currentUser()?.valueForKey("Name") as! String
            Client.sharedInstance().getUserInfo()
            self.performSequetoTabBarController()
        }
        
        self.userEmail.delegate = self
        self.userPassword.delegate = self
        
        // Check Current Access Token for Facebook and perform seque to Tab Bar Controller if available
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            Client.sharedInstance().returnUserData()
            Client.sharedInstance().getUserInfo()
            performSequetoTabBarController()
        }
        else
        {
                // Present Facebook Login Button
                let loginView : FBSDKLoginButton = FBSDKLoginButton()
                self.view.addSubview(loginView)
                loginView.frame = CGRectMake(0, 380, 288, 38)
                loginView.center.x = self.view.center.x
                loginView.readPermissions = ["public_profile", "email", "user_friends"]
                loginView.delegate = self
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    // Textfield resigns first responder when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Login button pressed
    @IBAction func loginPressed(sender: AnyObject) {
        
        var emailString: String = userEmail.text
        var passwordString: String = userPassword.text
        
        // Check if device is connected to the Internet
        if Reachability.isConnectedToNetwork() == false {
            showAlertMsg("Connection Error", errorMsg: "Unable to connect to the internet. Please check your connection")
        }
        
        // Prompt user to enter email if emailUsername field is empty
        else if emailString.isEmpty {
            showAlertMsg("Login Error", errorMsg: "Please enter your email")
        }
        
        // Prompt user to enter password if password field is empty
        else if passwordString.isEmpty {
            showAlertMsg("Login Error", errorMsg: "Please enter your password")
        }

        else {
            
            IndicatorView.shared.showActivityIndicator(view)
            
            PFUser.logInWithUsernameInBackground(userEmail.text, password:userPassword.text) {
                (user: PFUser?, loginError: NSError?) -> Void in
                
            IndicatorView.shared.hideActivityIndicator()
                
                if loginError == nil {
                    User = PFUser.currentUser()?.valueForKey("Name") as! String
                    Client.sharedInstance().getUserInfo()
                    self.performSequetoTabBarController()
                } else {
                    if let errorString = loginError?.userInfo?["error"] as? NSString {
                    self.error = errorString as String
                    } else {
                    self.error = "Please try again later"
                    }
                    self.showAlertMsg("Login Error", errorMsg: self.error)
                    }
                }
            }
        }
    
    // Function to perform seque to Tab Bar Controller
   func performSequetoTabBarController() {
        NSOperationQueue.mainQueue().addOperationWithBlock{
            self.performSegueWithIdentifier("tabBarController", sender: self)
        }
    }
    
    // Show Alert Method
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    //# MARK: - Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
            self.showAlertMsg("FBLogin Error", errorMsg: "Unable to log in to Facebook")
        }
        else if result.isCancelled {
            // Handle cancellations
            self.showAlertMsg("Cancel", errorMsg: "Cancel Facebook Login")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            Client.sharedInstance().returnUserData()
            performSegueWithIdentifier("tabBarController", sender: self)
        }
        
    }
    
    // Facebook Logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    
}

