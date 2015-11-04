//
//  MessagesViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 6/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import CoreData
import FBSDKLoginKit



class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    // Outlets
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    let loginManager = FBSDKLoginManager()
    
    // Declare variables
    var timer: NSTimer = NSTimer()
    var userimage: UIImage?
    var uImage: UIImage?
    var startBool:Bool = true
    var objects:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check last message object Id saved to prevent receiving duplicate messages
        if let lmoi:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("lastmessObjId"){
            lastmessObjId = lmoi as? String
        }
        
        // Set delegates and datasource for tableview and textfield
        self.messagesTableView.delegate = self
        self.messagesTableView.dataSource = self
        self.messageTextField.delegate = self
        
        do {
            // Set delegate for fetchedResultsController
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
        // Add a tap gesture recognizer to the tableview
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messagesTableView.addGestureRecognizer(tapGesture)
        
        // No lines for table
        self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    // Periodically retrieve a new message from Parse
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollToLastRow()
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    
    func loadMessages(){
        Client.sharedInstance().retrieveLastMessage()
        scrollToLastRow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // To end editing when user taps outside of textfield
    func tableViewTapped() {
        self.messageTextField.endEditing(true)
    }
    
    // Send button pressed
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        self.messageTextField.endEditing(true)
        
        // Disable the send button and textfield
        self.messageTextField.enabled = false
        self.sendButton.enabled = false
        
        // Create a PFObject
        let newMessageObject:PFObject = PFObject(className: "Messages")
        
        // Set the Text key to the messageTextField
        newMessageObject["Text"] = self.messageTextField.text
        newMessageObject["Name"] = User
        newMessageObject["userImage"] = userImage
        
        // Save the PFObject
        newMessageObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                self.loadMessages()
                NSLog("Message saved successfully")
                
            } else {
                NSLog(error!.description)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Enable the textfield and send button
                self.sendButton.enabled = true
                self.messageTextField.enabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    // Function to scroll to last row whenever a new nessage is retrieved
    func scrollToLastRow() {
        let indexPath = NSIndexPath(forRow: objects!-1, inSection: 0)
        messagesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    //# MARK: Text Field Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 280
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()

    
    //# MARK: Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        objects = sectionInfo.numberOfObjects
        return objects!
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "MessageCell"
        let message = fetchedResultsController.objectAtIndexPath(indexPath) as! Message
        let cell = messagesTableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MessageTableViewCell
        configureCell(cell, withMessage: message)
        
        // Return the cell
        return cell
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.messagesTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.messagesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.messagesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            messagesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            messagesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            let cell = messagesTableView.cellForRowAtIndexPath(indexPath!) as! MessageTableViewCell
            let message = controller.objectAtIndexPath(indexPath!) as! Message
            self.configureCell(cell, withMessage: message)
            
        case .Move:
            messagesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            messagesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.messagesTableView.endUpdates()
    }
    
    func configureCell(cell: MessageTableViewCell, withMessage message: Message){
        
        // Initialise frames
        cell.messageLabel = UILabel(frame: CGRectMake(130.0, 35.0, CGRectGetWidth(cell.frame) - 20, 5))
        cell.userImage = UIImageView(frame: CGRectMake(14.0, 21.0, 58.0, 58.0))
        cell.nameLabel = UILabel(frame: CGRectMake(8.0, 78.0, 71.0, 21.0))
        cell.datetimeLabel = UILabel(frame: CGRectMake(113.0, 14.0, 117.0, 21.0))
        
        // Assign data from Message class
        cell.messageLabel.text = message.message
        cell.datetimeLabel.text = message.date
        cell.nameLabel.text = message.name
        cell.userImage.image = message.image
        
       // Remove views to prevent ovelapping
       for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        
    }
    
    // Logout button pressed
    @IBAction func logout(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

