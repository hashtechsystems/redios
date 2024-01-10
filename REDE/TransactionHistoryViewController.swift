//
//  TransactionHistoryViewController.swift
//  REDE
//
//  Created by Avishek on 05/09/22.
//

import UIKit
import SVProgressHUD

class TransactionHistoryViewController: BaseViewController {
    
    @IBOutlet weak var lblChargerStation: UILabel!
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    var transaction: Transaction?
    var chargerStation:ChargerStation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
        self.getChargingProgressDetails()
    }
    
    func updateUI(details: inout TransactionDetails, amount: Double?){
        
        self.lblChargerStation.text = details.chargingStationName ?? ""
        
        self.lblStatus.text = "Successful"
        
        self.lblDate.text = "\(details.createdAt ?? "") \(details.zone ?? "UTC")"
        
        self.lblDuration.text = "\(details.duration ?? "")"
        
        self.lblEnergy.text = "\((details.meterDiff ?? 0.0) / 1000.00) kWh"
        
        if details.price_plan_details != nil{
            if ((details.amount ?? 0.0) == 0.0){
                self.lblCost.text = "Free"
            }else{
                self.lblCost.text = "$ \(details.amount ?? 0.0)"
            }
        }
        else{
            self.lblCost.text = "Free"
        }
        
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZ"
        
        details.meterData?.sort { (lhs: MeterData, rhs: MeterData) -> Bool in
            return dateFormatter.date(from: lhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0 < dateFormatter.date(from: rhs.timestamp ?? "")?.timeIntervalSince1970 ?? 0
        }
        
        let allSampledValues = details.meterData?.compactMap{ $0.sampledValue }.reduce([], +)
        let energyValues = allSampledValues?.filter({ $0.measurand?.elementsEqual("Energy.Active.Import.Register") ?? false })
        
        let kwhStart = Float(details.meterStart ?? 0)
        if let meterDataEnd = energyValues?.last?.value, let kwhEnd = Float(meterDataEnd) {
            let value = (kwhEnd - kwhStart)/1000
            self.lblEnergy.text = String(format:"%.2f kW", value)
            if self.chargerStation?.pricePlanId != nil{
                if (value < 0.01){
                    self.lblCost.text = "Free"
                }else{
                    self.lblCost.text = "$ \(amount ?? 0)"
                }
            }
            else{
                self.lblCost.text = "Free"
            }
        }
        else{
            self.lblEnergy.text = ""
            self.lblCost.text = ""
        }*/
    }
}

extension TransactionHistoryViewController {
    
    @IBAction func gotoDashboardClick(){
        self.gotoDashboard()
    }
    
    func gotoDashboard(){
        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
    }
    
    func getChargingProgressDetails(){
       
        guard let transactionId = transaction?.transactionId else {
            return
        }
        
        SVProgressHUD.show()
        
        NetworkManager().getTransactionDetails(transactionId: transactionId) { [weak self] data, error in
            
            guard var transaction = data?.data else {
                return
            }
            
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
                
                if (error?.elementsEqual("Your session has been expired.") ?? false){
                    self?.logout()
                }
                else{
                    self?.updateUI(details: &transaction, amount: data?.amount)
                }
            }
        }
    }
}
