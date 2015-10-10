//
//  AddEventViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 7/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse

class AddEventViewController:UIViewController, UIPickerViewDelegate, UITextFieldDelegate  {
    
    // Declare variables
    var selectedDateTime = ""
    var selectedDate = ""
    var selectedTime = ""
    var space = " "
    var color = ""
    var colors = ["Red", "Green", "Blue", "Magenta", "Purple"]
    
    // Outlets for textfields and pickers
    @IBOutlet weak var eventTF: UITextField!
    @IBOutlet weak var eventLocationTF: UITextField!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically set right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save")
        
        // Set delegates for textfields
        self.eventTF.delegate = self
        self.eventLocationTF.delegate = self
        
        // Set date on date picker to selected date
        eventDatePicker.setDate(selDate, animated: true)
        getSelectedDateTime()
        
        // Set default color in color picker
        colorPicker.selectRow(2, inComponent: 0, animated: true)
        
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func viewWillAppear(animated: Bool) {
        self.subscribeToKeyboardNotifications()
    }
    
    // Textfield resigns first responder when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the view when the keyboard covers the text field
    func keyboardWillShow(notification: NSNotification) {
        if (eventLocationTF.isFirstResponder()){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Hide Keyboard
    func keyboardWillHide(notification: NSNotification) {
        if (eventLocationTF.isFirstResponder()){
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // Get height of keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    // Unsubscribe from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //# MARK: Pickerview Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return colors[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedColor = colors[row]
        color = selectedColor
    }
    
    //# MARK: DatePicker Methods
    
    func getSelectedDateTime() {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        selectedDateTime = dateFormatter.stringFromDate(eventDatePicker.date)
    }
    
    // Picker for selecting date and time
    @IBAction func datePickerAction(sender: AnyObject) {
        getSelectedDateTime()
    }
    
    // Show Alert Method
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Function to save event details
    func save() {
        
        self.eventLocationTF.endEditing(true)
        
        var eventString: String = eventTF.text
        
        // Check if device is connected to the Internet
        if Reachability.isConnectedToNetwork() == false {
            showAlertMsg("Connection Error", errorMsg: "Unable to connect to the internet. Please check your connection")
        }
        
        // Prompt user to fill in the event if the event field is empty
        else if eventString.isEmpty {
            showAlertMsg("Calendar Update Error", errorMsg: "Please fill in the event")
        }
        
        
        else {
        IndicatorView.shared.showActivityIndicator(view)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
        
        var splitDateTime = selectedDateTime.componentsSeparatedByString(space)
        selectedDate = splitDateTime[0]
        selectedTime = splitDateTime[1]
        
        var newEventObject:PFObject = PFObject(className: "Calendar")
        newEventObject["Date"] = selectedDate
        newEventObject["Event"] = eventTF.text
        newEventObject["Location"] = eventLocationTF.text
        newEventObject["Time"] = selectedTime
        newEventObject["Color"] = color
        
        if color != "" {
            newEventObject["Color"] = color
        } else {
            newEventObject["Color"] = "Blue"
        }
        
        newEventObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                NSLog("Event saved successfully")
                Client.sharedInstance().retrieveNewEvent()
                addEventBool = true
                self.navigationItem.hidesBackButton = false
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save")
                IndicatorView.shared.hideActivityIndicator()
                
            } else {
                NSLog(error!.description)
                IndicatorView.shared.hideActivityIndicator()
                self.showAlertMsg("Calendar Update Error", errorMsg: error!.description)

            }
        }
    }
    }
}
