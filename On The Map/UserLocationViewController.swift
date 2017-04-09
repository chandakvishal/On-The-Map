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

class UserLocationViewController: UIViewController, UITextFieldDelegate {

    let sharedOTMClient = OnTheMapClient.sharedInstance()

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var findOnMapButton:     UIButton!
    @IBOutlet weak var locationTextView:    UITextField!

    var firstName: String?
    var lastName:  String?
    var geocoder = CLGeocoder()
    var keyboardUtils: KeyboardUtils!


    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        keyboardUtils = KeyboardUtils(view: view, bottomTextField: locationTextView)
        keyboardUtils.subscribeToKeyboardNotifications()
        keyboardUtils.subscribeToKeyboardHideNotifications()
    }

    @IBAction func cancelLocationFinder(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findOnMap(_ sender: Any) {
        if let location = locationTextView.text {
            
             let controller = self.storyboard!.instantiateViewController(withIdentifier: "UserPinViewController") as! UserPinViewController
            
            geocoder.geocodeAddressString(location) {
                (places, error) in

                if (places?.first) != nil {
                    controller.mapString = location
                    self.present(controller, animated: true, completion: nil)
                } else {
                    self.showAlert(message: "Unable to find location: \(self.locationTextView.text!)")
                }
            }
        }
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
