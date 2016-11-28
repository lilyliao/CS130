//
//  ProfileViewController.swift
//  Club_Connect
//
//  Created by Mahir Eusufzai on 10/31/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITabBarControllerDelegate{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bruinIDTextField: UITextField!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self;
        loadExisitingValues()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: UIButton)
    {
        KCSUser.active().setValue(nameTextField.text, forAttribute: "name")
        KCSUser.active().setValue(bruinIDTextField.text, forAttribute: "UID")
        KCSUser.active().setValue(ageTextField.text, forAttribute: "age")
        KCSUser.active().setValue(majorTextField.text, forAttribute: "major")
        KCSUser.active().setValue(genderControl.titleForSegment(at: genderControl.selectedSegmentIndex), forAttribute: "gender")
        KCSUser.active().save { (error) -> Void in
            print(error)
        }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func logout(sender: UIButton)
    {
        //TO DO: replace with real logic
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.dismiss(animated: true, completion: nil);
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                                   shouldSelect viewController: UIViewController) -> Bool
    {
        if (nameTextField.text!.isEmpty || bruinIDTextField.text!.isEmpty || ageTextField.text!.isEmpty || majorTextField.text!.isEmpty) {
            presentAlert();
            return false;
        }
        else {
            return true;
        }
    }
    
    /**
      * If the user is in the database, fill with their information
     **/
    func loadExisitingValues() {
        if let name = KCSUser.active().getValueForAttribute("name")
        {
            nameTextField.text = name as! String
        }
        if let bruinID = KCSUser.active().getValueForAttribute("UID")
        {
            bruinIDTextField.text = bruinID as! String
        }
        if let age = KCSUser.active().getValueForAttribute("age")
        {
            ageTextField.text = age as! String
        }
        if let major = KCSUser.active().getValueForAttribute("major")  {
            majorTextField.text = major as! String
        }
        if let gender = KCSUser.active().getValueForAttribute("gender"){
            if (gender as! String == "Male") {
                genderControl.selectedSegmentIndex = 0;
            }
            else {
                genderControl.selectedSegmentIndex = 1;
            }
        }
    }
    
    
    /**
     * Present alert when users didn't fill out information
     **/
    func presentAlert()
    {
        let alertController = UIAlertController(title: "Incomplete Profile", message: "Please fill out all fields.", preferredStyle: UIAlertControllerStyle.alert)
  
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
