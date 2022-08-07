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
    @IBOutlet weak var viewPlugIn: UIView!
    @IBOutlet weak var collectionConnectors: UICollectionView!

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
        collectionConnectors.reloadData()
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
        NetworkManager().fetchChargerDetails(chargerId: 7) { charger, error  in
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

extension ChargerDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate{
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chargerStation?.connectors.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectorCell", for: indexPath) as? ConnectorCell
        
        let connector = self.chargerStation?.connectors[indexPath.row]
        cell?.connector = connector
        
        if connector?.type.elementsEqual("CHADEMO") ?? false {
            cell?.imgView.image = UIImage.init(named: "chdemo")
        }
        else{
            cell?.imgView.image = UIImage.init(named: "ccs")
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension ChargerDetailsViewController : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 10
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
