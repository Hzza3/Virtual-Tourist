//
//  PhotoAlbumVC.swift
//  Virtual Tourist
//
//  Created by Epic Systems on 4/26/19.
//  Copyright © 2019 AhmedHazzaa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin : Pin?
    let dataController = DataController.shared()
    var locCordinates: CLLocationCoordinate2D!
    var totalPages : Int?
    
    var fetchedPhotos = [PhotoObject]() // data coming from flickr
    var photos = [Photo]() // for core data
    
    var newAlbum = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionView.register(UINib(nibName: "PhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoViewCell")
        
        setupmapview()
        loadPhotos()
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        
        NetworkingTasks.shared().getPhotos(latitude: locCordinates.latitude, longitude: locCordinates.longitude, totalPages: self.totalPages) { (fetchedPhotos, error) in
            if error == nil {
                
                self.newAlbum = true
                self.fetchedPhotos.removeAll()
                self.deleteAllPhotos()
                
                self.fetchedPhotos = fetchedPhotos?.photos?.photo ?? [PhotoObject]()
                self.totalPages = fetchedPhotos?.photos?.pages ?? 1
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func deleteAllPhotos() {
        
        for photo in self.photos {
            self.dataController.viewContext.delete(photo)
        }
        self.photos.removeAll()
        try? self.dataController.viewContext.save()
    }
    
    func deletePhoto(index: Int) {
        
        dataController.viewContext.delete(photos[index])
        try? dataController.viewContext.save()
        self.photos.remove(at: index)
        collectionView.reloadData()
    }
    
    func loadPhotos() {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin ?? Pin())
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            
            self.photos.removeAll()
            self.photos = result
    
            if self.photos.count == 0 {
                newAlbum = true
                getNewSetOfPhotos()
            } else {
                newAlbum = false
            }
        }
    }
    
    
    func getNewSetOfPhotos() {
        
        NetworkingTasks.shared().getPhotos(latitude: locCordinates.latitude, longitude: locCordinates.longitude, totalPages: nil) { (fetchedPhotos, error) in
            
            if error == nil {
                self.fetchedPhotos = fetchedPhotos?.photos?.photo ?? [PhotoObject]()
                self.totalPages = fetchedPhotos?.photos?.pages ?? 1
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension PhotoAlbumVC: MKMapViewDelegate  {
    
    func setupmapview() {
        
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCordinates
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCordinates, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

extension PhotoAlbumVC: MyCollectionViewCell {
    
    
    func didDownloadImage(index: Int, image: Data) {
        
        let photo = Photo(context: dataController.viewContext)
        photo.pin = self.pin
        photo.image = image
        photo.imageUrl = fetchedPhotos[index].urlN
        photo.title = fetchedPhotos[index].title
        
        try? dataController.viewContext.save()
        self.photos.append(photo)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newAlbum {
            return self.fetchedPhotos.count
        } else {
            return self.photos.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        
        if newAlbum {
            cell.delegate = self
            cell.index = indexPath.row
            cell.configCell(url: self.fetchedPhotos[indexPath.row].urlN ?? "")
            if indexPath.row == (self.fetchedPhotos.count - 1) {
                self.newAlbum = false
            }
            return cell
        } else {
            cell.imageView.image = UIImage(data: self.photos[indexPath.row].image ?? Data())
            cell.activityIndicator.isHidden = true
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deletePhoto(index: indexPath.row)
    }
}

