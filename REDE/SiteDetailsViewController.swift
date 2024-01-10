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
        lblName.text = site?.name
        lblLocation.text = site?.getFullAdress()
        tblChargers.backgroundColor = .white
        tblChargers.separatorColor = UIColor.init(patternImage: UIImage.init(named: "dotted_line")!)
        tblChargers.register(UINib(nibName: "SiteDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "SiteDetailTableViewCell")
    }
}

extension SiteDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return site?.chargerStations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chargerStation = self.site?.chargerStations?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiteDetailTableViewCell") as! SiteDetailTableViewCell
        cell.backgroundColor = .white
        
        
        cell.lblName.font = UIFont.init(name: "Aldrich-Regular", size: 18)
        cell.lblName.textColor = UIColor.init(red: 189.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        cell.lbloutput.font = UIFont.init(name: "Aldrich-Regular", size: 14)
        cell.lbloutput.textColor = UIColor.black

//        cell.lbloutput.text = chargerStation?.charger_output ?? ""
        cell.lblName.text = chargerStation?.name
        
        if let chargerStation = chargerStation {
            if chargerStation.connectors.count >= 1 {
                let connector1 = chargerStation.connectors[0]
                cell.lblConnection1.text = connector1.type
                cell.lblConnection1KW.text = "\(connector1.connector_output) KW"
                cell.vwPoint1.layer.cornerRadius = 5
                cell.vwPoint1.layer.masksToBounds = true
                if connector1.status == "AVAILABLE" {
                    cell.lblConnection1.textColor = hexStringToUIColor(hex: "31C418")
                    cell.lblConnection1KW.textColor = hexStringToUIColor(hex: "31C418")
                } else {
                    cell.lblConnection1.textColor = .gray
                    cell.lblConnection1KW.textColor = .gray
                }

                if chargerStation.connectors.count == 2 {
                    let connector2 = chargerStation.connectors[1]
                    cell.lblConnection2.text = connector2.type
                    cell.lblConnection2KW.text = "\(connector2.connector_output) KW"
                    cell.stackView2.isHidden = false
                    cell.vwPoint2.layer.cornerRadius = 5
                    cell.vwPoint2.layer.masksToBounds = true
                    if connector2.status == "AVAILABLE" {
                        cell.lblConnection2.textColor = hexStringToUIColor(hex: "31C418")
                        cell.lblConnection2KW.textColor = hexStringToUIColor(hex: "31C418")
                    } else {
                        cell.lblConnection2.textColor = .gray
                        cell.lblConnection2KW.textColor = .gray
                    }
                } else {
                    cell.stackView2.isHidden = true
                }
            }
        }
        
        cell.vwMain.layer.cornerRadius = 8
        cell.vwMain.layer.masksToBounds = true
        //charger_output
//        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
//        cell.contentView.backgroundColor = UIColor.systemGray6
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = UIViewController.instantiateVC(viewController: ChargerDetailsViewController.self), let chargerStation = self.site?.chargerStations?[indexPath.row] else { return }
        controller.qrCode = chargerStation.qrCode
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
