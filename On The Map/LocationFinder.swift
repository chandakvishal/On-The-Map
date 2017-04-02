//
//  LocationFinder.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation

extension OnTheMapClient {

    func studentLocationFinder(completionHandlerForLocation: @escaping (_ success: Bool,
                                                                        _ locationData: [StudentInfo]?,
                                                                        _ errorString: String?) -> Void) -> Void {

        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */

        //No parameters in this case, thus sending an empty objecyt
        var parameters = [String: AnyObject]()
        parameters[Parse.NumberOfStudents] = 100 as AnyObject?
        parameters[Parse.Order] = "-updatedAt" as AnyObject?

        /* 2. Make the request */
        let _ = taskForParseGETMethod(Parse.StudentLocationPath,
                                      parameters: parameters) {
            (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForLocation(false, nil, "Unable to get Location")
            } else {

                /* GUARD: Was there any data returned? */
                guard let parsedResult = results as! [String: AnyObject]? else {
                    completionHandlerForLocation(false, nil, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "results" key in parsedResult? */
                guard let locationDict = parsedResult[Parse.LocationResults] as? [[String: AnyObject]] else {
                    completionHandlerForLocation(false, nil, "Cannot find key '\(Parse.LocationResults)' in \(parsedResult)")
                    return
                }

                var studentList = [StudentInfo]()

                // Convert each student dictionary (parsed JSON) to a StudentInfo struct.
                for student in locationDict {
                    let studentStruct = StudentInfo(dictionary: student)
                    studentList.append(studentStruct)
                }

                completionHandlerForLocation(true, studentList, nil)
            }
        }
    }
}
