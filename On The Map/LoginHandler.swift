//
//  LoginHandler.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension OnTheMapClient {

    // MARK: Login Handler

    func loginHandler(_ hostViewController: UIViewController,
                      username: String,
                      password: String,
                      completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        getUdacityAccess(username: username, password: password) {
            (success, sessionKey, userIdentifierKey, errorString) in
            if (success) {
                self.userId = userIdentifierKey
                self.sessionID = sessionKey
            }
            completionHandlerForAuth(success, errorString)
        }
    }

    private func getUdacityAccess(username: String,
                                  password: String,
                                  _ completionHandlerForLogin: @escaping (_ success: Bool,
                                                                          _ sessionId: String?,
                                                                          _ userIdentifierKey: String?,
                                                                          _ errorString: String?) -> Void) {

        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */

        //No parameters in this case, thus sending an empty object
        let parameters = [String: AnyObject]()

        //Json consists of a dictionary containing username & password
        let jsonBody   = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"

        /* 2. Make the request */
        let _ = taskForUdacityPOSTMethod(Udacity.SessionPath,
                                         parameters: parameters,
                                         jsonBody: jsonBody) {
            (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForLogin(false, nil, nil, "Login Failed!")
            } else {

                /* GUARD: Was there any data returned? */
                guard let parsedResult = results as! [String: AnyObject]? else {
                    completionHandlerForLogin(false, nil, nil, "No data was returned by the request!")
                    return
                }

                /* GUARD: Is the "session" key in parsedResult? */
                guard let session = parsedResult[Udacity.Session] as? [String: AnyObject] else {
                    completionHandlerForLogin(false, nil, nil, "Cannot find key '\(Udacity.Session)' in \(parsedResult)")
                    return
                }

                /* GUARD: Is the "session:Id" key in parsedResult? */
                guard let sessionKey = session[Udacity.SessionId] as? String else {
                    completionHandlerForLogin(false, nil, nil, "Cannot find key '\(Udacity.SessionId)' in \(parsedResult)")
                    return
                }

                /* GUARD: Is the "account" key in parsedResult? */
                guard let account = parsedResult[Udacity.Account] as? [String: AnyObject] else {
                    completionHandlerForLogin(false, nil, nil, "Cannot find key '\(Udacity.Account)' in \(parsedResult)")
                    return
                }

                /* GUARD: Is the "account:key" key in parsedResult? */
                guard let accountKey = account[Udacity.AccountKey] as? String else {
                    completionHandlerForLogin(false, nil, nil, "Cannot find key '\(Udacity.AccountKey)' in \(parsedResult)")
                    return
                }
                completionHandlerForLogin(true, sessionKey, accountKey, nil)
            }
        }
    }

    // MARK: Login Handler

    func logoutHandler(_ hostViewController: UIViewController,
                       completionHandlerForLogout: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        //No parameters in this case, thus sending an empty object
        let parameters = [String: AnyObject]()

        let _ = taskForUdacityDeleteMethod(Udacity.SessionPath, parameters: parameters) {
            (results, error) in

            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForLogout(false, "Unable to Logout")
            } else {
                completionHandlerForLogout(true, "Unable to Logout")
            }
        }
    }
}
