//
//  MapViewController.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 22.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import UIKit
//import YandexMapKit
//import GoogleMaps
//import GooglePlaces
import MapKit

protocol AddressDelegate {
    func didSelect(street: String)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: AddressDelegate? = nil
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var zoomLevel: Float = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        self.mapView.showsUserLocation = true
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func finishMap(_ sender: Any) {
        if delegate != nil {
            self.mapView.showsUserLocation = false
            for annotation in self.mapView.annotations {
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    
                    // Location name
                    if let locationName = placeMark.location {
                        print(locationName)
                    }
                    // Street address
                    if let street = placeMark.thoroughfare {
                        if let delegate = self.delegate {
                            delegate.didSelect(street: street)
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                    }
                    // City
                    if let city = placeMark.subAdministrativeArea {
                        print(city)
                    }
                    // Zip code
                    if let zip = placeMark.isoCountryCode {
                        print(zip)
                    }
                    // Country
                    if let country = placeMark.country {
                        print(country)
                    }
                })
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            guard let location = manager.location else { return }
        }
    }
    
    
}

