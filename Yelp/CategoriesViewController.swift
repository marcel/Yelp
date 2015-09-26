//
//  CategoriesViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {
//  - [0] : "Active Life"
//  - [1] : "Arts & Entertainment"
//  - [2] : "Automotive"
//  - [3] : "Beauty & Spas"
//  - [4] : "Bicycles"
//  - [5] : "Education"
//  - [6] : "Event Planning & Services"
//  - [7] : "Financial Services"
//  - [8] : "Food"
//  - [9] : "Health & Medical"
//  - [10] : "Home Services"
//  - [11] : "Hotels & Travel"
//  - [12] : "Local Flavor"
//  - [13] : "Local Services"
//  - [14] : "Mass Media"
//  - [15] : "Nightlife"
//  - [16] : "Pets"
//  - [17] : "Professional Services"
//  - [18] : "Public Services & Government"
//  - [19] : "Real Estate"
//  - [20] : "Religious Organizations"
//  - [21] : "Restaurants"
//  - [22] : "Shopping"
  let topLevelCategories = Yelp.Category.allTopLevel.sort { $0.title > $1.title }
//  - [0] : "restaurants"
//  - [1] : "active"
//  - [2] : "shopping"
//  - [3] : "homeservices"
//  - [4] : "food"
//  - [5] : "health"
//  - [6] : "localservices"
//  - [7] : "arts"
//  - [8] : "auto"
//  - [9] : "physicians"
//  - [10] : "professional"
//  - [11] : "japanese"
//  - [12] : "eventservices"
//  - [13] : "specialtyschools"
//  - [14] : "beautysvc"
//  - [15] : "hotelstravel"
//  - [16] : "fashion"
//  - [17] : "bars"
//  - [18] : "italian"
//  - [19] : "education"
//  - [20] : "homeandgarden"
//  - [21] : "nightlife"
//  - [22] : "realestate"
//  - [23] : "lawyers"
//  - [24] : "fitness"
//  - [25] : "transport"
//  - [26] : "publicservicesgovt"
//  - [27] : "chinese"
//  - [28] : "gourmet"
//  - [29] : "portuguese"
//  - [30] : "financialservices"
//  - [31] : "mexican"
//  - [32] : "media"
//  - [33] : "tours"
//  - [34] : "artsandcrafts"
//  - [35] : "dentists"
//  - [36] : "french"
//  - [37] : "religiousorgs"
//  - [38] : "german"
//  - [39] : "sportgoods"
//  - [40] : "pets"
//  - [41] : "c_and_mh"
//  - [42] : "petservices"
//  - [43] : "hotels"
//  - [44] : "brazilian"
//  - [45] : "festivals"
//  - [46] : "hair"
//  - [47] : "bicycles"
//  - [48] : "caribbean"
//  - [49] : "flowers"
//  - [50] : "musicinstrumentservices"
//  - [51] : "itservices"
//  - [52] : "medcenters"
//  - [53] : "latin"
//  - [54] : "turkish"
//  - [55] : "massmedia"
//  - [56] : "hairremoval"
//  - [57] : "parks"
//  - [58] : "mideastern"
//  - [59] : "donburi"
//  - [60] : "photographers"
//  - [61] : "tanning"
//  - [62] : "african"
//  - [63] : "diving"
//  - [64] : "dentalhygienists"
//  - [65] : "malaysian"
//  - [66] : "diagnosticservices"
//  - [67] : "polish"
//  - [68] : "belgian"
//  - [69] : "spanish"
//  - [70] : "localflavor"
//  - [71] : "nonprofit"
//  - [72] : "mediterranean"
//  - [73] : "arabian"
  let topCategoriesByChildren  = Yelp.Category.allByParent.keys.sort { (l,r) in
    Yelp.Category.allByParent[l]!.count > Yelp.Category.allByParent[r]!.count
  }.flatMap { Yelp.Category.allByAlias[$0] }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    return topCategoriesByChildren.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      CategoryCell.identifier,
      forIndexPath: indexPath
    ) as! CategoryCell

    let category = topCategoriesByChildren[indexPath.row]
    cell.nameLabel.text = category.title
    
    return cell
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Top Categories"
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
