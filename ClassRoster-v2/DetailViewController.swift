//
//  DetailViewController.swift
//  ClassRoster-v2
//
//  Created by Adrian Gherle on 8/31/14.
//  Copyright (c) 2014 Adrian Gherle. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func deletePerson(controller: DetailViewController)
    func changeRole(controller: DetailViewController)
}

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var person: Person?
    var delegate: DetailViewControllerDelegate? = nil
    var downloadImageQueue = NSOperationQueue()
    
    @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gitImageView: UIImageView!
    
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstNameTF.delegate = self
        self.lastNameTF.delegate = self
        self.usernameTF.delegate = self
        
        firstNameTF.text = person!.firstName
        lastNameTF.text = person!.lastName
        if person!.username != nil {
            self.usernameTF.text = person!.username
        }
        
        if person!.picture != nil {
            self.imageView.image = UIImage(data: person!.picture)
        }
        
        if person!.isStudent == true {
            roleLabel.text = "Student"
        } else  {
            roleLabel.text = "Teacher"
        }
        
        if person!.gitHubPicture != nil {
            self.gitImageView.image = UIImage(data: person!.gitHubPicture)
        }
        
        spinningWheel.alpha = 0
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 1
        
        gitImageView.clipsToBounds = true
        gitImageView.layer.borderColor = UIColor.blackColor().CGColor
        gitImageView.layer.borderWidth = 1
        
    }
    
    
    override func viewWillLayoutSubviews() {
        
        imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        gitImageView.layer.cornerRadius = self.imageView.frame.size.width / 2
    
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    //MARK: UITextFieldDelegate
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        // Dissmiss the keyboard when the view is touched
        self.view.endEditing(true)
    
    }
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        if textField == usernameTF {
            if usernameTF.text == "" {
                person!.username = nil
            } else {
                person!.username = usernameTF.text
                
                var alert = UIAlertController(title: nil, message: "Download GitHub profile photo?", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                    self.getGitHubImage(self.person!.username!)
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(action) -> Void in}))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        textField.resignFirstResponder()
        return true
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField!) {
        
        var message = "Name was not changed"
        var title = ""
        
        if textField == firstNameTF {
            if firstNameTF.text == "" {
                title = "First name required!"
                displayAlert(title, message: message)
                firstNameTF.text = person!.firstName
            } else {
                person!.firstName = firstNameTF.text
            }
        }
        
        if textField == lastNameTF {
            if lastNameTF.text == "" {
                title = "Last name required!"
                displayAlert(title, message: message)
                lastNameTF.text = person!.lastName
            } else {
                person!.lastName = lastNameTF.text
            }
        }
        textField.resignFirstResponder()
    }
    
    
    //MARK: Other
    
    func getGitHubImage(username: String) {
        
        self.downloadImageQueue.qualityOfService = NSQualityOfService.UserInitiated
        
        // setup URL
        var imageURL = NSURL(string: "https://api.github.com/users/" + username)

        gitImageView.alpha = 0
        self.spinningWheel.alpha = 1
        spinningWheel.startAnimating()
        
        let sesion = NSURLSession.sharedSession()
        
        let task = sesion.dataTaskWithURL(imageURL, completionHandler: {(data, response, error) -> Void in
            
            if response == nil {
                
                self.spinningWheel.stopAnimating()
                self.displayAlert("Error accessing page", message: "Please check username and try again")
                
            } else {
                
                let thisResponse = response as NSHTTPURLResponse
                var statusCode = thisResponse.statusCode as Int
                println("Status code is: \(statusCode)")
                
                if statusCode == 200 {
                    
                    var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    var avatarURL = NSURL(string: jsonDictionary["avatar_url"] as String)
                    var avatarData = NSData(contentsOfURL: avatarURL)
                    var avatarImage = UIImage(data: avatarData)
                    self.person!.gitHubPicture = avatarData
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        
                        self.gitImageView.image = avatarImage
                        self.gitImageView.alpha = 1
                        self.spinningWheel.stopAnimating()
                        self.spinningWheel.alpha = 0
                        
                    })
                    
                } else {
                    
                    self.spinningWheel.stopAnimating()
                    self.spinningWheel.alpha = 0
                    self.displayAlert("Page not found!", message: "Please check username and try again")
                
                }
                
            }
        })
        
        task.resume()
        
    }
    
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()
        
    }

    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.imageView.image = editedImage
        self.person!.picture = UIImagePNGRepresentation(editedImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
    
        picker.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    
    //MARK: Action buttons
    
    @IBAction func addPhotoBtn(sender: AnyObject) {
        
        var imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Photo Album", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action) -> Void in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func changeRoleBtn(sender: AnyObject) {
        
        if person!.isStudent {
            roleLabel.text = "Teacher"
        }else {
            roleLabel.text = "Student"
        }
        self.delegate!.changeRole(self)
    
    }
    
    
    @IBAction func deleteBtn(sender: AnyObject) {
        
        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete Person", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            if self.delegate! != nil {
                self.delegate!.deletePerson(self)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(action) -> Void in }))
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    
    @IBAction func gitImageTapped(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Enter gitHub username", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = "username"
            textField.text = self.person!.username
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            let thisTextField = alert.textFields[0] as UITextField
            let username = thisTextField.text
            
            if username != "" {
                self.person!.username = username
                self.getGitHubImage(username)
                self.usernameTF.text = username
            } else {
                self.person!.username = nil
                self.person!.gitHubPicture = nil
                println("Add code for empty username here!")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
