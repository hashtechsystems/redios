//
//  ChargerDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit

class ChargerDetailsViewController: BaseViewController {

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblConnector: UILabel!
    @IBOutlet weak var viewPlugIn: UIView!
    
    var site: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isRightButtonHidden = true
        lblLocation.text = site?.address
    }
}

extension ChargerDetailsViewController {
    
    @IBAction func onClickConfirm(){

    }
}
