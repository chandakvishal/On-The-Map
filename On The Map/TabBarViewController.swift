//
//  TabBarViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 25/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {


    var firstName: String?
    var lastName:  String?
    var sharedInstance = OnTheMapClient.sharedInstance()

    @IBOutlet weak var userInfoOutlet: UIBarButtonItem!
    @IBOutlet weak var reloadOutlet:   UIBarButtonItem!
    @IBOutlet weak var logoutOutlet:   UIBarButtonItem!

    @IBAction func logout(_ sender: Any) {
        setUIEnabled(false)
        sharedInstance.logoutHandler(self) {
            (success, errorString) in
            self.sharedInstance.performUIUpdatesOnMain {
                if success {
                    self.completeLogout()
                } else {
                    self.setUIEnabled(true)
                    self.showRetryAlert(title: "Network Problem",
                                        message: "Unable to logout.",
                                        option1: "Retry",
                                        option2: "Cancel") {
                        self.logout(sender)
                    }
                }
            }
        }
    }

    // MARK: Change View to Maps

    private func completeLogout() {
        print("Logout Completed successfully!")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func reloadButton(_ sender: Any) {
        loadStudentLocations()
    }

    @IBAction func postUserInformation(_ sender: Any) {

        if (sharedInstance.firstName == nil && sharedInstance.lastName == nil) {

            sharedInstance.getUserInformation(userId: sharedInstance.userId!) {
                (success, firstName, lastName, errorString) in
                self.sharedInstance.performUIUpdatesOnMain {
                    if success {
                        self.sharedInstance.firstName = firstName
                        self.sharedInstance.lastName = lastName
                    } else {
                        print(errorString!)
                    }
                }
            }
        }

        // TODO: Also check if the student already has an address, then update it


        let controller = storyboard!.instantiateViewController(withIdentifier: "UserLocationViewController")
        present(controller, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadStudentLocations()
    }

    func loadStudentLocations() {

        // studentLocations is an array of dictionaries
        sharedInstance.studentLocationFinder() {
            (success, studentInfoArray, error) in

            self.sharedInstance.performUIUpdatesOnMain {

                if success {
                    if let mapVC = self.viewControllers?[0] as? MapViewController {
                        StudentInfo.listOfStudents = studentInfoArray!
                        mapVC.loadStudents(studentInfo: studentInfoArray!)
                    }
                    if let tableVC = self.viewControllers?[1] as? TableViewController {
                        tableVC.studentList = studentInfoArray!
                    }
                } else {
                    self.showRetryAlert(title: "Network Problem",
                                        message: "Unable to download location data from server.",
                                        option1: "Retry",
                                        option2: "Cancel") {
                        self.loadStudentLocations()
                    }
                }
            }
        }
    }

    func showRetryAlert(title: String, message: String, option1: String, option2: String, retryFunction: @escaping () -> Void) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: option1, style: UIAlertActionStyle.destructive) {
            (result: UIAlertAction) -> Void in
            retryFunction()
        }

        let okAction = UIAlertAction(title: option2, style: UIAlertActionStyle.default) {
            (result: UIAlertAction) -> Void in
            print(option2)
        }

        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


    func setUIEnabled(_ enabled: Bool) {
        view.alpha = 0.5;
        userInfoOutlet.isEnabled = enabled
        reloadOutlet.isEnabled = enabled
        logoutOutlet.isEnabled = enabled
    }
}
