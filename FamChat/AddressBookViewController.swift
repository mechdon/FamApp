//
//  AddressBookViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 29/10/15.
//  Copyright © 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import AddressBook

class AddressBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addressbookTableView: UITableView!
    
    var addressbookArray:[String] = [String]()
    var selectionArray:[String] = [String]()
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
    }()
    
    override func viewDidLoad() {
        
        self.addressbookTableView.dataSource = self
        self.addressbookTableView.delegate = self
        
        var rightAddButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Add Selection", style: UIBarButtonItemStyle.Plain, target: self, action: "addSelection:")
        self.navigationItem.setRightBarButtonItem(rightAddButtonItem, animated: true)
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            print("Already authorized")
            readFromAddressBook(addressBook)
        case .Denied:
            print("You are denied access to address book")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {[weak self] (granted: Bool, error: CFError!) in
                    
                    if granted{
                        let strongSelf = self!
                        print("Access is granted")
                        strongSelf.readFromAddressBook(strongSelf.addressBook)
                    } else {
                        print("Access is not granted")
                    }
                    
                })
        case .Restricted:
            print("Access is restricted")
            
        default:
            print("Unhandled")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func readFromAddressBook(addressBook: ABAddressBookRef){
        
        /* Get all the people in the address book */
        let allPeople = ABAddressBookCopyArrayOfAllPeople(
            addressBook).takeRetainedValue() as NSArray
        
        for person: ABRecordRef in allPeople{
            
            let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
            let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as! String
            //let email: ABMultiValueRef = ABRecordCopyValue(person
            //    , kABPersonEmailProperty).takeRetainedValue()
            
            var name = firstName + " " + lastName
            self.addressbookArray.append(name)
            
        }
        
        dispatch_async(dispatch_get_main_queue()){
            self.addressbookTableView.reloadData()
        }
        
    }
    
    
    //# MARK - TableView Methods
    
    // Return number of members
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressbookArray.count
    }
    
    // Populate rows with member names
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = addressbookArray[indexPath.row]
        return cell
    }
    
    // Launch corresponding URL for selected row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        var selectedName = cell.textLabel!.text!
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            if let index = selectionArray.indexOf(selectedName) {
                selectionArray.removeAtIndex(index)
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
            
        } else {
            selectionArray.append(selectedName)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
    }
    
    func addSelection(sender: UIBarButtonItem){
        print(selectionArray)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
}

