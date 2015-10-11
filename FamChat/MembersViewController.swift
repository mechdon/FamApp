//
//  MembersViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 22/8/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import CoreData
import FBSDKLoginKit

class MembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Outlet for TableView
    @IBOutlet var membersTableView: UITableView!
    
    let loginManager = FBSDKLoginManager()
    
    // Declare variables
    var timer: NSTimer = NSTimer()
    var photos = [PFFile]()
    var startBool:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates for TableView
        self.membersTableView.delegate = self
        self.membersTableView.dataSource = self
        
        // Set delegate for fetchedResultsController
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        // Check if the app is launched for the first time and there is no persistent data saved previously
        if let start:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("startBool") {
            startBool = start as! Bool
        }
        
        // Retrieve all members, messages and calendar events if app is launched for the first time
        if startBool {
            IndicatorView.shared.showActivityIndicator(view)
            Client.sharedInstance().retrieveCalendarEvents()
            Client.sharedInstance().retrieveMembers()
            Client.sharedInstance().retrieveMessages()
            startBool = false
            NSUserDefaults.standardUserDefaults().setBool(startBool, forKey: "startBool")
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    // Periodically update member list
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateMemberList", userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Reload data in TableView
    func reloadData() {
        dispatch_async(dispatch_get_main_queue()) {
            self.membersTableView.reloadData()
        }
    }
    
    // Retrieve new member to update member list
    func updateMemberList() {
        Client.sharedInstance().updateMemberList()
    }
    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()

    //# MARK - TableView Methods
    
    // Return number of members
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        if (sectionInfo.numberOfObjects == count) {
            IndicatorView.shared.hideActivityIndicator()}
        return sectionInfo.numberOfObjects
    }
    
    // Populate rows with member names
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "memberCell"
        
        let member = fetchedResultsController.objectAtIndexPath(indexPath) as! Person
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MemberTableViewCell
        
        configureCell(cell, withMember: member)
        
        return cell
    }
    
    // Launch corresponding URL for selected row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.membersTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.membersTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.membersTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                membersTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                membersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = membersTableView.cellForRowAtIndexPath(indexPath!) as! MemberTableViewCell
                let member = controller.objectAtIndexPath(indexPath!) as! Person
                self.configureCell(cell, withMember: member)
                
            case .Move:
                membersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                membersTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.membersTableView.endUpdates()
    }

    
    func configureCell(cell: MemberTableViewCell, withMember member: Person) {
        
        cell.nameLabel.text = member.name

        if let localImage = member.image {
            cell.memberImageView.image = localImage
            cell.memberImageView.layer.cornerRadius = cell.memberImageView.frame.size.width/2
            cell.memberImageView.clipsToBounds = true
        }
    }
    
    // Logout button pressed
    @IBAction func logout(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
