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
    
    // Declare variables
    var error = ""
    var checkBool:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var uuid = NSUUID().UUIDString
        
       }
    
    override func viewDidAppear(animated: Bool) {
        
        // Check if user has signed in previously
        if PFUser.currentUser() != nil {
            
            User = PFUser.currentUser()?.valueForKey("Name") as! String
            getUserInfo()
            self.performSequetoTabBarController()
        }
        
        self.userEmail.delegate = self
        self.userPassword.delegate = self
        
        // Check Current Access Token for Facebook and perform seque to Tab Bar Controller if available
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            returnUserData()
            getUserInfo()
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
    
    // Get User's name and image to be used for messaging and map
    func getUserInfo() {
        
        var query:PFQuery = PFQuery(className: "Members")
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]?, error:NSError?) -> Void in
            
            if let objects = objects {
                
                for userObject in objects {
                    
                    let userName: String! = (userObject as! PFObject)["Name"] as? String
                    let photo = (userObject as! PFObject)["photo"] as? PFFile
                    var id = userObject.objectId!
                    
                    if userName == User {
                        userImage = photo
                        self.getUserUIImage()
                        userId = id!
                    }
                }
            }
        }
    }
    
    // Get userImage
    func getUserUIImage() {
        
        userImage!.getDataInBackgroundWithBlock {
            (imageData: NSData?, error:NSError?) -> Void in
            
            if (error == nil) {
                userUIImage = UIImage(data: imageData!)
                
            } else {
                var err = String(_cocoaString: error!)
                self.showAlertMsg("UserImage Error", errorMsg: err)
            }
        }
        
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
                    
                    self.getUserInfo()
                    
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
            returnUserData()
            performSegueWithIdentifier("tabBarController", sender: self)
        }
        
    }
    
    // Facebook Logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    // Obtain User Data via Facebook Login
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                self.showAlertMsg("FBLogin Error", errorMsg: "Unable to retrieve user data")
            }
            else
            {
               let userId: String = result.valueForKey("id") as! String
               let userName: String = result.valueForKey("name") as! String
               let Email: String = result.valueForKey("email") as! String
                User = userName
        
                var query = PFQuery(className: "Members")
                query.findObjectsInBackgroundWithBlock {
                    (objects:[AnyObject]?, error:NSError?) -> Void in
                    
                    if error == nil {
                        
                        for object in objects! {
                        
                            var tempId = object["userId"]! as! String
                            var photo = (object as! PFObject)["photo"] as? PFFile
                            
                            if tempId == userId {
                                userImage = photo
                                self.checkBool = true
                            }
                        }
                        
                        if !self.checkBool {
                            
                            let url = NSURL(string: "http://graph.facebook.com/\(userId)/picture")
                            let urlRequest = NSURLRequest(URL: url!)
                            
                            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) {
                                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                                
                                var image = UIImage(data: data! as NSData)!
                                
                                var userPhoto = PFFile(name: "photo.png", data: UIImagePNGRepresentation(image))
                                
                                userImage = userPhoto
                                
                                self.getUserUIImage()
                                
                                var user = PFObject(className: "Members")
                                user.setObject(userId, forKey: "userId")
                                user.setObject(userName, forKey: "Name")
                                user.setObject(Email, forKey: "email")
                                user.setObject(userPhoto, forKey: "photo")
                                user.saveInBackground()
                                
                            }
                        }
                        
                    } else {
                        var err = String(_cocoaString: error!)
                        self.showAlertMsg("FBLogin Error", errorMsg: err)
                    }
                }
            }
        })
    }

}

