//
//  OTMConstants.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation

extension OnTheMapClient {

    // MARK: Constants

    struct Udacity {

        // MARK: URLs
        static let Host         = "www.udacity.com"
        static let Path         = "/api"

        // MARK: Authentication
        static let SessionPath  = "/session"
        static let UserInfoPath = "/users/"

        static let UserId = "id"

        static let Udacity  = "udacity"
        static let Username = "username"
        static let Password = "password"

        static let Session    = "session"
        static let Account    = "account"
        static let AccountKey = "key"
        static let SessionId  = "id"

        struct JsonResponseKeys {
            static let Users     = "user"
            static let LastName  = "last_name"
            static let FirstName = "first_name"
        }

    }

}
