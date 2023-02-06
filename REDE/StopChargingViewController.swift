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
    @IBOutlet weak var viewSocStatus: UIView!
    @IBOutlet weak var lblCurrent: UILabel!
    @IBOutlet weak var lblEnegry: UILabel!
    
    @IBOutlet weak var viewSocStatusHeightConstarint: NSLayoutConstraint!
    
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
        
        //AC - Hide SOC
        //DC - Visible SOC
        if details.chargerType?.lowercased().elementsEqual("ac") ?? false {
            self.viewSocStatus.isHidden = true
            self.viewSocStatusHeightConstarint.constant = 0
        }
        else {
            self.viewSocStatus.isHidden = false
            self.viewSocStatusHeightConstarint.constant = 49.5
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZ"
        
        details.meterData?.sort { (lhs: MeterData, rhs: MeterData) -> Bool in
            return dateFormatter.date(from: lhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0 < dateFormatter.date(from: rhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0
        }
        
        let data = details.meterData?.last
        
        if let item = data?.sampledValue?.filter({ $0.measurand?.elementsEqual("Energy.Active.Import.Register") ?? false}).first{
            if let value = item.value, let kwh = Float(value){
                self.lblEnegry.text = String(format:"%.4f kW h", kwh/1000)
            }
            else{
                self.lblEnegry.text = ""
            }
        }
        else{
            self.lblEnegry.text = ""
        }
        
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
                    if (data?.message?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: data?.message)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if self.chargerStation?.site?.pricePlanId != nil {
                    self.gotoTransactionHistory()
                }
                else{
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
                
                if (error?.elementsEqual("Your session has been expired.") ?? false){
                    self.logout()
                }
                else{
                    
                    self.updateUI(details: &transaction)
                    
                    if (transaction.connectorStatus?.uppercased().elementsEqual("SUSPENDEDEV") ?? false) ||
                        (transaction.connectorStatus?.uppercased().elementsEqual("SUSPENDEDEVSE") ?? false) {
                        if self.chargerStation?.site?.pricePlanId != nil{
                            self.updatePayment()
                        }
                        else{
                            self.gotoDashboard()
                        }
                    }
                    /*else if transaction.status?.lowercased().elementsEqual("active") ?? false{
                     self.updateUI(details: &transaction)
                     }*/
                    else if transaction.status?.lowercased().elementsEqual("finished") ?? false {
                        self.updateTimer?.invalidate()
                        self.gotoTransactionHistory()
                    }
                    else if transaction.status?.lowercased().elementsEqual("failed") ?? false {
                        self.updateTimer?.invalidate()
                        self.gotoDashboard()
                    }
                }
            }
        }
    }
    
    
    
    func updatePayment(){
        
        guard let authId = self.authId, let transactionId = self.transaction?.transactionId else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().updatePayment(authId: authId, sessionId: transactionId) { response, error in
            
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if response.status{
                    self.updateTimer?.invalidate()
                    self.gotoDashboard()
                }
                else{
                    self.showAlert(title: "RED E", message: response.data)
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
