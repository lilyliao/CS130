//
//  EventsTableViewController.swift
//  Club_Connect
//
//  Created by Li-Wei Tseng on 10/29/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
    var events:[Event] = []
    var ids:[String] = []
    var eventKinvey : KinveyEventData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let groupsRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/groups", parameters: nil)
        groupsRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                if let dict = result as? NSDictionary {
                    if let objs = dict.object(forKey: "data") as? [NSDictionary] {
                        for obj in objs {
                            let groupID = obj["id"] as! String
                            print(groupID)
                            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "\(groupID)/events", parameters: nil)
                            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                
                                if ((error) != nil) {
                                    // Process error
                                    print("Error: \(error)")
                                } else {
                                    if let dict = result as? NSDictionary {
                                        if let objs = dict.object(forKey: "data") as? [NSDictionary] {
                                            for obj in objs {
                                                let event = Event(id: obj["id"] as? String, name: obj["name"] as? String, description: obj["description"] as? String, start_time: obj["start_time"] as? String, end_time: obj["end_time"] as? String, rsvp_status: obj["rsvp_status"] as? String)
                                                self.events.append(event)
                                                print(self.events)
                                            }
                                        }
                                        
                                        self.tableView.reloadData()
                                    }
                                    
                                }
                            })

                        }
                    }
                    self.tableView.reloadData()
                }
            }
        })
        let accountsRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/accounts", parameters: nil)
        accountsRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                if let dict = result as? NSDictionary {
                    if let objs = dict.object(forKey: "data") as? [NSDictionary] {
                        for obj in objs {
                            let accountID = obj["id"] as! String
                            print(accountID)
                            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "\(accountID)/events", parameters: nil)
                            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                
                                if ((error) != nil) {
                                    // Process error
                                    print("Error: \(error)")
                                } else {
                                    if let dict = result as? NSDictionary {
                                        if let objs = dict.object(forKey: "data") as? [NSDictionary] {
                                            for obj in objs {
                                                let event = Event(id: obj["id"] as? String, name: obj["name"] as? String, description: obj["description"] as? String, start_time: obj["start_time"] as? String, end_time: obj["end_time"] as? String, rsvp_status: obj["rsvp_status"] as? String)
                                                self.events.append(event)
                                                print(self.events)
                                            }
                                        }
                                        
                                        self.tableView.reloadData()
                                    }
                                    
                                }
                            })

                        }
                    }
                    self.tableView.reloadData()
                }
            }
        })

    }

    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        let event = events[indexPath.row] as Event
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.start_time
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentEvent = events[indexPath.row] as Event
        
        eventKinvey = KinveyEventData()
        eventKinvey?.event_fb_id = currentEvent.id
        eventKinvey?.name = currentEvent.name
        eventKinvey?.attendee_id = ""
        performSegue(withIdentifier: "scanner", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "scanner") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! ViewController
            // your new view controller should have property that will store passed value
            viewController.event = self.eventKinvey
        }
    }
}
