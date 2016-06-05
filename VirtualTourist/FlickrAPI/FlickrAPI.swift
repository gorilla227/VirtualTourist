//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Andy on 16/6/3.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class FlickrAPI {
    static let SharedInstance = FlickrAPI()
    
    private func generateURL(parameters: [String: AnyObject]) -> NSURL {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Constants.Basic.APIScheme
        urlComponents.host = Constants.Basic.APIHost
        urlComponents.path = Constants.Basic.APIPath
        urlComponents.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems?.append(queryItem)
        }
        
        return urlComponents.URL!
    }
    
    private func generalErrorHandlering(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (result: AnyObject?, errorMessage: String?) -> Void) {
        guard error == nil else {
            completionHandler(result: nil, errorMessage: error?.localizedDescription)
            return
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode else {
            completionHandler(result: nil, errorMessage: "No statusCode")
            return
        }
        
        guard statusCode >= 200 && statusCode < 300 else {
            completionHandler(result: nil, errorMessage: "Your request returned a status code \(statusCode) out of range!")
            return
        }
        
        guard let data = data else {
            completionHandler(result: nil, errorMessage: "No datat was returned by the request.")
            return
        }
        
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandler(result: nil, errorMessage: "Could not parse the data with JSON")
            return
        }
        
        guard let stat = parsedResult[Constants.ResponseKeys.Status] as? String where stat == Constants.ResponseValues.OKStatus else {
            completionHandler(result: nil, errorMessage: "Flickr API returned an error stat.")
            return
        }
        
        completionHandler(result: parsedResult, errorMessage: nil)
    }
    
    func requestMaxPages(parameters: [String: AnyObject], completionHandler: (result: Int, errorMessage: String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: generateURL(parameters))
        print(request.URL)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.generalErrorHandlering(data, response: response, error: error, completionHandler: { (result, errorMessage) in
                guard let parsedResult = result where errorMessage == nil else {
                    completionHandler(result: 0, errorMessage: errorMessage)
                    return
                }
                
                guard let photosDictionary = parsedResult[Constants.ResponseKeys.Photos] as? [String: AnyObject] else {
                    completionHandler(result: 0, errorMessage: "Cannot find key \(Constants.ResponseKeys.Photos)")
                    return
                }
                
                guard let totalPages = photosDictionary[Constants.ResponseKeys.Pages] as? Int else {
                    completionHandler(result: 0, errorMessage: "Cannot find key '\(Constants.ResponseKeys.Pages)' in photosDictionary")
                    return
                }
                
                // Return the totalPages(max 40)
                completionHandler(result: min(totalPages, 40), errorMessage: nil)
            })
        }
        
        task.resume()
    }
    
    func requestImageList(parameters: [String: AnyObject], completionHandler: (result: [String]?, errorMessage: String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: generateURL(parameters))
        print(request.URL)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.generalErrorHandlering(data, response: response, error: error, completionHandler: { (result, errorMessage) in
                guard let parsedResult = result where errorMessage == nil else {
                    completionHandler(result: nil, errorMessage: errorMessage)
                    return
                }
                
                guard let photosDictionary = parsedResult[Constants.ResponseKeys.Photos] as? [String: AnyObject] else {
                    completionHandler(result: nil, errorMessage: "Cannot find key \(Constants.ResponseKeys.Photos)")
                    return
                }
                
                guard let photos = photosDictionary[Constants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandler(result: nil, errorMessage: "Cannot find key \(Constants.ResponseKeys.Photo)")
                    return
                }
                
                var photoList = [String]()
                for photo in photos {
                    if let photoURL = photo[Constants.ResponseKeys.MediumURL] as? String {
                        photoList.append(photoURL)
                    }
                }
                
                completionHandler(result: photoList, errorMessage: nil)
            })
        }
        
        task.resume()
    }
}