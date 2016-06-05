//
//  FlickrAPIConstants.swift
//  VirtualTourist
//
//  Created by Andy on 16/6/3.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

extension FlickrAPI {
    struct Constants {
        
        // MARK: Flickr Basic Constants
        struct Basic {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        // MARK: Flickr Parameter Keys
        struct ParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let PerPage = "per_page"
            static let SafeSearch = "safe_search"
            static let Page = "page"
        }
        
        // MARK: Flickr Parameter Values
        struct ParameterValues {
            static let Method_PhotsForLocation = "flickr.photos.search"
            static let APIKeys = "84e5e337149d5665571c87f47d1878d2"
            static let MediumURL = "url_m"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1"
            static let UseSafeSearch = "1"
        }
        
        // MARK: Flickr Response Keys
        struct ResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        struct ResponseValues {
            static let OKStatus = "ok"
        }
    }
}