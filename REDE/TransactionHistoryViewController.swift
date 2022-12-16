//
//  TransactionHistoryViewController.swift
//  REDE
//
//  Created by Avishek on 05/09/22.
//

import UIKit

class TransactionHistoryViewController: BaseViewController {
    
    @IBOutlet weak var lblChargerStation: UILabel!
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    var transaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
        self.getChargingProgressDetails()
    }
    
    func updateUI(details: inout TransactionDetails){
        
        self.lblChargerStation.text = details.chargingStationName ?? ""
        
        self.lblCost.text = "$ \(details.finalAmount ?? 0)"
        
        self.lblStatus.text = details.status
        
        self.lblDate.text = details.sessionEnd
        
        //self.lblEnergy.text = details.sessionEnd
        
/*
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
        
        NetworkManager().getTransactionDetails(transactionId: transactionId) { transaction, error in
            
            guard var transaction = transaction else {
                return
            }
            
            DispatchQueue.main.async {
                self.updateUI(details: &transaction)
            }
        }
    }
}
