//
//  StopChargingViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit
import SVProgressHUD

class StopChargingViewController: BaseViewController {
    
    @IBOutlet weak var lblChargerStation: UILabel!
    @IBOutlet weak var lblSiteId: UILabel!
    @IBOutlet weak var lblSocStatus: UILabel!
    @IBOutlet weak var lblCurrent: UILabel!
    
    var chargerStation:ChargerStation?
    var transaction: Transaction?
    var authId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
    }
}

extension StopChargingViewController {
    
    @IBAction func onClickStopCharging(){
        self.stopCharging()
    }
    
    func gotoDashboard(){
        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
    }
}

extension StopChargingViewController {
    
    func stopCharging(){
        guard let ocppCbid = self.chargerStation?.ocppCbid, let transactionId = transaction?.transactionId else {
            self.gotoDashboard()
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().stopCharging(ocppCbid: ocppCbid, transactionId: transactionId) { data, error in
            guard let transaction = data else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                    self.gotoDashboard()
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if self.chargerStation?.site?.pricePlanId != nil {
                    //call update payment
                }
                else{
                    //do nothing
                    self.gotoDashboard()
                }
            }
        }
    }
}
