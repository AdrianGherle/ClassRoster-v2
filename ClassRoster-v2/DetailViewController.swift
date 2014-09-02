//
//  DetailViewController.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/31/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var person: Person?
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var usernameTF: UITextField!
    
    
    @IBAction func changeRoleBtn(sender: AnyObject) {
        if person!.isStudent {
            person!.isStudent = false
            roleLabel.text = "Teacher"
        }else {
            person!.isStudent = true
            roleLabel.text = "Student"
        }
    }
    
    @IBAction func addPhotoBtn(sender: AnyObject) {
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
