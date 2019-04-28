//
//  PhotosModel.swift
//  Virtual Tourist
//
//  Created by Epic Systems on 4/26/19.
//  Copyright © 2019 AhmedHazzaa. All rights reserved.
//

import Foundation

struct PhotosMainObject: Codable {
    
    var photos : PhotosObject?
    let stat : String?
    
    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }

    
}

struct PhotosObject: Codable {
    
    let page : Int?
    let pages : Int?
    let perpage : Int?
    let photo : [PhotoObject]?
    let total : String?
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case photo = "photo"
        case total = "total"
    }
    
    
}

struct PhotoObject: Codable {
    
    let title : String?
    let urlN : String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case urlN = "url_n"
    }
    
}
