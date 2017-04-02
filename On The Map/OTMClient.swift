//
//  OTMClient.swift
//  On The Map
//
//  Created by Chandak, Vishal on 19/03/17.
//  Copyright © 2017 Chandak, Vishal. All rights reserved.
//

import Foundation

class OnTheMapClient: NSObject {
    // MARK: Properties

    // shared session
    var session                          = URLSession.shared

    // authentication state
    var studentInfoArray: [StudentInfo]? = nil

    var sessionID: String? = nil
    var userId:    String? = nil
    var firstName: String? = nil
    var lastName:  String? = nil

    var ObjectId: String?

    // MARK: Initializers

    override init() {
        super.init()
    }

    // MARK: GET Request handler for Udacity API
    func taskForUdacityGETMethod(_ method: String,
                                 parameters: [String: AnyObject],
                                 completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: udacityUrlFromParameters(parameters, withPathExtension: method))
        return taskForGetMethod(isUdacityApi: true, request: request, completionHandlerForGET: completionHandlerForGET)
    }

    // MARK: GET Request handler for Parse API
    func taskForParseGETMethod(_ method: String,
                               parameters: [String: AnyObject],
                               completionHandlerForGET: @escaping (_ result: AnyObject?,
                                                                   _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: parseUrlFromParameters(parameters, withPathExtension: method))
        request.addValue(Parse.ApplicationIdValue, forHTTPHeaderField: Parse.ApplicationIdHeaderKey)
        request.addValue(Parse.RestApiKey, forHTTPHeaderField: Parse.RestHeaderKey)

        return taskForGetMethod(isUdacityApi: false, request: request, completionHandlerForGET: completionHandlerForGET)
    }

    // MARK: GET Request handler for Parse API
    func taskForParseGETMethodWithEncoding(_ method: String,
                                           parameters: String?,
                                           completionHandlerForGET: @escaping (_ result: AnyObject?,
                                                                               _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* Build the URL, Configure the request */
        let url     = NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?" + parameters!)
        let request = NSMutableURLRequest(url: url as! URL)
        request.addValue(Parse.ApplicationIdValue, forHTTPHeaderField: Parse.ApplicationIdHeaderKey)
        request.addValue(Parse.RestApiKey, forHTTPHeaderField: Parse.RestHeaderKey)

        return taskForGetMethod(isUdacityApi: false, request: request, completionHandlerForGET: completionHandlerForGET)
    }

    // MARK: Generic GET Handler
    func taskForGetMethod(isUdacityApi: Bool,
                          request: NSMutableURLRequest,
                          completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(isUdacityApi: isUdacityApi, data, completionHandlerForConvertData: completionHandlerForGET)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // MARK: POST Request handler for Udacity API
    func taskForUdacityPOSTMethod(_ method: String,
                                  parameters: [String: AnyObject],
                                  jsonBody: String,
                                  completionHandlerForPOST: @escaping (_ result: AnyObject?,
                                                                       _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: udacityUrlFromParameters(parameters, withPathExtension: method))
        request.addValue(Constants.AcceptHeaderValue, forHTTPHeaderField: "Accept")
        request.addValue(Constants.ContenTypeHeaderValue, forHTTPHeaderField: "Content-Type")
        return taskForPOSTMethod(isUdacityApi: true,
                                 request: request,
                                 jsonBody: jsonBody,
                                 completionHandlerForPOST: completionHandlerForPOST)
    }

    // MARK: POST Request handler for Parse API
    func taskForParsePOSTMethod(_ method: String,
                                parameters: [String: AnyObject],
                                jsonBody: String,
                                completionHandlerForPOST: @escaping (_ result: AnyObject?,
                                                                     _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: parseUrlFromParameters(parameters, withPathExtension: method))
        request.addValue(Parse.ApplicationIdValue, forHTTPHeaderField: Parse.ApplicationIdHeaderKey)
        request.addValue(Parse.RestApiKey, forHTTPHeaderField: Parse.RestHeaderKey)
        request.addValue(Constants.ContenTypeHeaderValue, forHTTPHeaderField: "Content-Type")

        return taskForPOSTMethod(isUdacityApi: false,
                                 request: request,
                                 jsonBody: jsonBody,
                                 completionHandlerForPOST: completionHandlerForPOST)
    }

    // MARK: Generic POST Handler
    func taskForPOSTMethod(isUdacityApi: Bool,
                           request: NSMutableURLRequest,
                           jsonBody: String,
                           completionHandlerForPOST: @escaping (_ result: AnyObject?,
                                                                _ error: NSError?) -> Void) -> URLSessionDataTask {

        request.httpMethod = "POST"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        print("Headers \(request.allHTTPHeaderFields)")
        print("JSON Body: " + jsonBody)
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code: \(response as? HTTPURLResponse)?.statusCode)")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(isUdacityApi: isUdacityApi, data, completionHandlerForConvertData: completionHandlerForPOST)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    func taskForPutMethod(_ method: String,
                          parameters: [String: AnyObject],
                          jsonBody: String,
                          completionHandlerForPut: @escaping (_ result: AnyObject?,
                                                              _ error: NSError?) -> Void) -> URLSessionDataTask {

        let request = NSMutableURLRequest(url: parseUrlFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "PUT"
        request.addValue(Parse.ApplicationIdValue, forHTTPHeaderField: Parse.ApplicationIdHeaderKey)
        request.addValue(Parse.RestApiKey, forHTTPHeaderField: Parse.RestHeaderKey)
        request.addValue(Constants.ContenTypeHeaderValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        print("Put Headers \(request.allHTTPHeaderFields)")

        print("JSON \(jsonBody)")
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPut(nil, NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code: \(response as? HTTPURLResponse)?.statusCode)")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(isUdacityApi: false, data, completionHandlerForConvertData: completionHandlerForPut)
        }

        /* 7. Start the request */
        task.resume()

        return task

    }
    // MARK: DELETE Request handler for Udacity API
    func taskForUdacityDeleteMethod(_ method: String,
                                    parameters: [String: AnyObject],
                                    completionHandlerForDelete: @escaping (_ result: AnyObject?,
                                                                           _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: udacityUrlFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage     = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        return taskForDeleteMethod(isUdacityApi: true, request: request, completionHandlerForDelete: completionHandlerForDelete)
    }

    // MARK: Generic DELETE Handler
    func taskForDeleteMethod(isUdacityApi: Bool,
                             request: NSMutableURLRequest,
                             completionHandlerForDelete: @escaping (_ result: AnyObject?,
                                                                    _ error: NSError?) -> Void) -> URLSessionDataTask {

        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDelete(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code: \(response as? HTTPURLResponse)?.statusCode)")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(isUdacityApi: isUdacityApi, data, completionHandlerForConvertData: completionHandlerForDelete)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(isUdacityApi: Bool, _ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {

        var datum = data
        if isUdacityApi == true {
            let range = Range(5..<data.count)
            datum = data.subdata(in: range) /* subset response data! */
        }

        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: datum, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(datum)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        print("Parsed Result: \(parsedResult)")
        completionHandlerForConvertData(parsedResult, nil)
    }

    // MARK: Generate Parse URL
    private func parseUrlFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()

        components.host = OnTheMapClient.Parse.Host
        components.path = OnTheMapClient.Parse.Path + (withPathExtension ?? "")
        return urlFromParameters(components: components, parameters, withPathExtension: withPathExtension)

    }

    // MARK: Generate Udacity URL
    private func udacityUrlFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.host = OnTheMapClient.Udacity.Host
        components.path = OnTheMapClient.Udacity.Path + (withPathExtension ?? "")

        return urlFromParameters(components: components, parameters, withPathExtension: withPathExtension)
    }

    // create a URL from parameters
    private func urlFromParameters(components: URLComponents, _ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {

        var components = components
        components.scheme = OnTheMapClient.Constants.SecureScheme
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.url!)
        return components.url!
    }

    // MARK: Shared Instance
    class func sharedInstance() -> OnTheMapClient {

        struct Singleton {
            static var sharedInstance = OnTheMapClient()
        }

        return Singleton.sharedInstance
    }
}
