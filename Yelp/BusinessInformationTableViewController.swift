//
//  BusinessInformationTableViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/24/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BusinessInformationTableViewController: UITableViewController {
  static let identifier = "BusinessInformationTableViewController"
  
  enum Icon: String {
    case Phone = "phone.png"

    var image: UIImage {
      return UIImage(named: rawValue)!
    }
  }

  var business: Yelp.Business!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60.0
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath
    indexPath: NSIndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      BusinessInformationCell.identifier,
      forIndexPath: indexPath
    ) as! BusinessInformationCell

    cell.icon.image = Icon.Phone.image
    cell.headingLabel.text = "Call"
    cell.subHeadingLabel.text = "Phone number goes here"
    print("Dequeued and initiazled cell: \(cell)")
    
    return cell
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
