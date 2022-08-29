//
//  ChargerDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit
import SVProgressHUD
import AnimatedCardInput
import AuthorizeNetAccept

class ChargerDetailsViewController: BaseViewController {
    
    private let kClientName = "5KP3u95bQpv"
    private let kClientKey  = "2NU5ph424e5PjZ57p76PquLtBj9MT2smPCKpm43NEFhZ4gr8358zpG5dtBJSy2Qf"
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var viewPlugIn: UIView!
    @IBOutlet weak var collectionConnectors: UICollectionView!
    
    var qrCode: String?
    fileprivate var chargerStation:ChargerStation?
    private var selectedCellIndex: Int?
    
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
        
        guard let index = selectedCellIndex, let connector = self.chargerStation?.connectors[index] else {
            self.showAlert(title: "Error", message: "Please select connector")
            return
        }
        
       // if self.chargerStation?.site?.pricePlanId != nil {
            guard let controller = UIViewController.instantiateVC(viewController: AuthorizePaymentViewController.self) else { return }
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
//        }
//        else{
//
//        }
        
        /*self.viewPlugIn.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            guard let controller = UIViewController.instantiateVC(viewController: StopChargingViewController.self) else { return }
            self.navigationController?.pushViewController(controller, animated: true)
        }*/
    }
}

extension ChargerDetailsViewController {
    
    func fetchChargerDetails(){
        
        guard let qrCode = self.qrCode else { return }
        
        SVProgressHUD.show()
        NetworkManager().fetchChargerDetails(qrCode: qrCode) { charger, error  in
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
        
        cell?.isSelected = false
        
        if selectedCellIndex != indexPath.item {
            cell?.toggleSelected()
        }
        
        if connector?.type.elementsEqual("CHADEMO") ?? false {
            cell?.imgView.image = UIImage.init(named: "chdemo")
        }
        else{
            cell?.imgView.image = UIImage.init(named: "ccs")
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ConnectorCell
        cell.isSelected = true
        selectedCellIndex = indexPath.item
        cell.toggleSelected()
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
        return 10
    }
}

extension ChargerDetailsViewController : AuthorizePaymentDelegate{
 
    func creditCardData(data: CreditCardData?) {
        guard let card = data else{
            return
        }

        let arr = card.validityDate.components(separatedBy: "/")
        guard arr.count == 2, let month = arr.first, let year = arr.last else{
            return
        }
       
        self.getToken(cardNumber: card.cardNumber, expirationMonth: month, expirationYear: year, cardCode: card.CVVNumber)
    }
    
    func getToken(cardNumber: String, expirationMonth: String, expirationYear: String, cardCode: String) {
        
        let handler = AcceptSDKHandler(environment: AcceptSDKEnvironment.ENV_TEST)
        
        let request = AcceptSDKRequest()
        request.merchantAuthentication.name = kClientName
        request.merchantAuthentication.clientKey = kClientKey
        
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = cardNumber
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = expirationMonth
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = expirationYear
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = cardCode
        
        SVProgressHUD.dismiss()

        handler!.getTokenWithRequest(request, successHandler: { (inResponse:AcceptSDKTokenResponse) -> () in
            
            print("Token--->%@", inResponse.getOpaqueData().getDataValue())
            var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
            output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
            print(output)
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
        }) { (inError:AcceptSDKErrorResponse) -> () in
            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            print(output)
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
}
