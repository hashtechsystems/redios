//
//  TransactionHistoryViewController.swift
//  REDE
//
//  Created by Avishek on 05/09/22.
//

import UIKit

class TransactionHistoryViewController: BaseViewController {
    
    @IBOutlet weak var lblTransaction: UILabel!
    
    var updatePaymentResponse: UpdatePaymentResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isLeftButtonHidden = true
        self.navbar.isRightButtonHidden = true
        self.lblTransaction.text = self.updatePaymentResponse?.data ?? ""
    }
}

extension TransactionHistoryViewController {
    
    @IBAction func gotoDashboardClick(){
        self.gotoDashboard()
    }
    
    func gotoDashboard(){
        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
    }
}
