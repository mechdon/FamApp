//
//  Person.swift
//  FamChat
//
//  Created by Gerard Heng on 15/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

// 1. Import CoreData
import CoreData

// 2. Make Person available to Objective-C code
@objc(Person)

// 3. Make Person a subclass of NSManagedObject
class Person : NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Image = "image"
    }
    
    // 4. We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var name: String?
    @NSManaged var image: UIImage?
    @NSManaged var pin: [Pin]
    @NSManaged var person: [Person]
    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * 6. The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Person into a Core Data Managed Object Context
    *  - initialze the Person's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        name = dictionary[Keys.Name] as? String
        image = dictionary[Keys.Image] as? UIImage

    }
    
}



