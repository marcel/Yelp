//
//  MapViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  @IBOutlet weak var businessMapView: MKMapView!
  var businesses: [Yelp.Business]!
  
  @IBAction func listButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    annotateMap()
  }

  func annotateMap() {
    businesses.forEach { business in
      annotateMapWithBusiness(business)
    }

    let businessCoordinates = businesses.map {
      locationCoordinateForBusiness($0)
    }

    let midPoint = MapViewController.middlePointOfListMarkers(businessCoordinates)

//    let delta = 0.002 // 0.001 looks to be about 1 block radious
    let delta = 0.01 // 0.001 looks to be about 1 block radious
    let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    // TODO Figure out the right center amongst all the locations
     businessMapView.region = MKCoordinateRegion(center: midPoint, span: span)
  }

  func annotateMapWithBusiness(business: Yelp.Business) {
    let location = locationCoordinateForBusiness(business)
    let businessCoordinateAnnotation = MKPointAnnotation()
    businessCoordinateAnnotation.coordinate = location
    businessCoordinateAnnotation.title = business.name
    businessMapView.addAnnotation(businessCoordinateAnnotation)
  }

  func locationCoordinateForBusiness(business: Yelp.Business) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(
      latitude: business.location.coordinate.latitude,
      longitude: business.location.coordinate.longitude
    )
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  class func degreeToRadian(angle:CLLocationDegrees) -> CGFloat{

    return (  (CGFloat(angle)) / 180.0 * CGFloat(M_PI)  )

  }

  //        /** Radians to Degrees **/

  class func radianToDegree(radian:CGFloat) -> CLLocationDegrees{

    return CLLocationDegrees(  radian * CGFloat(180.0 / M_PI)  )

  }

  class func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{

    var x = 0.0 as CGFloat

    var y = 0.0 as CGFloat

    var z = 0.0 as CGFloat



    for coordinate in listCoords{

      var lat:CGFloat = degreeToRadian(coordinate.latitude)

      var lon:CGFloat = degreeToRadian(coordinate.longitude)

      x = x + cos(lat) * cos(lon)

      y = y + cos(lat) * sin(lon);

      z = z + sin(lat);

    }

    x = x/CGFloat(listCoords.count)

    y = y/CGFloat(listCoords.count)

    z = z/CGFloat(listCoords.count)



    var resultLon: CGFloat = atan2(y, x)

    var resultHyp: CGFloat = sqrt(x*x+y*y)

    var resultLat:CGFloat = atan2(z, resultHyp)



    var newLat = radianToDegree(resultLat)

    var newLon = radianToDegree(resultLon)

    var result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)

    return result

  }
}
