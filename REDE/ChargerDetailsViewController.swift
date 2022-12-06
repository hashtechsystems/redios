//
//  ChargerDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit
import PassKit
import SVProgressHUD
import AnimatedCardInput
import AuthorizeNetAccept

class ChargerDetailsViewController: BaseViewController {
    
    @objc let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]

    
//    private let kClientName = "6938BCtt6n8"//"5KP3u95bQpv"
//    private let kClientKey  = "2NU5ph424e5PjZ57p76PquLtBj9MT2smPCKpm43NEFhZ4gr8358zpG5dtBJSy2Qf"

    let kClientName = "8eeT945T5"
    let kClientKey  = "5nKXgA5vg93r5A95drWZy246Ja32rS85nQv2N8HahH2Dum94B63HR3M8wsA5eBs2"

    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var viewPlugIn: UIView!
    @IBOutlet weak var collectionConnectors: UICollectionView!
    
    var qrCode: String?
    fileprivate var chargerStation:ChargerStation?
    fileprivate var transaction: Transaction?
    fileprivate var authId: String?
    
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
        
        guard let index = selectedCellIndex, let _ = self.chargerStation?.connectors[index] else {
            self.showAlert(title: "Error", message: "Please select connector")
            return
        }
        
        if self.chargerStation?.site?.pricePlanId != nil {
            guard let controller = UIViewController.instantiateVC(viewController: AuthorizePaymentViewController.self) else { return }
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
        else{
            self.startCharging()
        }
        
    }
    
    func gotoStopCharging(){
        
        self.viewPlugIn.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            guard let controller = UIViewController.instantiateVC(viewController: StopChargingViewController.self) else { return }
            controller.chargerStation = self.chargerStation
            controller.transaction = self.transaction
            controller.authId = self.authId
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
                    self.showAlert(title: "Error", message: error){
                        self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                    }
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
        
        if connector?.type.elementsEqual("CHADEMO") ?? false {
            cell?.imgView.image = UIImage.init(named: "chdemo")
        }
        else{
            cell?.imgView.image = UIImage.init(named: "ccs")
        }
        
        if let index = selectedCellIndex,  index == indexPath.item {
            cell?.showCheck()
        }
        else{
            cell?.hideCheck()
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = selectedCellIndex {
            selectedCellIndex = nil
        }
        else{
            selectedCellIndex = indexPath.item
        }
        collectionView.reloadData()
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
        
        let handler = AcceptSDKHandler(environment: AcceptSDKEnvironment.ENV_LIVE)
        
        let request = AcceptSDKRequest()
        request.merchantAuthentication.name = kClientName
        request.merchantAuthentication.clientKey = kClientKey
        
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = cardNumber
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = expirationMonth
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = expirationYear
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = cardCode
        
        SVProgressHUD.show()

        handler!.getTokenWithRequest(request, successHandler: { (inResponse:AcceptSDKTokenResponse) -> () in
            
            print("Token--->%@", inResponse.getOpaqueData().getDataValue())
            
            var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
            output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
            print(output)
            
            self.makePayment(cardNumber: cardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, token: inResponse.getOpaqueData().getDataValue())
            
        }) { (inError:AcceptSDKErrorResponse) -> () in
            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            print(output)
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Error", message: output){
                    self.onClickConfirm()
                }
            }
        }
        
        /*let supportedNetworks = [ PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa ]
        
        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) == false {
            let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }

        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.rede.network"
        request.supportedNetworks = SupportedPaymentNetworks
        // DO NOT INCLUDE PKMerchantCapability.capabilityEMV
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: 1.00)
        ]

        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        
        self.present(applePayController!, animated: true, completion: nil)*/
    }
}

extension ChargerDetailsViewController{
    
    func makePayment(cardNumber: String, expirationMonth: String, expirationYear: String, token: String){
        
        guard let qrCode = self.qrCode else{
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            return
        }
        
        NetworkManager().makePayment(qrCode: qrCode, /*cardDate: "\(expirationYear)-\(expirationMonth)", cardNumber: cardNumber,*/ cryptogram: token) { success, authId, error in

            if let authId = authId, success {
                self.authId = authId
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.startCharging()
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error){
                        self.onClickConfirm()
                    }
                }
            }
        }
    }
    
    func startCharging(){
        guard let ocppCbid = self.chargerStation?.ocppCbid else {
            return
        }

        SVProgressHUD.show()
        NetworkManager().startCharging(ocppCbid: ocppCbid) { transaction, error in
            guard let transaction = transaction else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error){
                        self.onClickConfirm()
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.transaction = transaction
                self.gotoStopCharging()
            }
        }
    }
}


extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

/*
extension ChargerDetailsViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")

        if payment.token.paymentData.count > 0 {
            let base64str = self.base64forData(payment.token.paymentData)
            let messsage = String(format: "Data Value: %@", base64str)
            let alert = UIAlertController(title: "Authorization Success", message: messsage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        } else {
            let alert = UIAlertController(title: "Authorization Failed!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        }
    }
    
    @objc func performApplePayCompletion(_ controller: PKPaymentAuthorizationViewController, alert: UIAlertController) {
        controller.dismiss(animated: true, completion: {() -> Void in
            self.present(alert, animated: false, completion: nil)
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    @objc func base64forData(_ theData: Data) -> String {
        let charSet = CharacterSet.urlQueryAllowed

        let paymentString = NSString(data: theData, encoding: String.Encoding.utf8.rawValue)!.addingPercentEncoding(withAllowedCharacters: charSet)
        
        return paymentString!
    }
}*/
