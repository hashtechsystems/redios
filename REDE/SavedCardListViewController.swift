//
//  SavedCardListViewController.swift
//  REDE
//
//  Created by Riddhi Makwana on 19/01/24.
//

import UIKit
protocol SavedCardListDelegate{
    func OpenCardView()
    func payWithCard(id : Int)
}

class SavedCardListViewController: UIViewController {
    @IBOutlet weak var tblView : UITableView!
    var delegate: SavedCardListDelegate?

    var cardList = [CreditCard]()
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: "CardTableViewCell")

        tblView.register(UINib(nibName: "AddNewCardTableViewCell", bundle: nil), forCellReuseIdentifier: "AddNewCardTableViewCell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBackClicked(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    

}
extension SavedCardListViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= cardList.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewCardTableViewCell", for: indexPath) as! AddNewCardTableViewCell
            cell.vwMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.vwMain.layer.borderWidth = 1.0
            cell.vwMain.layer.cornerRadius = 4
            cell.vwMain.layer.shadowColor = UIColor.gray.cgColor
            cell.vwMain.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.vwMain.layer.shadowRadius = 4
            cell.vwMain.layer.shadowOpacity = 0.3
                        
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as! CardTableViewCell
            cell.vwMain.layer.cornerRadius = 4
            cell.vwMain.layer.shadowColor = UIColor.gray.cgColor
            cell.vwMain.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.vwMain.layer.shadowRadius = 4
            cell.vwMain.layer.shadowOpacity = 0.3
            cell.vwMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.vwMain.layer.borderWidth = 1.0
            let obj = cardList[indexPath.row]
            cell.lblCard.text = "**** **** **** \(obj.cardNumber)"
            cell.lblExp.text = "Valid untill \(obj.expiryDate)"
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= cardList.count{
            self.delegate?.OpenCardView()
        }else{
            let obj = cardList[indexPath.row]
            self.delegate?.payWithCard(id: obj.id)
        }
        self.navigationController?.popViewController(animated: true)

    }
    
}
