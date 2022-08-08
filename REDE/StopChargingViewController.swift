//
//  StopChargingViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit

class StopChargingViewController: BaseViewController {
    
    @IBOutlet weak var lblChargerStation: UILabel!
    @IBOutlet weak var lblSiteId: UILabel!
    @IBOutlet weak var lblSocStatus: UILabel!
    @IBOutlet weak var lblCurrent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
    }
}

extension StopChargingViewController {
    
    @IBAction func onClickStopCharging(){
        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
    }
}
