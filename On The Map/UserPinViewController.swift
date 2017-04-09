//
//  UserPinViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 08/04/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UserPinViewController: UIViewController, UITextFieldDelegate {

    let sharedOTMClient = OnTheMapClient.sharedInstance()

    @IBOutlet weak var linkTextView: UITextField!
    @IBOutlet weak var mapView:      MKMapView!
    @IBOutlet weak var submitButton: UIButton!

    var mapString: String?
    var mediaURL:  String?
    var firstName: String?
    var lastName:  String?
    var latitude:  Double?
    var longitude: Double?
    var geocoder = CLGeocoder()

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true;
        showPinOnMap()
        getStudentInfo()
        linkTextView.delegate = self;
    }

    @IBAction func cancelButton(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func showPinOnMap() {

        geocoder.geocodeAddressString(mapString!) {
            (places, error) in

            let placemark = places!.first!

            self.latitude = placemark.location?.coordinate.latitude
            self.longitude = placemark.location?.coordinate.longitude

            let mapKitPlacemark = MKPlacemark(placemark: placemark)

            self.mapView.addAnnotation(mapKitPlacemark)
            self.mapView.centerCoordinate = (placemark.location?.coordinate)!

            let coordinateSpan   = MKCoordinateSpanMake(80, 80)
            let coordinateRegion = MKCoordinateRegion(center: (placemark.location?.coordinate)!, span: coordinateSpan)

            self.mapView.setRegion(coordinateRegion, animated: true)
            self.activityIndicatorView.stopAnimating()
        }
    }

    func getStudentInfo() {
        sharedOTMClient.getSingleStudentInformation(userId: sharedOTMClient.userId!) {
            (success, student, errorString) in
            if (success) {
                self.sharedOTMClient.ObjectId = student!.objectId
            } else {
                // This just gets the objectId of the student if a location is already posted
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
                present(alertController, animated: true, completion: nil)

            } else {
                let uniqueKey = sharedOTMClient.userId
                firstName = sharedOTMClient.firstName
                lastName = sharedOTMClient.lastName
                mediaURL = linkTextView.text

                if self.sharedOTMClient.ObjectId != nil {

                    sharedOTMClient.putUserInformation(uniqueKey: uniqueKey!, firstName: firstName!,
                                                       lastName: lastName!, mapString: mapString!,
                                                       mediaURL: mediaURL!, latitude: latitude!, longitude: longitude!) {
                        (updatedAt, errorMessage) in

                        self.sharedOTMClient.performUIUpdatesOnMain {
                            if errorMessage == nil {
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            } else {
                                self.showAlert(message: errorMessage!)
                            }
                        }
                    }
                } else {

                    sharedOTMClient.postUserInformation(uniqueKey: uniqueKey!, firstName: firstName!,
                                                        lastName: lastName!, mapString: mapString!,
                                                        mediaURL: mediaURL!, latitude: latitude!, longitude: longitude!) {
                        (success, errorMessage) in
                        self.sharedOTMClient.performUIUpdatesOnMain {

                            if success {
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            } else {
                                self.showAlert(message: errorMessage!)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension UserPinViewController {

    override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.portrait ||
            UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown ||
            UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return true
        } else {
            return false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask
                = [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
        return orientation
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
