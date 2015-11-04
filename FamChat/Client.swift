//
//  Client.swift
//  FamChat
//
//  Created by Gerard Heng on 15/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import CoreData
import FBSDKLoginKit

var imagesArray:[UIImage] = [UIImage]()
var membersArray:[String] = [String]()
var datesArray:[String] = [String]()
var eventsArray:[String] = [String]()
var locationsArray:[String] = [String]()
var timesArray:[String] = [String]()
var colorsArray:[String] = [String]()
var color:UIColor = UIColor.clearColor()
var count:Int?
var userimage: UIImage?
var lastmessObjId: String?
var lastmemObjId: String?
var lastcalObjId: String?
var checkBool:Bool = false

class Client: NSObject {
    
    var userPhoto: UIImage?
    
    /* Shared Session */
    var session : NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    func retrieveCalendarEvents(){
        
        let query:PFQuery = PFQuery(className: "Calendar")
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            
            datesArray = [String]()
            eventsArray = [String]()
            locationsArray = [String]()
            timesArray = [String]()
            colorsArray = [String]()
            
            let objId = objects?.last!.objectId
            lastcalObjId = objId!
            
            if let objects = objects {
                
                for eventObject in objects {
                    let date:String? = (eventObject as! PFObject)["Date"] as? String
                    let event:String? = (eventObject as! PFObject)["Event"] as? String
                    let location:String? = (eventObject as! PFObject)["Location"] as? String
                    let time:String? = (eventObject as! PFObject)["Time"] as? String
                    let color:String? = (eventObject as! PFObject)["Color"] as? String
                    
                    if date != nil {
                        datesArray.append(date!)
                        eventsArray.append(event!)
                        locationsArray.append(location!)
                        timesArray.append(time!)
                        colorsArray.append(color!)
                    }
                }
            }
            
            NSUserDefaults.standardUserDefaults().setObject(datesArray, forKey: "datesArray")
            NSUserDefaults.standardUserDefaults().setObject(eventsArray, forKey: "eventsArray")
            NSUserDefaults.standardUserDefaults().setObject(locationsArray, forKey: "locationsArray")
            NSUserDefaults.standardUserDefaults().setObject(timesArray, forKey: "timesArray")
            NSUserDefaults.standardUserDefaults().setObject(colorsArray, forKey: "colorsArray")
        }
    }
    
    func retrieveNewEvent(){
        
        let query:PFQuery = PFQuery(className: "Calendar")
        query.orderByDescending("createdAt")
        query.limit = 1
        
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let firstObject: AnyObject = objects?.first {
                    
                    let date:String? = firstObject["Date"] as? String
                    let event:String? = firstObject["Event"] as? String
                    let location:String? = firstObject["Location"] as? String
                    let time:String? = firstObject["Time"] as? String
                    let color:String? = firstObject["Color"] as? String
                    let objId:String? = firstObject.objectId
                    
                    if objId != lastcalObjId {
                        datesArray.append(date!)
                        eventsArray.append(event!)
                        locationsArray.append(location!)
                        timesArray.append(time!)
                        colorsArray.append(color!)
                        addEventBool = true
                    }
                    lastcalObjId = objId
                    
                    NSUserDefaults.standardUserDefaults().setObject(datesArray, forKey: "datesArray")
                    NSUserDefaults.standardUserDefaults().setObject(eventsArray, forKey: "eventsArray")
                    NSUserDefaults.standardUserDefaults().setObject(locationsArray, forKey: "locationsArray")
                    NSUserDefaults.standardUserDefaults().setObject(timesArray, forKey: "timesArray")
                    NSUserDefaults.standardUserDefaults().setObject(colorsArray, forKey: "colorsArray")
                }
            }
        }
    }

    
    func retrieveMembers() {
        
        let query:PFQuery = PFQuery(className: "Members")
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            
            let objId = objects!.last!.objectId
            lastmemObjId = objId!
            
            if let objects = objects {
                
                count = objects.count
                
                for memberObject in objects {
                    
                    let memberName:String? = (memberObject as! PFObject)["Name"] as? String
                    let photo = (memberObject as! PFObject)["photo"] as? PFFile
                    
                    photo?.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        self.userPhoto = UIImage(data: imageData!)
                        
                        
                        let memberInfo: [String:AnyObject] = [
                            Person.Keys.Name : memberName!,
                            Person.Keys.Image : self.userPhoto!
                        ]
                        
                        dispatch_async(dispatch_get_main_queue()){
                            Person(dictionary: memberInfo, context: self.sharedContext)
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                }
            }
        }
    }
    
    func updateMemberList() {
        
        let query:PFQuery = PFQuery(className: "Members")
        query.orderByDescending("createdAt")
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            
            if error == nil {
                
                if let firstObject: AnyObject = objects?.first {

                    let memberName:String? = firstObject["Name"] as? String
                    let photo = firstObject["photo"] as? PFFile
                    let objId:String? = firstObject.objectId
                    
                    photo?.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        self.userPhoto = UIImage(data: imageData!)
                        
                        let memberInfo: [String:AnyObject] = [
                            Person.Keys.Name : memberName!,
                            Person.Keys.Image : self.userPhoto!
                        ]
                        
                        if objId != lastmemObjId {
                            
                            dispatch_async(dispatch_get_main_queue()){
                                let memberToBeAdded = Person(dictionary: memberInfo, context: self.sharedContext)
                                CoreDataStackManager.sharedInstance().saveContext()
                            }
                            lastmemObjId = objId
                        }
                    }
                }
            }
        }
    }
    
    
    
    func retrieveMessages() {
        
        // Create a new PFQuery
        let query:PFQuery = PFQuery(className: "Messages")
        
        // Call findobjectsinbackground
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            
            let objId = objects!.last!.objectId
            NSUserDefaults.standardUserDefaults().setObject(objId!, forKey: "lastmessObjId")
            
            if let objects = objects {
                
                // Loop through the objects array
                for messageObject in objects {
                    
                    // Retrieve the Text column value of each PFObject
                    let messageText:String? = (messageObject as! PFObject)["Text"] as? String
                    let userName:String? = (messageObject as! PFObject)["Name"] as? String
                    let image:PFFile? = (messageObject as! PFObject)["userImage"] as? PFFile
                    let date = messageObject.createdAt as NSDate!
                                        
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy       HH:mm"
                    
                    let datetime:String? = dateFormatter.stringFromDate(date)
                    
                    image?.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        userimage = UIImage(data: imageData!)
                        
                        let messageInfo:[String:AnyObject] = [
                            Message.Keys.Message : messageText!,
                            Message.Keys.Date : datetime!,
                            Message.Keys.Name : userName!,
                            Message.Keys.Image : userimage!
                        ]
                        
                        dispatch_async(dispatch_get_main_queue()){
                            Message(dictionary: messageInfo, context: self.sharedContext)
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                }
            }
        }
    }
    
    func retrieveLastMessage(){
        
        // Create a new PFQuery
        let query:PFQuery = PFQuery(className: "Messages")
        
        query.orderByDescending("createdAt")
        query.limit = 1
        
        // Call findobjectsinbackground
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            
            if error ==  nil {
                
                if let firstObject: AnyObject = objects?.first {
                    
                    let messageText:String? = firstObject["Text"] as? String
                    let userName:String? = firstObject["Name"] as? String
                    let image:PFFile? = firstObject["userImage"] as? PFFile
                    let date  = firstObject.createdAt as NSDate!
                    let objId:String? = firstObject.objectId
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy       HH:mm"
                    
                    let datetime:String? = dateFormatter.stringFromDate(date)
                    
                    image?.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        userimage = UIImage(data: imageData!)
                        
                        let messageInfo:[String:AnyObject] = [
                            Message.Keys.Message : messageText!,
                            Message.Keys.Date : datetime!,
                            Message.Keys.Name : userName!,
                            Message.Keys.Image : userimage!
                        ]
                        
                        if objId != lastmessObjId {
                        dispatch_async(dispatch_get_main_queue()){
                            let messageToBeAdded = Message(dictionary: messageInfo, context: self.sharedContext)
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        lastmessObjId = objId
                        NSUserDefaults.standardUserDefaults().setObject(objId!, forKey: "lastmessObjId")
                            
                        }
                    }
                }
            }
        }
    }
    
    // Get User's name and image to be used for messaging and map
    func getUserInfo() {
        
        let query:PFQuery = PFQuery(className: "Members")
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]?, error:NSError?) -> Void in
            
            if let objects = objects {
                
                for userObject in objects {
                    
                    let userName: String! = (userObject as! PFObject)["Name"] as? String
                    let photo = (userObject as! PFObject)["photo"] as? PFFile
                    let id = userObject.objectId!
                    
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
                userUIImage = UIImage(named: "profile")
            }
        }
    }
    
    // Obtain User Data via Facebook Login
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                LoginViewController().showAlertMsg("FBLogin Error", errorMsg: "Unable to retrieve user data")
            }
            else
            {
                let userId: String = result.valueForKey("id") as! String
                let userName: String = result.valueForKey("name") as! String
                let Email: String = result.valueForKey("email") as! String
                User = userName
                
                let query = PFQuery(className: "Members")
                query.findObjectsInBackgroundWithBlock {
                    (objects:[AnyObject]?, error:NSError?) -> Void in
                    
                    if error == nil {
                        
                        for object in objects! {
                            
                            let tempId = object["userId"]! as! String
                            let photo = (object as! PFObject)["photo"] as? PFFile
                            
                            if tempId == userId {
                                userImage = photo
                                checkBool = true
                            }
                        }
                        
                        if !checkBool {
                            
                           // let url = NSURL(string: "http://graph.facebook.com/\(userId)/picture")
                          //  let urlRequest = NSURLRequest(URL: url!)
                            
                            let urlRequest = NSMutableURLRequest(URL: NSURL(string: "http://graph.facebook.com/\(userId)/picture")!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
                            
                            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) {
                                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                                
                                let image = UIImage(data: data! as NSData)!
                                
                                let userPhoto = PFFile(name: "photo.png", data: UIImagePNGRepresentation(image)!)
                                
                                userImage = userPhoto
                                
                                self.getUserUIImage()
                                
                                let user = PFObject(className: "Members")
                                user.setObject(userId, forKey: "userId")
                                user.setObject(userName, forKey: "Name")
                                user.setObject(Email, forKey: "email")
                                user.setObject(userPhoto, forKey: "photo")
                                user.saveInBackground()
                                
                            }
                        }
                        
                    } else {
                        let err = error?.localizedDescription
                        LoginViewController().showAlertMsg("FBLogin Error", errorMsg: err!)
                    }
                }
            }
        })
    }

    


    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }
    
    
}
