//
//  LogInViewController.swift
//  Club_Connect
//
//  Created by Li-Wei Tseng on 10/23/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    let PROFILE_TAB_INDEX = 2
    let FEED_TAB_INDEX = 0

    var isNewUser = KCSUser.active() == nil

    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFacebook()
        setBackground()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil)
        {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        Set Background Image for Log In Page
     **/
    func setBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    /**
        Configure Facebook Graph API permissions
     **/
    func configureFacebook(){
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends", "user_events", "user_managed_groups", "pages_show_list"];
        
        btnFacebook.delegate = self
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).start { (connection, resultObject, error) -> Void in
//            
//            
//            if ((error) != nil) {
//                // Process error
//                print("Error: \(error)")
//            } else {
//                print("Log in successfully!")
//            }
//        }
        KCSUser.login(
            withSocialIdentity: .socialIDFacebook, //.socialIDTwitter, or .socialIDLinkedIn, or .socialIDSalesforce
            accessDictionary: [ KCSUserAccessTokenKey : FBSDKAccessToken.current().tokenString ]
        ) { (user, error, actionResult) in
            if let user = user {
                //the log-in was successful and the user is now the active user and credentials saved
                //hide log-in view and show main app content
                print("User: \(user)")
            }
            else if let error = error {
                //handle error
                print("Error: \(error)")
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let tabBarController = segue.destination as! UITabBarController;
        if (isNewUser) {
            tabBarController.selectedIndex = PROFILE_TAB_INDEX
        }
        else {
            tabBarController.selectedIndex = FEED_TAB_INDEX
        }
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
