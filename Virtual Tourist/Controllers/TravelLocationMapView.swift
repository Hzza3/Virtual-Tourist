//
//  TravelLocationMapView.swift
//  Virtual Tourist
//
//  Created by Epic Systems on 4/26/19.
//  Copyright © 2019 AhmedHazzaa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapView: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let dataController = DataController.shared()
    
    var pins = [Pin]()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Virtual Tourist"
        mapView.delegate = self
        
        dataController.load()
        
        loadPins()
    }
    
    @IBAction func addPinTapped(_ sender: UILongPressGestureRecognizer) {
        
        let loc = sender.location(in: mapView)
        let cordinates = mapView.convert(loc, toCoordinateFrom: mapView)
        
        if sender.state == .ended {
            putPinOnTheMap(cordinates: cordinates)
            savePin(cordinates: cordinates)
        }
    }
    
    func putPinOnTheMap(cordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        annotations.append(annotation)
        self.mapView.addAnnotation(annotation)
    }
    
    func makeAnnotations() {
        
        for pin in pins {
            
            let lat = CLLocationDegrees(Double(pin.lat!)!)
            let long = CLLocationDegrees(Double(pin.long!)!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
            
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func savePin(cordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.lat = String(cordinates.latitude)
        pin.long = String(cordinates.longitude)
        pins.append(pin)
        try? dataController.viewContext.save()
    }
    
    func loadPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            makeAnnotations()
        }
    }
    
    func loadPin(lat: String, lon: String) -> Pin? {
        
        var pin: Pin?
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "lat == %@ AND long == %@", lat, lon)
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pin = result.first
        }
        return pin
    }
    
}

extension TravelLocationMapView {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if let selectedAnnotation = view.annotation {
            mapView.deselectAnnotation(selectedAnnotation, animated: true)
            let cord = selectedAnnotation.coordinate
            let dvc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumVC
            dvc.locCordinates = cord
            dvc.pin = loadPin(lat: String(cord.latitude), lon: String(cord.longitude))
            self.navigationController?.pushViewController(dvc, animated: true)
        }
        
    }
    
}
