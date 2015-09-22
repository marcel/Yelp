//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BusinessesViewController: UITableViewController {

  var businesses: [Yelp.Business] = [] {
    didSet {
      reloadData()
    }
  }
    override func viewDidLoad() {
      super.viewDidLoad()
      prepareTableView()

      let client = Yelp.Client()
      client.searchWithTerm("Restaurants", sort: .Distance, categories: ["thai"], deals: false) { (businesses: [Yelp.Business]!, error: NSError!) -> Void in
        self.businesses = businesses

        for business in businesses {
          print(business.name)
        }
      }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  func reloadData() {
    tableView.reloadData()
  }

  func prepareTableView() {
    tableView.rowHeight          = UITableViewAutomaticDimension
    tableView.separatorInset     = UIEdgeInsetsZero
    tableView.layoutMargins      = UIEdgeInsetsZero
    tableView.estimatedRowHeight = 120
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return businesses.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(
      BusinessCell.identifier,
      forIndexPath: indexPath
    ) as! BusinessCell
    cell.separatorInset = UIEdgeInsetsZero
    
    cell.result = (indexPath.row + 1, businessAtIndexPath(indexPath))
    
    return cell
  }

  func businessAtIndexPath(indexPath: NSIndexPath) -> Yelp.Business {
    return businesses[indexPath.row]
  }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
