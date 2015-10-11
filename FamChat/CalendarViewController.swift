//
//  ViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 6/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

// Declare public variables outside of class
var selDate:NSDate = NSDate()
var addEventBool = false

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var secondDateLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let loginManager = FBSDKLoginManager()
    
    // Declare variables
    var timer: NSTimer = NSTimer()
    var shouldShowDaysOut = true
    var animationFinished = true
    var compMth = ""
    var compare = ""
    var todaysDate:NSDate = NSDate()
    var today:String = ""
    var tomorrow:String = ""
    var yesterday:String = ""
    var dayViewDate:String = ""
    var selectedDate:String = ""
    var eventsDefault:String = "No Event Scheduled"


    // MARK: - Life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve persistent data from NSUserDefaults if available
        if let rEventsArray:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("eventsArray") { eventsArray = rEventsArray as! Array }
        if let rDatesArray:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("datesArray") { datesArray = rDatesArray as! Array }
        if let rLocationsArray:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("locationsArray") { locationsArray = rLocationsArray as! Array }
        if let rTimesArray:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("timesArray") { timesArray = rTimesArray as! Array }
        if let rColorsArray:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("colorsArray") { colorsArray = rColorsArray as! Array }
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        // Get next day and previous day
        let tomDate = NSCalendar.currentCalendar().dateByAddingUnit(
            .CalendarUnitDay,
            value: 1,
            toDate: todaysDate,
            options: NSCalendarOptions(0))
        
        let yesDate = NSCalendar.currentCalendar().dateByAddingUnit(
            .CalendarUnitDay,
            value: -1,
            toDate: todaysDate,
            options: NSCalendarOptions(0))
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        tomorrow = dateFormatter.stringFromDate(tomDate!)
        yesterday = dateFormatter.stringFromDate(yesDate!)
        
        selectedDateLabel.text = "Today"
        secondDateLabel.text = calendarView.presentedDate.commonDescription
        compMth = calendarView.presentedDate.commonDescription
        
        // Reload view when a new event is saved and retrieved
        if (addEventBool) {
            reloadMonth()
            addEventBool = false
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    // Periodically retrieve a new event if available
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadEvents", userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    func loadEvents() {
        Client.sharedInstance().retrieveNewEvent()
    }
    

    // Add Event Button Pressed
    @IBAction func addEvent(sender: UIBarButtonItem) {
        let addEventVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddEventViewController") as! AddEventViewController
        navigationController?.pushViewController(addEventVC, animated: true)
    }
    
   override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    self.calendarView.commitCalendarViewUpdate()
    self.menuView.commitMenuViewUpdate()
    }
}



// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    // When user selects a particular date on the calendar
    func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date.convertedDate()
        selDate = date!
        
        eventLabel.text = eventsDefault
        timeLabel.text = ""
        venueLabel.text = ""
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        selectedDate = dateFormatter.stringFromDate(date!)
        
        for var i = 0; i < datesArray.count; i++ {
            if selectedDate == datesArray[i]{
                eventLabel.text = eventsArray[i]
                venueLabel.text = locationsArray[i]
                timeLabel.text = timesArray[i]
            }
        }
        
        if dayView.isCurrentDay {
            selectedDateLabel.text = "Today"
            secondDateLabel.text = calendarView.presentedDate.commonDescription
        } else if selectedDate == tomorrow {
            selectedDateLabel.text = "Tomorrow"
            secondDateLabel.text = calendarView.presentedDate.commonDescription
        } else if selectedDate == yesterday {
            selectedDateLabel.text = "Yesterday"
            secondDateLabel.text = calendarView.presentedDate.commonDescription
        }
        else {
            selectedDateLabel.text = calendarView.presentedDate.commonDescription
            secondDateLabel.text = ""
        }
    }
    
    func presentedDateUpdated(date: CVDate) {
        
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    // Set dotMarkers
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dayViewDate = dateFormatter.stringFromDate(dayView.date.convertedDate()!)
        
        for var i = 0; i < datesArray.count; i++ {
            if datesArray[i] == dayViewDate {
                return true
            }
        }
        return false
    }
    
    // Set dotMarker colors
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dayViewDate = dateFormatter.stringFromDate(dayView.date.convertedDate()!)
        
        for var i = 0; i < colorsArray.count ; i++ {
            
            if datesArray[i] == dayViewDate {
            
            if colorsArray[i] == "Red" {
                color = UIColor.redColor()
            } else if colorsArray[i] == "Green" {
                color = UIColor.greenColor()
            } else if colorsArray[i] == "Blue" {
                color = UIColor.blueColor()
            } else if colorsArray[i] == "Magenta" {
                color = UIColor.magentaColor()
            } else if colorsArray[i] == "Purple" {
                color = UIColor.purpleColor()
            }
        
        }
        }
        
        return [color, color, color]
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
}

// MARK: - CVCalendarViewDelegate

extension CalendarViewController: CVCalendarViewDelegate {
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        var newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        var ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        
        return false
    }
}



// MARK: - CVCalendarViewAppearanceDelegate

extension CalendarViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension CalendarViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    func reloadMonth() {
        calendarView.reloadMonthView(NSDate())
    }
    
}

// MARK: - Convenience API Demo

extension CalendarViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    // Logout button pressed
    @IBAction func logout(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}