//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Epic Systems on 4/26/19.
//  Copyright © 2019 AhmedHazzaa. All rights reserved.
//

import UIKit

protocol MyCollectionViewCell {
    func didDownloadImage(index: Int, image: Data)
}
class PhotoViewCell: UICollectionViewCell {
    
    var delegate: MyCollectionViewCell?
    var index :Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configCell (url: String) {
        
        self.imageView.backgroundColor = .groupTableViewBackground
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        NetworkingTasks.shared().downloadImage(url: url) { (imageData, error) in
            if (error != nil) {
                
                self.activityIndicator.stopAnimating()
                print(error!)
                
            } else {
                
                self.delegate?.didDownloadImage(index: self.index ?? 0, image: imageData!)
                performUIUpdatesOnMain {
                    self.imageView.backgroundColor = .clear
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.imageView.image = UIImage(data: imageData!)
                }
            }
        }
    }
    
    
}
