//
//  RegisterViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 13/8/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    // Textfield outlets
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // Declare variables
    var error = ""
    var userId: String = ""
    
    override func viewDidAppear(animated: Bool) {
        
        // Set delegates for textfields
        self.name.delegate = self
        self.email.delegate = self
        self.password.delegate = self
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
       
    }

    
    // Register button pressed
    @IBAction func register(sender: AnyObject) {
        
        var nameString: String = name.text
        var userNameString: String = email.text
        var emailString: String = email.text
        var passwordString: String = password.text
        
        // Prompt user to enter name if username field is empty
        if nameString.isEmpty {
            showAlertMsg("SignUp Error", errorMsg: "Please enter your name")
        }
        
        // Prompt user to enter email if email field is empty
        else if emailString.isEmpty {
            showAlertMsg("SignUp Error", errorMsg: "Please enter your email")
        }
        
        // Prompt user to enter password if password field is empty
        else if passwordString.isEmpty {
            showAlertMsg("SignUp Error", errorMsg: "Please enter your password")
        }
        
        else {
            
            // SignUp user
            var user = PFUser()
            user.setObject(name.text, forKey: "Name")
            user.username = email.text
            user.password = password.text
            user.email = email.text
            
            IndicatorView.shared.showActivityIndicator(view)
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, signupError: NSError?) -> Void in
                
                IndicatorView.shared.hideActivityIndicator()

                if signupError == nil {
                    
                    var image = UIImage(named: "profile.png")
                    var memberPhoto = PFFile(name: "photo.png", data: UIImagePNGRepresentation(image))
                
                    var member = PFObject(className: "Members")
                    member.setObject(user.objectId!, forKey: "userId")
                    member.setObject(self.name.text, forKey: "Name")
                    member.setObject(self.email.text, forKey: "email")
                    member.setObject(memberPhoto, forKey: "photo")
                    member.saveInBackground()
                    self.performSegueWithIdentifier("toTabBarController", sender: self)
                    
                } else {
                    if let errorString = signupError?.userInfo?["error"] as? NSString {
                    self.error = errorString as! String
                    
                } else {
                    self.error = "Please try again later"
                }
                    self.showAlertMsg("SignUp Error", errorMsg: self.error)
                }
            }
        }
    }
    
    // Show Alert Method
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                // No further action apart from dismissing this alert
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
