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
    
    let locationManager = CLLocationManager()
    var center: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navbar.isLeftButtonHidden = true
        
        mapview.delegate = self
        mapview.userTrackingMode = .follow
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

extension MapViewController{
    func fetchSites(lat: Double, long: Double){
        NetworkManager().sites(lat: 41.12, long: -71.34) { sites, error in
            DispatchQueue.main.async {
                
                let annotations = sites.map { site -> SiteAnnotation in
                    let pin = SiteAnnotation()
                    pin.title = site.name
                    pin.subtitle = site.address
                    pin.site = site
                    pin.coordinate = CLLocationCoordinate2D(
                        latitude: Double(site.latitude) ?? 0.0,
                        longitude: Double(site.longitude) ?? 0.0
                    )
                    return pin
                }
                
                self.mapview.addAnnotations(annotations)
                
                if let center = self.center{
                    self.mapview.zoom(toCenterCoordinate: center, zoomLevel: 15)
                }
            }
        }
    }
}


extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.fetchSites(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
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
        
        let pinImage = UIImage(named: "flag")
        annotationView?.image = pinImage
       
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    /// Called whent he user taps the disclosure button in the bridge callout.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? SiteAnnotation {
            guard let controller = UIViewController.instantiateVC(viewController: ChargerDetailsViewController.self) else { return }
            controller.site = annotation.site
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class SiteAnnotation: MKPointAnnotation{
    var site: Site?
}


extension MKMapView {
    
    var MERCATOR_OFFSET : Double {
        return 268435456.0
    }
    
    var MERCATOR_RADIUS : Double  {
        return 85445659.44705395
    }
    
    private func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / 180.0)
    }
    
    private func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / 180.0)) / (1 - sin(latitude * Double.pi / 180.0))) / 2.0)
    }
    
    private  func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / Double.pi;
    }
    
    private func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / Double.pi;
    }
    
    private func coordinateSpan(withMapView mapView: MKMapView, centerCoordinate: CLLocationCoordinate2D, zoomLevel: UInt) ->MKCoordinateSpan {
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        let zoomExponent = Double(20 - zoomLevel)
        let zoomScale = pow(2.0, zoomExponent)
        
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth =  Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng;
        
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat);
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        return span
    }
    
    func zoom(toCenterCoordinate centerCoordinate:CLLocationCoordinate2D, zoomLevel: UInt) {
        let zoomLevel = min(zoomLevel, 20)
        let span = self.coordinateSpan(withMapView: self, centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.setRegion(region, animated: true)
        
    }
}
