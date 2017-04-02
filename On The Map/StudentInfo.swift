//
//  StudentInfo.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation

struct StudentInfo {
    var firstName: String?

    var lastName: String?

    var objectId: String?

    var uniqueKey: String?

    var mapString: String?

    var mediaURL: String?

    var latitude: Double?

    var longitude: Double?

    var createdAt: Date?

    var updatedAt: Date?

    static var listOfStudents: [StudentInfo] = []

    init(dictionary: [String: AnyObject]) {

        self.createdAt = dictionary[OnTheMapClient.Parse.CreatedAt] as? Date

        self.firstName = dictionary[OnTheMapClient.Parse.FirstName] as? String

        self.lastName = dictionary[OnTheMapClient.Parse.LastName] as? String

        self.latitude = dictionary[OnTheMapClient.Parse.Latitude] as? Double

        self.longitude = dictionary[OnTheMapClient.Parse.Longitude] as? Double

        self.mapString = dictionary[OnTheMapClient.Parse.MapString] as? String

        self.mediaURL = dictionary[OnTheMapClient.Parse.MediaURL] as? String

        self.objectId = dictionary[OnTheMapClient.Parse.ObjectId] as? String

        self.uniqueKey = dictionary[OnTheMapClient.Parse.UniqueKey] as? String

        self.updatedAt = dictionary[OnTheMapClient.Parse.UpdatedAt] as? Date
    }
}
