//
//  MapViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BusinessesTableViewController, MKMapViewDelegate {

  @IBOutlet weak var businessMapView: MKMapView!

  var pointAnnotations: [MKPointAnnotation]!
  
  @IBAction func listButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    styleMap()

    self.pointAnnotations = businesses.map {
      pointAnnotationForBusiness($0)
    }

    annotateMap()
  }

  func styleMap() {
    let layer = businessMapView.layer
    layer.cornerRadius  = 6.0
  }

  func annotateMap() {
    pointAnnotations.forEach { annotation in
      businessMapView.addAnnotation(annotation)
    }

    zoomMapViewToFitAnnotations(pointAnnotations)
  }

  func pointAnnotationForBusiness(business: Yelp.Business) -> MKPointAnnotation {
    let location = locationCoordinateForBusiness(business)

    let businessPointAnnotation        = MKPointAnnotation()
    businessPointAnnotation.coordinate = location
    businessPointAnnotation.title      = business.name
    businessPointAnnotation.subtitle   = business.formatter.address

    return businessPointAnnotation
  }

  func locationCoordinateForBusiness(business: Yelp.Business) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(
      latitude: business.location.coordinate.latitude,
      longitude: business.location.coordinate.longitude
    )
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func zoomMapViewToFitAnnotations(annotations: [MKPointAnnotation]) {
    guard !annotations.isEmpty else {
      return
    }

    let annotationRegionPadFactor = 1.25

    let minimumZoomArc = 0.002 // 0.001 looks to be about 1 block radious (1 degree of arc ~= 69 miles)
    let maxDegreesArc  = 360.0

    let mapPoints = annotations.map { MKMapPointForCoordinate($0.coordinate) }
    let mapRect = MKPolygon(points: UnsafeMutablePointer(mapPoints), count: mapPoints.count).boundingMapRect
    var region = MKCoordinateRegionForMapRect(mapRect)

    // If there is only 1 point we want the max zoom-in instead of max zoom-out
    if annotations.count == 1 {
      region.span.latitudeDelta  = minimumZoomArc
      region.span.longitudeDelta = minimumZoomArc
    } else {
      // Padding so pins aren't scrunched on the edges
      // ...but padding can't be bigger than the world
      region.span.latitudeDelta  = min(maxDegreesArc, region.span.latitudeDelta  * annotationRegionPadFactor)
      region.span.longitudeDelta = min(maxDegreesArc, region.span.longitudeDelta * annotationRegionPadFactor)

      // ...and don't zoom in stupid-close on small samples
      region.span.latitudeDelta  = max(minimumZoomArc, region.span.latitudeDelta)
      region.span.longitudeDelta = max(minimumZoomArc, region.span.longitudeDelta)
    }

    businessMapView.setRegion(region, animated: true)
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let annotationForRow = pointAnnotations[indexPath.row]

    let alreadySelected = businessMapView.selectedAnnotations.reduce(false) { (didFindAnnotation, annotation) in
      return (didFindAnnotation || annotation.isEqual(annotationForRow))
    }

    if alreadySelected {
      businessMapView.deselectAnnotation(annotationForRow, animated: true)
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    } else {
      businessMapView.selectAnnotation(annotationForRow, animated: true)
    }
  }

  // MARK: - MKMapViewDelegate

  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
    annotationView.annotation = annotation
    annotationView.canShowCallout = true
//    annotationView.animatesDrop = true


    annotationView.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)

    return annotationView
  }

  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let annotationIndex = pointAnnotations.indexOf(view.annotation as! MKPointAnnotation)!
    let business = businesses[annotationIndex]

    print("Callout tapped \(view) \(control) \(business)")
    performSegueWithIdentifier("DetailView", sender: business)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let business = sender as! Yelp.Business
    let detailViewController = segue.destinationViewController as! BusinessDetailViewController
    detailViewController.business = business
  }
}
