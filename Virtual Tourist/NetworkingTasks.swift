//
//  NetworkingTasks.swift
//  On The Map
//
//  Created by Epic Systems on 3/4/19.
//  Copyright © 2019 EpicSystems. All rights reserved.
//

import Foundation

class NetworkingTasks {
    
    // MARK: shared session
    var session = URLSession.shared
    
    // MARK: Shared Instances
    static func shared() -> NetworkingTasks {
        struct singlton {
            static var sharedInstance = NetworkingTasks()
        }
        return singlton.sharedInstance
    }
    
    
    
    
    func makeURLFromParameters(_ parameters: [String:Any]? = nil, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        
        components.scheme = FlickrConstants.ApiScheme
        components.host = FlickrConstants.ApiHost
        components.path = FlickrConstants.ApiPath + (withPathExtension ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    
    func getTask(url: URL, completionHandlerForGetTask: @escaping (_ result: Data?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                completionHandlerForGetTask(nil, error)
            }
            
            guard (error == nil) else {
                sendError("request error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("wrong code")
                return
            }
            
            guard let data = data else {
                sendError("no data")
                return
            }
            
           completionHandlerForGetTask(data, nil)
            
        }
        
        task.resume()
        
        return task
    }
    
    func getPhotos(latitude: Double, longitude: Double, totalPages: Int?,completion: @escaping (_ fetchedPhotos: PhotosMainObject?, _ error: String?) -> Void) {
        
        var page = 1
    
        if let total = totalPages {
            let lower : UInt32 = 1
            let upper = UInt32(total)
            page = Int(arc4random_uniform(upper - lower) + lower)
        } else {
             page = 1
        }
    
        let params = [
            FlickrAPIParameterKeys.Method : FlickrAPIParameterValues.SearchMethod,
            FlickrAPIParameterKeys.APIKey : FlickrAPIParameterValues.APIKey,
            FlickrAPIParameterKeys.latitude: latitude,
            FlickrAPIParameterKeys.longitude : longitude,
            FlickrAPIParameterKeys.Extras : FlickrAPIParameterValues.MediumURL,
            FlickrAPIParameterKeys.PhotosPerPage: FlickrAPIParameterValues.PhotosPerPage,
            FlickrAPIParameterKeys.Page : page,
            FlickrAPIParameterKeys.Format : FlickrAPIParameterValues.ResponseFormat,
            FlickrAPIParameterKeys.NoJSONCallback : FlickrAPIParameterValues.JSONCallbackState
            ] as [String : Any]
        
        let url = makeURLFromParameters(params, withPathExtension: nil)
        
        let _ = getTask(url: url) { (response, error) in
            
            if let error = error {
                
                completion(nil, error)
                return
            }
            
            guard let response = response else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let photos = try decoder.decode(PhotosMainObject.self, from: response)
                completion(photos, nil)
            } catch {
                completion(nil, error.localizedDescription)
            }
        }
        
    }

    func downloadImage (url: String, completion: @escaping (_ image: Data?, _ error: String?) -> Void) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let _ = getTask(url: url) { (imageData, error) in
            
            if let err = error {
                completion(nil, err)
            } else {
                completion(imageData, nil)
            }
        }
    }

}
