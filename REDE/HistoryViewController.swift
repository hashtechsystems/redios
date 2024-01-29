//
//  HistoryViewController.swift
//  REDE
//
//  Created by Riddhi Makwana on 20/12/23.
//

import UIKit
import SVProgressHUD
class HistoryViewController: UIViewController {

    @IBOutlet weak var tblView : UITableView!
    let refreshControl = UIRefreshControl()

    var transactions = [History]()
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblView.addSubview(refreshControl) // not required when using UITableViewController
     

        tblView.register(UINib(nibName: "TransactionHistoryCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryCell")
        getHistory()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getHistory()
    }
    func getHistory(){
        SVProgressHUD.show()
        NetworkManager().getTransactionHistory { response, error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard let transaction = response else {
                return
            }
            self.transactions.removeAll()
            self.transactions = transaction
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tblView.reloadData()
            }
            
            
        }
    }
}
extension HistoryViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
        cell.vwMain.layer.cornerRadius = 4
        cell.vwMain.layer.shadowColor = UIColor.gray.cgColor
        cell.vwMain.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell.vwMain.layer.shadowRadius = 4
        cell.vwMain.layer.shadowOpacity = 0.3
        let obj = self.transactions[indexPath.row]
        cell.lblId.text = "Transcation ID : \(obj.id ?? 0)"
        cell.lblSiteName.text = "Site Name : \(obj.site_name ?? "")"
        cell.lblChargerName.text = "Charger Name : \(obj.charger_name ?? "")"
        cell.lblAmount.text = "$\(obj.amount ?? 0)"
        let Energy = String(format:"%.2f kW", ((obj.meter_diff ?? 0)/1000))
        cell.lblEnegeryDelivered.text = "Energy Delivered : \(Energy)"
        cell.lblDate.text = obj.created_at ?? ""
        cell.selectionStyle = .none
        return cell
    }
    
}
