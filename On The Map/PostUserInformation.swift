//
// Created by Chandak, Vishal on 26/03/17.
// Copyright (c) 2017 Chandak, Vishal. All rights reserved.
//

import Foundation
import UIKit

extension OnTheMapClient {

    func getUserInformation(userId: String, getUserCompletionHandler: @escaping (_ success: Bool,
                                                                                 _ firstName: String?,
                                                                                 _ lastName: String?,
                                                                                 _ errorString: String?) -> Void) -> Void {

        //No parameters in this case, thus sending an empty object
        let parameters = [String: AnyObject]()

        let _ = taskForUdacityGETMethod("\(Udacity.UserInfoPath)\(userId)", parameters: parameters) {
            (result, error) in
            if error != nil {
                getUserCompletionHandler(false, nil, nil, "Unable to get user information from the Server")
            } else {

                guard let parsedResult = result as! [String: AnyObject]? else {
                    getUserCompletionHandler(false, nil, nil, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "user" key in parsedResult? */
                guard let user = parsedResult[Udacity.JsonResponseKeys.Users] as? [String: AnyObject] else {
                    getUserCompletionHandler(false, nil, nil, "Cannot find key '\(Udacity.JsonResponseKeys.Users)' in \(parsedResult)")
                    return
                }

                guard let firstName = user[Udacity.JsonResponseKeys.FirstName] as? String else {
                    getUserCompletionHandler(false, nil, nil, "Cannot find key '\(Udacity.JsonResponseKeys.FirstName)' in \(parsedResult)")
                    return
                }

                guard let lastName = user[Udacity.JsonResponseKeys.LastName] as? String else {
                    getUserCompletionHandler(false, nil, nil, "Cannot find key '\(Udacity.JsonResponseKeys.LastName)' in \(parsedResult)")
                    return
                }
                getUserCompletionHandler(true, firstName, lastName, nil)
            }
        }
    }

    func getSingleStudentInformation(userId: String, getUserCompletionHandler: @escaping (_ success: Bool,
                                                                                          _ studentInfo: StudentInfo?,
                                                                                          _ errorString: String?) -> Void) -> Void {

        let parameter = "where=%7B%22\(Parse.UniqueKey)%22%3A%22\(OnTheMapClient.sharedInstance().userId!)%22%7D"

        let _ = taskForParseGETMethodWithEncoding(Parse.StudentLocationPath, parameters: parameter) {
            (result, error) in
            if error != nil {
                getUserCompletionHandler(false, nil, "Unable to get user information from the Server")
            } else {

                guard let parsedResult = result as! [String: AnyObject]? else {
                    getUserCompletionHandler(false, nil, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "results" key in parsedResult? */
                guard let studentInfo = parsedResult[Parse.LocationResults] as? [[String: AnyObject]] else {
                    getUserCompletionHandler(false, nil, "Cannot find key '\(Parse.LocationResults)' in \(parsedResult)")
                    return
                }

                let student = StudentInfo.init(dictionary: studentInfo[0])
                print("Student Dict: \(studentInfo[0])")
                getUserCompletionHandler(true, student, nil)
            }
        }
    }

    func postUserInformation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String,
                             latitude: Double, longitude: Double,
                             completionHandlerForPost: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //No parameters in this case, thus sending an empty object
        let parameters = [String: AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", " +
            "\"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\"," +
            "\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\"," +
        "\"latitude\": \(latitude), \"longitude\": \(longitude)}";

        /* 2. Make the request */
        let _ = taskForParsePOSTMethod(Parse.StudentLocationPath,
                                       parameters: parameters,
                                       jsonBody: jsonBody) {
            (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForPost(false, "Failed to post location!")
            } else {

                /* GUARD: Was there any data returned? */
                guard let parsedResult = results as! [String: AnyObject]? else {
                    completionHandlerForPost(false, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "createdAt" key in parsedResult? */
                guard let createdAt = parsedResult[Parse.CreatedAt] as? String else {
                    completionHandlerForPost(false, "Cannot find key '\(Parse.CreatedAt)' in \(parsedResult)")
                    return
                }

                /* GUARD: Is the "objectId" key in parsedResult? */
                guard let objectId = parsedResult[Parse.ObjectId] as? String else {
                    completionHandlerForPost(false, "Cannot find key '\(Parse.ObjectId)' in \(parsedResult)")
                    return
                }

                print("Posted User info at \(createdAt) with objectId \(objectId)")
                OnTheMapClient.sharedInstance().ObjectId = objectId
                completionHandlerForPost(true, nil)
            }
        }
    }

    func putUserInformation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String,
                            latitude: Double, longitude: Double,
                            completionHandlerForPost: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //No parameters in this case, thus sending an empty object
        let parameters = [String: AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", " +
            "\"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\"," +
            "\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\"," +
        "\"latitude\": \(latitude), \"longitude\": \(longitude)}";

        /* 2. Make the request */
        let _ = taskForPutMethod("\(Parse.StudentLocationPath)/\(OnTheMapClient.sharedInstance().ObjectId!)",
                                 parameters: parameters,
                                 jsonBody: jsonBody) {
            (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForPost(false, "Failed to post location!")
            } else {

                /* GUARD: Was there any data returned? */
                guard let parsedResult = results as! [String: AnyObject]? else {
                    completionHandlerForPost(false, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "createdAt" key in parsedResult? */
                guard let updatedAt = parsedResult[Parse.UpdatedAt] as? String else {
                    completionHandlerForPost(false, "Cannot find key '\(Parse.UpdatedAt)' in \(parsedResult)")
                    return
                }

                print("Posted User info updated at \(updatedAt)")

                completionHandlerForPost(true, nil)
            }
        }
    }
}
