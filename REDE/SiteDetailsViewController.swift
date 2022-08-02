//
//  SiteDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 01/08/22.
//

import UIKit

class SiteDetailsViewController: BaseViewController {
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblChargers: UITableView!
    
    var site: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isRightButtonHidden = true
        lblLocation.text = site?.getFullAdress()
    }
}

extension SiteDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return site?.chargerStations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let chargerStation = self.site?.chargerStations?[indexPath.row]
        cell.textLabel?.text = chargerStation?.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = UIViewController.instantiateVC(viewController: ChargerDetailsViewController.self), let chargerStation = self.site?.chargerStations?[indexPath.row] else { return }
        controller.chargerId = chargerStation.id
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
