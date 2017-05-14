//
//  ViewController.swift
//  NavGATOR
//
//  Created by yuma@duck on 12/4/17.
//  Copyright © 2017 yuma@duck. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var latitudeTxtField: UITextField!
    @IBOutlet weak var longitudeTxtField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var movedToUserLocation = false
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    func dropAnnotation(gestureRecogniser: UIGestureRecognizer) {
        if gestureRecogniser.state == .began {
            let holdLocation = gestureRecogniser.location(in: mapView)
            let coor = mapView.convert(holdLocation, toCoordinateFrom: mapView)
            
            let annotationView: MKAnnotationView!
            let pointAnnotation = MKPointAnnotation()
            
            pointAnnotation.coordinate = coor
            pointAnnotation.title = "\(coor.latitude), \(coor.longitude)"
            
            annotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: "Annotation2")
            mapView.addAnnotation(annotationView.annotation!)
            
            latitudeTxtField.text = "\(coor.latitude)"
            longitudeTxtField.text = "\(coor.longitude)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let keyboardDissapearrer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(keyboardDissapearrer)
        
        let pinDroppererererr = UILongPressGestureRecognizer(target: self, action: #selector(self.dropAnnotation(gestureRecogniser:)))
        pinDroppererererr.minimumPressDuration = CFTimeInterval(2.0)
        mapView.addGestureRecognizer(pinDroppererererr)
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @IBAction func navgate(_ sender: Any) {
        dismissKeyboard()
        
        if let latitudeTxt = latitudeTxtField.text, let longitudeTxt = longitudeTxtField.text {
            if latitudeTxt != "" && longitudeTxt != "" {
                if let lat = Double(latitudeTxt), let lon = Double(longitudeTxt) {
                    self.clearMap()
                    
                    let coor = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                    
                    let annotationView: MKPinAnnotationView!
                    let annotationPoint = MKPointAnnotation()
                    
                    annotationPoint.coordinate = coor
                    annotationPoint.title = "\(lat), \(lon)"
                    
                    annotationView = MKPinAnnotationView(annotation: annotationPoint, reuseIdentifier: "Annotation")
                    mapView.addAnnotation(annotationView.annotation!)
                    
                    let directionsRequest = MKDirectionsRequest()
                    directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
                    directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: coor))
                    directionsRequest.requestsAlternateRoutes = false
                    directionsRequest.transportType = .any
                    
                    let directions = MKDirections(request: directionsRequest)
                    
                    directions.calculate { response, error in
                        if let res = response {
                            if let route = res.routes.first {
                                self.mapView.add(route.polyline)
                                self.mapView.region.center = coor
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            print("hfuijdlnajnfijdnf")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            manager.startUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !movedToUserLocation {
            mapView.region.center = mapView.userLocation.coordinate
            
            movedToUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .yellow
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
