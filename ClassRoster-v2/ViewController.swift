//
//  ViewController.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/26/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit
import CoreData

class ViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate, AddNewViewControllerDelegate {
    
    let numberOfSections = 2
    var students = [Person]()
    var teachers = [Person]()

    
    @IBOutlet weak var tableView: UITableView!
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.initializeArrays()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        self.students.sort {$0.lastName < $1.lastName}
        self.teachers.sort {$0.lastName < $1.lastName}
        self.tableView.reloadData()
        self.saveData()
    
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableView

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
    
    
    //MARK: DetailViewControllerDelegate
    
    func deletePerson(controller: DetailViewController) {
        
        var context : NSManagedObjectContext = getContext()
        let thisPerson: Person = controller.person!
        context.deleteObject(thisPerson)
        
        deletePersonFromArray(thisPerson)
        context.save(nil)
        controller.navigationController.popToRootViewControllerAnimated(true)
        
    }
    
    
    func changeRole(controller: DetailViewController) {
        
        var context : NSManagedObjectContext = getContext()
        var thisPerson: Person = controller.person!
        
        deletePersonFromArray(thisPerson)
        if thisPerson.isStudent {
            thisPerson.isStudent = false
        } else {
            thisPerson.isStudent = true
        }
        addNewPersonToArray(thisPerson)
        
        context.save(nil)
    
    }
    
    
    func addNewPersonToArray(newPerson: Person) {
        
        var flag = false
        
        if newPerson.isStudent {
            for i in 0..<self.students.count {
                if newPerson.lastName < students[i].lastName {
                    students.insert(newPerson, atIndex: i)
                    flag = true
                    break
                }
            }
            if !flag {
                students.append(newPerson)
            }
            
        } else {     // newPerson is teacher
            
            for i in 0..<self.teachers.count {
                if newPerson.lastName < teachers[i].lastName {
                    teachers.insert(newPerson, atIndex: i)
                    flag = true
                    break
                }
            }
            if !flag {
                teachers.append(newPerson)
            }
        }
        tableView.reloadData()
        
    }
    
    
    func deletePersonFromArray(thisPerson: Person){
        
        if thisPerson.isStudent {         // remove from students array
            for i in 0..<self.students.count {
                if self.students[i].lastName == thisPerson.lastName {
                    self.students.removeAtIndex(i)
                    break
                }
            }
            
        } else {                         // remove from teachers array
            for i in 0..<self.teachers.count {
                if (self.teachers[i].lastName == thisPerson.lastName) {
                    self.teachers.removeAtIndex(i)
                    break
                }
            }
        }
    
    }
    
    
    //MARK: AddNewViewControllerDelegate
    
    func saveNewPerson(controller: AddNewViewController) {
        
        var context = getContext()
        var newPerson = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context) as Person
        
        newPerson.firstName = controller.firstName!
        newPerson.lastName = controller.lastName!
        newPerson.isStudent = controller.role
        // add rest of properties here
        
        context.save(nil)
        addNewPersonToArray(newPerson)
        controller.navigationController.popViewControllerAnimated(true)
        
    }
    
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        if segue.identifier == "detailSegue" {
            let destination = segue.destinationViewController as DetailViewController
            if tableView.indexPathForSelectedRow().section == 0 {
                destination.person = self.teachers[tableView.indexPathForSelectedRow().row]
            } else {
                destination.person = self.students[tableView.indexPathForSelectedRow().row]
            }
            destination.delegate = self
        }
        
        if segue.identifier == "addNewSegue" {
            let destination = segue.destinationViewController as AddNewViewController
            destination.delegate = self
        }
        
    }


    //MARK: CoreData
    
    func getContext() -> NSManagedObjectContext {
        
        let appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context : NSManagedObjectContext = appDel.managedObjectContext!
        return context
    
    }
    
    //MARK: Initialize Arrays
    
    func initializeArrays() {
        
        var context : NSManagedObjectContext = getContext()
        var request = NSFetchRequest(entityName: "People")
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
        
    }
    
    
    func populateArraysFromBackup() {
        
        var context: NSManagedObjectContext = getContext()
        
        if self.students.isEmpty {
            for (lastName, firstName) in studentNames {
                var person: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context)
                
                person.setValue(firstName, forKey: "firstName")
                person.setValue(lastName, forKey: "lastName")
                person.setValue(true, forKey: "isStudent")
            }
        }
        
        if self.teachers.isEmpty {
            for (lastName, firstName) in teacherNames {
                var person: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("People", inManagedObjectContext: context)
                
                person.setValue(firstName, forKey: "firstName")
                person.setValue(lastName, forKey: "lastName")
                person.setValue(false, forKey: "isStudent")
            }
        }
        saveData()
        initializeArrays()
        
    }
    
    func saveData(){
        
        getContext().save(nil)
    
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
    
}

