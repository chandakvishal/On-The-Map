//
//  OTMConstants.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation

extension OnTheMapClient {

    struct Parse {

        // MARK: Values for API Key
        static let ApplicationIdValue     = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey             = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: URLs
        static let SecureScheme           = "https"
        static let Host                   = "parse.udacity.com"
        static let Path                   = "/parse/classes"

        // MARK: Student Location
        static let StudentLocationPath    = "/StudentLocation"

        // MARK: Parameter Keys
        static let ApplicationIdHeaderKey = "X-Parse-Application-Id"
        static let RestHeaderKey          = "X-Parse-REST-API-Key"
        static let SessionID              = "session_id"
        static let RequestToken           = "request_token"
        static let NumberOfStudents       = "limit"
        static let Order                  = "order"

        // MARK: JSON Response Keys
        static let UdacitySession         = "session"
        static let UdacityAccount         = "account"
        static let UdacityAccountKey      = "key"
        static let UdacitySessionId       = "id"
        static let LocationResults        = "results"

        // MARK: Json Keys
        static let Results                = "results"
        static let ObjectId               = "objectId"
        static let UniqueKey              = "uniqueKey"
        static let FirstName              = "firstName"
        static let LastName               = "lastName"
        static let MapString              = "mapString"
        static let MediaURL               = "mediaURL"
        static let Latitude               = "latitude"
        static let Longitude              = "longitude"
        static let CreatedAt              = "createdAt"
        static let UpdatedAt              = "updatedAt"
    }

}
