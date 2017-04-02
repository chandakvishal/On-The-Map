//
//  UserLocationViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 26/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UserLocationViewController: UIViewController {

    let sharedOTMClient = OnTheMapClient.sharedInstance()
    @IBOutlet weak var mapView:             MKMapView!
    @IBOutlet weak var linkTextView:        UITextView!
    @IBOutlet weak var submitButton:        UIButton!
    @IBOutlet weak var findOnMapButton:     UIButton!
    @IBOutlet weak var locationTextView:    UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var submitView:          UIView!

    var firstName: String?
    var lastName:  String?
    var mapString: String?
    var mediaURL:  String?
    var latitude:  Double?
    var longitude: Double?
    var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSecondViewElements()
        getStudentInfo()
    }

    @IBAction func cancelLocationFinder(_ sender: Any) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController")
        present(controller, animated: true, completion: nil)
    }

    @IBAction func findOnMap(_ sender: Any) {
        if let location = locationTextView.text {
            self.mapString = location
            geocoder.geocodeAddressString(location) {
                (places, error) in

                if let placemark = places?.first {

                    self.latitude = placemark.location?.coordinate.latitude
                    self.longitude = placemark.location?.coordinate.longitude

                    let mapKitPlacemark = MKPlacemark(placemark: placemark)

                    self.mapView.addAnnotation(mapKitPlacemark)
                    self.mapView.centerCoordinate = (placemark.location?.coordinate)!

                    let coordinateSpan   = MKCoordinateSpanMake(80, 80)
                    let coordinateRegion = MKCoordinateRegion(center: (placemark.location?.coordinate)!, span: coordinateSpan)

                    self.mapView.setRegion(coordinateRegion, animated: true)

                } else {
                    self.showAlert(message: "Unable to find location: \(self.locationTextView.text)")
                }
            }

            hideFirstViewElements()
            showSecondViewElements()
        }
    }

    func getStudentInfo() {
        sharedOTMClient.getSingleStudentInformation(userId: sharedOTMClient.userId!) {
            (success, student, errorString) in
            if (success) {
                self.sharedOTMClient.ObjectId = student!.objectId
            } else {
                print("Unable to find \"objectId\" key")
            }
        }
    }

    @IBAction func onClickSubmit(_ sender: Any) {
        if let text = linkTextView.text {
            if text == "" {
                let alertController = UIAlertController(title: "Error",
                                                        message: "Please enter a valid link for posting",
                                                        preferredStyle: UIAlertControllerStyle.alert)

                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    (result: UIAlertAction) -> Void in
                    print(result)
                }

                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

            } else {
                let uniqueKey = sharedOTMClient.userId
                firstName = sharedOTMClient.firstName
                lastName = sharedOTMClient.lastName
                mediaURL = linkTextView.text
                let jsonBody = "{\"uniqueKey\": \"\(uniqueKey!)\", " +
                               "\"firstName\": \"\(firstName!)\", \"lastName\": \"\(lastName!)\"," +
                               "\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\"," +
                               "\"latitude\": \(latitude!), \"longitude\": \(longitude!)}";

                if self.sharedOTMClient.ObjectId != nil {

                    sharedOTMClient.putUserInformation(jsonBody: jsonBody) {
                        (updatedAt, errorMessage) in

                        performUIUpdatesOnMain {
                            if errorMessage == nil {

                                let controller
                                        = self.storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController")
                                self.present(controller, animated: true, completion: nil)
                            } else {
                                self.showAlert(message: errorMessage!)
                            }
                        }
                    }
                } else {

                    sharedOTMClient.postUserInformation(jsonBody: jsonBody) {
                        (success, errorMessage) in
                        performUIUpdatesOnMain {

                            if success {
                                let controller
                                        = self.storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController")
                                self.present(controller, animated: true, completion: nil)
                            } else {
                                self.showAlert(message: errorMessage!)
                            }
                        }
                    }
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func hideFirstViewElements() -> Void {
        findOnMapButton.isHidden = true
        locationTextView.isHidden = true
        descriptionTextView.isHidden = true
    }

    func hideSecondViewElements() -> Void {
        linkTextView.isHidden = true
        submitButton.isHidden = true
        mapView.isHidden = true
        submitView.isHidden = true
    }

    func showSecondViewElements() -> Void {
        linkTextView.isHidden = false
        submitButton.isHidden = false
        mapView.isHidden = false
        mapView.bringSubview(toFront: submitView)
        submitView.isHidden = false
    }
}
