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
    
    var updateTimer: Timer?
    
    var chargerStation:ChargerStation?
    var transaction: Transaction?
    var authId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
        getChargingProgressDetails()
        updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getChargingProgressDetails), userInfo: nil, repeats: true)

    }
    
    func updateUI(details: inout TransactionDetails){
        self.lblSiteId.text = details.siteName ?? ""
        self.lblChargerStation.text = details.chargingStationName ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZ"
        
        details.meterData?.sort { (lhs: MeterData, rhs: MeterData) -> Bool in
            return dateFormatter.date(from: lhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0 < dateFormatter.date(from: rhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0
        }

        
        let data = details.meterData?.first
        
        if let item = data?.sampledValue?.filter({ $0.measurand?.elementsEqual("SoC") ?? false}).first{
            self.lblSocStatus.text = "\(item.value ?? "0") %"
        }
        else{
            self.lblSocStatus.text = ""
        }
        
        if let item = data?.sampledValue?.filter({ $0.measurand?.elementsEqual("Current.Import") ?? false}).first{
            self.lblCurrent.text = "\(item.value ?? "0") %"
        }
        else{
            self.lblCurrent.text = ""
        }
    }
}

extension StopChargingViewController {
    
    @IBAction func onClickStopCharging(){
        self.stopCharging()
        self.updateTimer?.invalidate()
    }
    
    func gotoDashboard(){
        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
    }
    
    func gotoTransactionHistory(){
        guard let controller = UIViewController.instantiateVC(viewController: TransactionHistoryViewController.self) else { return }
        controller.transaction = self.transaction
        self.navigationController?.pushViewController(controller, animated: true)
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
                    //self.updatePayment()
                    
                    
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
                    self.gotoTransactionHistory(data: response.data)
                }
                else{
                    self.showAlert(title: "Error", message: response.data)
                    self.gotoDashboard()
                }
            }
        }
    }
    
    @objc func getChargingProgressDetails(){
       
        guard let transactionId = transaction?.transactionId else {
            return
        }
        
        NetworkManager().getTransactionDetails(transactionId: transactionId) { transaction, error in
            
            guard var transaction = transaction else {
                return
            }
            
            DispatchQueue.main.async {
                if transaction.status?.lowercased().elementsEqual("Active") ?? false{
                    self.updateUI(details: &transaction)
                }
                else if transaction.status?.lowercased().elementsEqual("Finished") ?? false{
                    self.updateTimer?.invalidate()
                    if self.chargerStation?.site?.pricePlanId != nil {
                        self.updatePayment()
                    }
                    else{
                        self.gotoDashboard()
                    }
                }
                else if transaction.status?.lowercased().elementsEqual("Failed") ?? false{
                    self.updateTimer?.invalidate()
                    self.gotoDashboard()
                }
            }
        }
    }
}

/*
[
  {
    "timestamp": "2022-07-29T15:44:25.000Z",
    "sampledValue": [
      {
        "unit": "Wh",
        "value": "701439",
        "format": "Raw",
        "context": "Sample.Periodic",
        "location": "Outlet",
        "measurand": "Energy.Active.Import.Register"
      },
      {
        "unit": "W",
        "value": "0.0",
        "format": "Raw",
        "context": "Sample.Periodic",
        "location": "Outlet",
        "measurand": "Power.Active.Import"
      },
      {
        "unit": "Percent",
        "value": "60",
        "format": "Raw",
        "context": "Sample.Periodic",
        "location": "Outlet",
        "measurand": "SoC"
      },
      {
        "unit": "V",
        "value": "427",
        "format": "Raw",
        "context": "Sample.Periodic",
        "location": "Outlet",
        "measurand": "Voltage"
      },
      {
        "unit": "A",
        "value": "0",
        "format": "Raw",
        "context": "Sample.Periodic",
        "location": "Outlet",
        "measurand": "Current.Import"
      }
    ]
  }
]
*/
