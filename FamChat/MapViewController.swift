//
//  MapViewController.swift
//  FamChat
//
//  Created by Gerard Heng on 6/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import ParseUI
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MapView outlet
    @IBOutlet weak var mapView: MKMapView!
   
   let loginManager = FBSDKLoginManager()
    
    // Declare variables
    var manager = CLLocationManager()
    var lat: Double = 0.0
    var lon: Double = 0.0
    var n = 0
    var userImage: UIImage?
    var uImage: UIImage?
    var pPhoto: PFFile?
    var userImageArray:[UIImage] = [UIImage]()
    var imageArray:[UIImage] = [UIImage]()
    var membersnameLocation:[String] = [String]()
    var memberPhotosLoc = [PFFile]()
    var latArray:[NSNumber] = [NSNumber]()
    var lonArray:[NSNumber] = [NSNumber]()
    var span:MKCoordinateSpan?
    var location: CLLocationCoordinate2D?
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Location Manager to provide updates on user location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    // Update user location in background
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation? = locations[0]
        let latitude:CLLocationDegrees = userLocation!.coordinate.latitude
        let longitude:CLLocationDegrees = userLocation!.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        span = MKCoordinateSpanMake(latDelta, lonDelta)
        location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let query = PFQuery(className: "Members")
        
        query.getObjectInBackgroundWithId(userId) {
            (object, error) -> Void in
            
            if error == nil {
                object?.setValue(latitude, forKey: "latitude")
                object?.setValue(longitude, forKey: "longitude")              
                object?.saveInBackground()
            } else {
               self.showAlertMsg("Location Error", errorMsg: (error?.localizedDescription)!)
            }
        }
    getusersLocations()
    }
    
    // Retrieve user locations
    func getusersLocations() {
        
        let query:PFQuery = PFQuery(className: "Members")
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            
            self.latArray = [NSNumber]()
            self.lonArray = [NSNumber]()
            self.userImageArray = [UIImage]()
            
            self.membersnameLocation = [String]()
            
            if let objects = objects {
                
                for memberObject in objects {
                    
                    let memberName: String? = (memberObject as! PFObject)["Name"] as? String
                    let photo = (memberObject as! PFObject)["photo"] as? PFFile
                    let lati = (memberObject as! PFObject)["latitude"] as? NSNumber
                    let long = (memberObject as! PFObject)["longitude"] as? NSNumber
                    
                    if lati != nil {
                    
                        self.membersnameLocation.append(memberName!)
                        self.latArray.append(lati as NSNumber!)
                        self.lonArray.append(long as NSNumber!)
                        self.memberPhotosLoc.append(photo!)
                    }
                }
            }
           self.addAnnotationsToMap()
        }
    }
    
    // Add annotations of user locations on map
    func addAnnotationsToMap(){
        
        var annotations = [CustomPointAnnotation]()
        
        for var i = 0; i < latArray.count; i++ {
            
            lat = latArray[i] as Double
            lon = lonArray[i] as Double
            let title = membersnameLocation[i]
            
            pPhoto = memberPhotosLoc[i]
            
            let latitude:CLLocationDegrees = lat
            let longitude:CLLocationDegrees = lon
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            let annotation = CustomPointAnnotation()
            annotation.coordinate = location
            annotation.title = title
            annotation.photo = pPhoto
            
            annotations.append(annotation)
        
      mapView.addAnnotations(annotations)
        
        dispatch_async(dispatch_get_main_queue()) {
            
           self.mapView.showAnnotations(annotations, animated: true)
        }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.showAlertMsg("Location Manager Error", errorMsg: error.localizedDescription)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "users"
        var annView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annView == nil {
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annView!.canShowCallout = true
        } else {
            annView!.annotation = annotation
        }
        let cpa = annotation as! CustomPointAnnotation
        let uImage: PFImageView = PFImageView(frame: CGRectMake(0, 0, 30, 30))
        uImage.file = cpa.photo
        uImage.loadInBackground()
        annView!.image = uImage.image
        return annView
    }
    
    // Show Alert Method
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        let title = errorTitle
        let errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ let alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                // No further action apart from dismissing this alert
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Logout button pressed
    @IBAction func logout(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

