//
//  Person.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/31/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit
import CoreData

@objc(Person)
class Person: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var username: String?
    @NSManaged var isStudent: Bool
    @NSManaged var picture: UIImage?
    @NSManaged var gitHubPicture: UIImage?
    
    convenience init(firstName: String, lastName: String, isStudent: Bool) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.isStudent = isStudent
    }
    
    func fullName() -> String{
        return self.lastName + " " + self.firstName
    }
}