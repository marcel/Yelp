//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/22/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController {

  var business: Yelp.Business! {
    didSet {
      self.formatter = Yelp.Business.Formatter(business: business)
    }
  }

  enum BookmarkIcon: String {
    case Enabled  = "bookmark-enabled-30.png"
    case Disabled = "bookmark-disabled-30.png"

    var icon: UIImage {
      return UIImage(named: rawValue)!
    }
  }

  var formatter: Yelp.Business.Formatter!
  let bookmarkRepository = BookmarkRepository.sharedInstance

  let client = Yelp.Client()

  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var crossStreetAndNeighborhoodLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var businessNameLabel: UILabel!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var fullSizeImageView: UIImageView!
  @IBOutlet weak var businessNameNavigationBarItem: UINavigationItem!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!

  @IBOutlet weak var reviewView: ReviewView!
  @IBOutlet weak var reviewContainerView: UIView!

  @IBOutlet weak var bookmarkButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    businessNameNavigationBarItem.title = business.name

//    setupInformationView()

    setupReviewContainer()
    loadReviews()
    setDistance()
    setCategories()
    setReviewCount()

    setAddressInformation()
    setupRatingImageView()
    loadMap()
    setBusinessName()
    setBackgroundImage()
    setBookmarkButtonState()

//    let verticalConstraints = reviewExcerptView.constraints
      reviewView.excerptLabel.preferredMaxLayoutWidth = reviewView.bounds.width
//    reviewExcerptView.sizeToFit()
//    reviewExcerptView.setNeedsDisplay()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func setBackgroundImage() {
    let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
    let effectView = UIVisualEffectView(effect: blur)
    effectView.translatesAutoresizingMaskIntoConstraints = false
    fullSizeImageView.addSubview(effectView)

    let subViews = ["effectView": effectView]

    fullSizeImageView.addConstraints(
      NSLayoutConstraint.constraintsWithVisualFormat(
        "H:|[effectView]|",
        options: [.AlignAllLeft, .AlignAllRight],
        metrics: nil,
        views: subViews
      )
    )
    fullSizeImageView.addConstraints(
      NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|[effectView]|",
        options: [.AlignAllTop, .AlignAllBottom],
        metrics: nil,
        views: subViews
      )
    )

    if let fullSizeImageUrl = business.fullSizeImageUrl {
      print(fullSizeImageUrl.url)
      self.fullSizeImageView.setImageWithURL(fullSizeImageUrl.url)
    }
  }

  func loadReviews() {
    print("Loading reviews for business \(business.id)")
//    displayProgressIndicatorWithMessage("Loading...")

    client.reviewsForBusiness(business) { (reviews, error) in
//      self.progressIndicator.dismissAnimated(true)

      if let reviews = reviews where !reviews.isEmpty {
        UIView.animateWithDuration(
          2.0,
          delay: 0,
          options: .TransitionCrossDissolve,
          animations: {
            self.reviewView.review = reviews.first!
          }, completion: nil
        )

        for review in reviews {
          print(review.excerpt)
        }
      } else {
        print("No reviews")
//        self.displayErrorMessage("No Results")
      }
    }
  }

  @IBAction func bookmarkButtonPresed(sender: AnyObject) {
    print("bookmarkButtonPresed")
    if bookmarkRepository.isBookmarked(business) {
      bookmarkRepository.remove(business)
    } else {
      bookmarkRepository.add(business)
    }

    setBookmarkButtonState()
  }

  func setBookmarkButtonState() {
    if bookmarkRepository.isBookmarked(business) {
      bookmarkButton.image = BookmarkIcon.Enabled.icon
    } else {
      bookmarkButton.image = BookmarkIcon.Disabled.icon
    }
  }

  func setupReviewContainer() {
    // Setting alpha in IB will make text in the reviewExceptView also 
    // transparent which we don't want
    reviewContainerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)

    let layer = reviewContainerView.layer
    layer.shadowOpacity = 0.4
    layer.shadowColor   = UIColor.blackColor().CGColor
    layer.shadowOffset  = CGSizeMake(1,1)
    layer.shadowRadius  = 5
    layer.masksToBounds = false
  }

  func setAddressInformation() {
    let locationFormatter = business.location.formatter
    addressLabel.text = locationFormatter.address
    crossStreetAndNeighborhoodLabel.text = locationFormatter.crossStreetsAndNeighborhood
  }

  func setupRatingImageView() {
    ratingImageView.setImageWithURL(business.ratingImageUrl.url)

    let layer = ratingImageView.layer
    layer.shadowRadius  = 2.0
    layer.shadowOpacity = 0.3
    layer.shadowOffset  = CGSizeMake(1, 2)
    layer.masksToBounds = false
  }

  func setBusinessName() {
    businessNameLabel.text = business.name

    let layer = businessNameLabel.layer
    layer.shadowColor            = UIColor.blackColor().CGColor
    layer.shadowRadius           = 2.0
    layer.shadowOpacity          = 0.5
    layer.shadowOffset           = CGSizeMake(1, 2)
    layer.masksToBounds          = false
    layer.allowsEdgeAntialiasing = true
    layer.edgeAntialiasingMask   = [.LayerRightEdge]
  }

  func loadMap() {
    let layer = mapView.layer
    layer.shadowColor   = UIColor.blackColor().CGColor
    layer.shadowRadius  = 2.0
    layer.shadowOpacity = 0.3
    layer.shadowOffset  = CGSizeMake(1,2)
    layer.masksToBounds = false

    mapView.showsUserLocation = true
    let coordinate = business.location.coordinate
    let location = CLLocationCoordinate2D(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
    let businessCoordinateAnnotation = MKPointAnnotation()
    businessCoordinateAnnotation.coordinate = location
    businessCoordinateAnnotation.title = business.name
    mapView.addAnnotation(businessCoordinateAnnotation)

    let delta = 0.002 // 0.001 looks to be about 1 block radious
    let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    mapView.region = MKCoordinateRegion(center: location, span: span)
  }

  func setDistance() {
    distanceLabel.text = formatter.distanceInMiles
  }

  func setCategories() {
    categoriesLabel.text = formatter.categories
  }

  func setReviewCount() {
    reviewCountLabel.text = formatter.reviewCount
  }

  func setupInformationView() {
    //    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    //
    //    let businessInfoController = storyboard.instantiateViewControllerWithIdentifier(
    //      BusinessInformationTableViewController.identifier
    //    ) as! BusinessInformationTableViewController


    //    businessInfoController.business = business
    //    informationView.addSubview(businessInfoController.tableView)
  }

}
