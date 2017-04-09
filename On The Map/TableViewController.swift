//
//  TableViewController.swift
//  On The Map
//
//  Created by Chandak, Vishal on 25/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var studentList = StudentInfo.listOfStudents

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let CellReuseId = "TableCell"
        let student     = studentList[(indexPath as NSIndexPath).row]
        let cell        = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        let name        = "John Doe" as String
        cell?.textLabel!.text = "\(student.firstName!) \(student.lastName!)"
        if cell?.textLabel!.text == " " {
            cell?.textLabel!.text = name
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = studentList[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.open(URL(string: student.mediaURL!)!, options: [:]) {
            (success) in
            if !success {
                print("Not a url entry!")
            }
        }
    }
}
