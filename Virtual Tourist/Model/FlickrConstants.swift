//
//  OnTheMapConstants.swift
//  On The Map
//
//  Created by Epic Systems on 3/4/19.
//  Copyright © 2019 EpicSystems. All rights reserved.
//

import Foundation


struct FlickrConstants {
    
    static let ApiScheme = "https"
    static let ApiHost = "api.flickr.com"
    static let ApiPath = "/services/rest"
}

struct FlickrAPIParameterKeys {
    static let Method = "method"
    static let APIKey = "api_key"
    static let latitude = "lat"
    static let longitude = "lon"
    static let Extras = "extras"
    static let PhotosPerPage = "per_page"
    static let Page = "page"
    static let Format = "format"
    static let NoJSONCallback = "nojsoncallback"
}

struct FlickrAPIParameterValues {
    static let SearchMethod = "flickr.photos.search"
    static let APIKey = "15d174dbd1677800a8c53916e5910905"
    static let MediumURL = "url_n"
    static let PhotosPerPage = 10
    static let ResponseFormat = "json"
    static let JSONCallbackState = "1"
}


