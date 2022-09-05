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
           
            guard let transaction = data, transaction.transactionId > 0 else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if self.chargerStation?.site?.pricePlanId != nil {
                    self.updatePayment()
                }
                else{
                    self.gotoDashboard()
                }
            }
        }
    }
    
    func updatePayment(){
        
        guard let authId = self.authId, let transactionId = transaction?.transactionId else {
            self.gotoDashboard()
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().updatePayment(authId: authId, sessionId: transactionId) { response, error in
            
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if response.status{
                    guard let controller = UIViewController.instantiateVC(viewController: TransactionHistoryViewController.self) else { return }
                    controller.updatePaymentResponse = response
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else{
                    self.showAlert(title: "Error", message: response.data)
                    self.gotoDashboard()
                }
            }
        }
    }
}
