//
//  AddNewViewController.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/27/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit

protocol AddNewViewControllerDelegate {
    func saveNewPerson(controller : AddNewViewController)
}
class AddNewViewController: UIViewController, UITextFieldDelegate {
    var firstName: String?
    var lastName: String?
    var role: Bool = true
    var delegate: AddNewViewControllerDelegate? = nil
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gitImageView: UIImageView!
    
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBAction func roleBtn(sender: AnyObject) {
        if roleLabel.text == "Student" {
            role = false
            roleLabel.text = "Teacher"
        } else {
            roleLabel.text = "Student"
            role = true
        }
    }
    
    
    @IBAction func saveAction(sender: AnyObject) {
        if delegate! != nil {
            if validateName() {
                firstName = firstNameTF.text
                lastName = lastNameTF.text
                delegate!.saveNewPerson(self)
            } else {
//                requiredLabel.text = "Must complete all required fields"
//                requiredLabel.textColor = UIColor.redColor()
            }
        }
    }
    
    func validateName() -> Bool {
        if firstNameTF.text == "" {
            return false
        } else {
            return true
        }
    }
    
    @IBAction func addPhotoBtn(sender: AnyObject) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstNameTF.delegate = self
        self.lastNameTF.delegate = self
        
        roleLabel.text = "Student"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
