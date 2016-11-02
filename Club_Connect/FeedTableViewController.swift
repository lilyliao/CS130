//
//  FeedTableViewController.swift
//  Club_Connect
//
//  Created by Li-Wei Tseng on 10/29/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    var events:[Event] = []
    
    override func viewDidLoad() {
        getPersonalEventFeed()
        super.viewDidLoad()
    }

    /**
        Get Personal Event Feed from Facebook Graph API
     **/
    func getPersonalEventFeed() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/events", parameters: nil)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(self.events.count)
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)

        let event = events[indexPath.row] as Event
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.rsvp_status
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
