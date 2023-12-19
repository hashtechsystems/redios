//
//  MapViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: BaseViewController {
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var btn_recenter: UIButton!
    
    let locationManager = CLLocationManager()
    var center: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navbar.setOnClickLeftButton {
            guard let controller = UIViewController.instantiateVC(viewController: ScannerViewController.self) else { return }
            controller.delegate = self
            self.present(controller, animated: true)
        }
        
        mapview.delegate = self
        mapview.mapType = .standard
        mapview.userTrackingMode = .follow
        mapview.isZoomEnabled = true
        mapview.isScrollEnabled = true
        mapview.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //locationManager.distanceFilter = 100
        //locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating location
        locationManager.startUpdatingLocation()
       // self.onQRDetection(code: "https://pay.rede.network/main/35293ea84dd5b7c3556381ceb1f06cd5")
    }
    
    @IBAction func onClickReCenter(){
        if let center = self.center {       
            self.setMapFocus(location: center, radiusInKm: 5000)
        }
    }
}

extension MapViewController{
    func fetchSites(lat: Double, long: Double){
        NetworkManager().sites(lat: lat, long: long) { sites, error in
            
            let annotations = sites.map { site -> SiteAnnotation in
                let pin = SiteAnnotation()
                pin.title = site.name
                pin.subtitle = site.address
                pin.site = site
                pin.coordinate = CLLocationCoordinate2D(
                    latitude: Double(site.latitude ?? "0.0") ?? 0.0,
                    longitude: Double(site.longitude ?? "0.0") ?? 0.0
                )
                return pin
            }
            
            DispatchQueue.main.async {
                if (error?.elementsEqual("Your session has been expired.") ?? false){
                    self.locationManager.stopUpdatingLocation()
                    self.logout()
                }
                else{
                    let annotationsOld = self.mapview.annotations.filter({ !($0 is MKUserLocation) })
                    self.mapview.removeAnnotations(annotationsOld)
                    self.mapview.addAnnotations(annotations)
                }
            }
        }
    }
}


extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
           // self.locationManager.stopUpdatingLocation()
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if self.center == nil {
                self.fetchSites(lat: location.coordinate.latitude, long: location.coordinate.longitude)
                self.setMapFocus(location: center, radiusInKm: 5000)
            }
            self.center = center
        }
    }
    
    func setMapFocus(location: CLLocationCoordinate2D, radiusInKm radius: CLLocationDistance) {
//        let diameter = radius * 2
//        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: diameter, longitudinalMeters: diameter)
//        self.mapview.region = region
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapview.setRegion(region, animated: true)
        
    }
}

extension MapViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        let pinImage = UIImage(named: "flag_red")
        annotationView?.image = pinImage
        
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    /// Called whent he user taps the disclosure button in the bridge callout.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? SiteAnnotation {
            guard let controller = UIViewController.instantiateVC(viewController: SiteDetailsViewController.self) else { return }
            controller.site = annotation.site
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class SiteAnnotation: MKPointAnnotation{
    var site: Site?
}

extension MapViewController: ScannerDelegate{
    
    func onQRDetection(code: String) {
        guard let url = URL.init(string: code) else { return }
        guard let controller = UIViewController.instantiateVC(viewController: ChargerDetailsViewController.self) else { return }
        controller.qrCode = url.lastPathComponent
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
