//
//  MapViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var navbar: NavigationBar!
    @IBOutlet weak var mapview: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navbar.setOnClickLeftButton {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
