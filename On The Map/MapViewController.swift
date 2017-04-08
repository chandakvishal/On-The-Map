//
//  FirstViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 18/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import UIKit
import MapKit

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    var previousStudentAnnotations: [MKPointAnnotation]?

    func loadStudents(studentInfo: [StudentInfo]) {

        var annotations = [MKPointAnnotation]()

        for student in studentInfo {

            if student.latitude == nil || student.longitude == nil {
                continue
            }

            let lat        = CLLocationDegrees(student.latitude!)
            let long       = CLLocationDegrees(student.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            if let firstName = student.firstName,
               let lastName = student.lastName,
               let mediaURL = student.mediaURL {


                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL

                annotations.append(annotation)
            }
        }
        if let previousStudentAnnotations = previousStudentAnnotations {
            mapView.removeAnnotations(previousStudentAnnotations)
        }
        previousStudentAnnotations = annotations
        mapView.addAnnotations(annotations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                UIApplication.shared.open(URL(string: toOpen)!, options: [:]) {
                    (success) in
                    if !success {
                        print("Not a url entry!")
                    }
                }
            }
        }
    }
}

