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
    @IBOutlet weak var txtSearch : UITextField!
    var isFiltered = false
    let locationManager = CLLocationManager()
    var center: CLLocationCoordinate2D? = nil
    var search = ""
    var allSites = [Site]()
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
        locationManager.requestWhenInUseAuthorization()
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
    func showAnnotationToMap(sites : [Site]){
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
            let annotationsOld = self.mapview.annotations.filter({ !($0 is MKUserLocation) })
            self.mapview.removeAnnotations(annotationsOld)
            self.mapview.addAnnotations(annotations)
            if annotations.count == 1{
                //self.zoomAnnotations(on: self.mapview, toFrame: CGRect(x: 0, y: 0, width: self.mapview.frame.size.width, height: self.mapview.frame.size.height), animated: true)
                
                let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                let region = MKCoordinateRegion(center: annotations[0].coordinate, span: span)
                self.mapview.setRegion(region, animated: true)
            }else{
                self.mapview.fitAll()
            }
        }
        
    }
    func fetchSites(lat: Double, long: Double){
        NetworkManager().sites(lat: lat, long: long) { sites, error in
//            let filtedsites = sites.filter( { $0.name == "Brookings Activity Center SD"})
            self.allSites = sites
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
                    self.mapview.fitAll() //zoomToAnnotations(animated: true)
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
        
        var availableConnector = 0
        if let site = (annotation as? SiteAnnotation)?.site {
            for chargerStation in site.chargerStations ?? [] {
                availableConnector += chargerStation.connectors.filter { $0.status == "AVAILABLE" }.count
            }
        }
        
        
//        let index = site?.chargerStations?.count ?? 0
//        for i in 0..<index{
//            let allConnectors = site?.chargerStations?[i].connectors
//            for i in 0..<(allConnectors?.count ?? 0){
//                let conn = allConnectors?[i]
//                if conn?.status == "AVAILABLE"{
//                    availableConnector += 1
//                }
//            }
//        }
        
        if availableConnector != 0{
            let pinImage = UIImage(named: "ig_flag_green")
            annotationView?.image = pinImage
        }else{
            let pinImage = UIImage(named: "ig_flag_orange")
            annotationView?.image = pinImage
        }
        
        
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    /// Called whent he user taps the disclosure button in the bridge callout.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? SiteAnnotation {
            guard let controller = UIViewController.instantiateVC(viewController: SiteDetailsViewController.self) else { return }
//            controller.site = annotation.site
            controller.id = annotation.site?.id ?? 0
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
extension MapViewController : UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isFiltered = false
        self.showAnnotationToMap(sites: self.allSites)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if string.isEmpty
        {
            search = String(search.dropLast())
        }
        else
        {
            search=textField.text!+string
        }
        
        if (textField.text?.count ?? 0) > 1 {
           
            let filtedsites = self.allSites.filter( { $0.name.lowercased().contains((textField.text!.lowercased()))})
            if filtedsites.count > 0{
                isFiltered = true
                self.showAnnotationToMap(sites: filtedsites)
            }
        }else{
            if isFiltered == true{
                isFiltered = false
                self.showAnnotationToMap(sites: self.allSites)
            }
        }
        
        return true
    }
    
    func zoomAnnotations(on mapView: MKMapView, toFrame annotationsFrame: CGRect, animated: Bool) {
        guard mapView.annotations.count >= 2 else { return }

        // Step 1: Make an MKMapRect that contains all the annotations

        let annotations = mapView.annotations
        var minPoint = MKMapPoint(annotations[0].coordinate)
        var maxPoint = minPoint

        for annotation in annotations {
            let point = MKMapPoint(annotation.coordinate)
            minPoint.x = min(point.x, minPoint.x)
            minPoint.y = min(point.y, minPoint.y)
            maxPoint.x = max(point.x, maxPoint.x)
            maxPoint.y = max(point.y, maxPoint.y)
        }

        let mapRect = MKMapRect(
            x: minPoint.x,
            y: minPoint.y,
            width: maxPoint.x - minPoint.x,
            height: maxPoint.y - minPoint.y
        )

        // Step 2: Calculate the edge padding

        let edgePadding = UIEdgeInsets(
            top: annotationsFrame.minY,
            left: annotationsFrame.minX,
            bottom: mapView.bounds.maxY - annotationsFrame.maxY,
            right: mapView.bounds.maxX - annotationsFrame.maxX
        )

        // Step 3: Set the map rect

        mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: animated)
    }
        
}

extension MKMapView {

    func zoomToAnnotations(animated: Bool) {
        var zoomRect = MKMapRect.null
            for annotation in annotations {
                if let annotation = annotation as? MKAnnotation {
                    let annotationPoint = MKMapPoint(annotation.coordinate)
                    let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
                    if zoomRect.isNull {
                        zoomRect = pointRect
                    } else {
                        zoomRect = zoomRect.union(pointRect)
                    }
                }
            }
            
            let padding = 0.5
            
            let addHeight = zoomRect.size.height * (1 + padding)
            let addWidth = zoomRect.size.width * (1 + padding)
            
            zoomRect.size.height += addHeight
            zoomRect.size.width += addWidth
            
            zoomRect.origin.x -= addWidth / 2
            zoomRect.origin.y -= addHeight / 2
            
            self.setVisibleMapRect(zoomRect, animated: animated)
        }
    
    /// When we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null;
        let decreaseFactor: Double = 0.1 // Adjust this factor to control the decrease in zoom

        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let width = 0.01 * (1 - decreaseFactor)
            let height = 0.01 * (1 - decreaseFactor)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: width, height: height);
            zoomRect            = zoomRect.union(pointRect);
        }
        
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }

    /// We call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
    
        for annotation in annotations {
            let aPoint          = MKMapPoint(annotation.coordinate)
            let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
        
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

}
