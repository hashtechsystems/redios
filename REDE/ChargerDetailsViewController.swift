//
//  ChargerDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit
import SVProgressHUD

class ChargerDetailsViewController: BaseViewController {

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblConnector: UILabel!
    @IBOutlet weak var viewPlugIn: UIView!
    
    var chargerId: Int?
    fileprivate var chargerStation:ChargerStation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isRightButtonHidden = true
        self.fetchChargerDetails()
    }
    
    func updateUI(){
        lblLocation.text = chargerStation?.site?.getFullAdress()
        lblId.text = chargerStation?.name
    }
}

extension ChargerDetailsViewController {
    
    @IBAction func onClickConfirm(){

    }
}

extension ChargerDetailsViewController {
    
    func fetchChargerDetails(){
        
        guard let chargerId = self.chargerId else { return }
        
        SVProgressHUD.show()
        NetworkManager().fetchChargerDetails(chargerId: chargerId) { charger, error  in
            guard let _ = charger else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.chargerStation = charger
                self.updateUI()
            }
        }
    }
}
