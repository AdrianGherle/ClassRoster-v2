//
//  ViewController.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/26/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit
import CoreData

class ViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let numberOfSections = 2
    var students = [Person]()
    var teachers = [Person]()

    
    @IBOutlet weak var tableView: UITableView!
    // setup array with NSManagedObject
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        initializeArrays()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.students.sort {$0.lastName < $1.lastName}
        self.teachers.sort {$0.lastName < $1.lastName}
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return numberOfSections
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.teachers.count
        } else {
            return self.students.count
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var personForRow : Person
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell!
        if indexPath.section == 0 {
            personForRow = self.teachers[indexPath.row]
        } else {
            personForRow = self.students[indexPath.row]
        }
        cell.textLabel.text = personForRow.fullName()
        return cell
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        if section == 0 {
            return "Teachers"
        } else {
            return "Students"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "detailSegue" {
            let destination = segue.destinationViewController as DetailViewController
            if tableView.indexPathForSelectedRow().section == 0 {
                destination.person = self.teachers[tableView.indexPathForSelectedRow().row]
            } else {
                destination.person = self.students[tableView.indexPathForSelectedRow().row]
            }
            /////////////////////////
            // might have to add a delegate to DetailViewController here
//            destination.delegate = self
        }
        
    }
   
    // Initial setup of people in array
    // Hold the student names => last : first
    var studentNames = ["Birkholz": "Nate", "Brightbill": "Matthew", "Chavez": "Jeff", "Ferderer": "Chrstie",
        "Fry": "David", "Gherle": "Adrian", "Hawken": "Jake", "Kazi": "Shams", "Klein": "Cameron",
        "Kolodziejczak": "Kori", "Lewis": "Parker", "Ma": "Nathan", "MacPhee": "Casey", "McAleer": "Brendan", "Mendez": "Brian",
        "Morris": "Mark", "North": "Rowan", "Pham": "Kevin", "Richman": "Will", "Thueringer": "Heather", "Vu": "Tuan",
        "Walkingstick": "Zack", "Wong": "Sara", "Zhang": "Hongyao"]
    
    // Hold the teacher names
    var teacherNames = ["Clem": "John", "Johnson": "Brad"]

    //MARK: CoreData
    
    func getContext() -> NSManagedObjectContext {
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext!
        return context
    }
    
    func initializeArrays() {
        var context : NSManagedObjectContext = getContext()
        let request = NSFetchRequest(entityName: "People")
        request.returnsObjectsAsFaults = false
        
        
        
        request.predicate = NSPredicate(format: "isStudent == %@", true)
        self.students = context.executeFetchRequest(request, error: nil) as [Person]
        self.students.sort{$0.lastName < $1.lastName}
        
        request.predicate = NSPredicate(format: "isStudent == %@", false)
        self.teachers = context.executeFetchRequest(request, error: nil) as [Person]
        self.teachers.sort {$0.lastName < $1.lastName}
        
        // first run of the app populate with initial data
        if self.students.isEmpty {
            populateArraysFromBackup()
        }
        
//        println(context.accessibilityElements.count)
//        if context.accessibilityElements.count == 0 {
//            /////////////// remove //////////////
//            println("no people in entity")
//            /////////////////////////
//            
//            for (lastName, firstName) in studentNames {
//                self.students.append(Person(firstName: firstName, lastName: lastName, isStudent: true))
//            }
//            for (lastName, firstName) in teacherNames {
//                self.teachers.append(Person(firstName: firstName, lastName: lastName, isStudent: false))
//            }
//        }
    }
    
    func populateArraysFromBackup() {
        
        var context: NSManagedObjectContext = getContext()
        
        
        if self.students.isEmpty {
            for (lastName, firstName) in studentNames {
                var person: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context)
                
//                self.students.append(Person(firstName: firstName, lastName: lastName, isStudent: true))
                person.setValue(firstName, forKey: "firstName")
                person.setValue(lastName, forKey: "lastName")
                person.setValue(true, forKey: "isStudent")
            }
        }
        
        if self.teachers.isEmpty {
            for (lastName, firstName) in teacherNames {
                var person: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context)
                
//                self.teachers.append(Person(firstName: firstName, lastName: lastName, isStudent: false))
                person.setValue(firstName, forKey: "firstName")
                person.setValue(lastName, forKey: "lastName")
                person.setValue(false, forKey: "isStudent")
            }
        }
        saveData()
        initializeArrays()
    }
    
    func saveData(){
        if getContext().save(nil){
            println("Saved data for first time !!!")
        }
    }
    
    
    
    
}

