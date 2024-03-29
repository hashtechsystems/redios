//
//  ChargerDetailsViewController.swift
//  REDE
//
//  Created by Avishek on 21/07/22.
//

import UIKit
//import PassKit
import SVProgressHUD
import AnimatedCardInput
import AuthorizeNetAccept

import PassKit
import Alamofire
class ChargerDetailsViewController: BaseViewController {
    
    @objc let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    
    //    private let kClientName = "6938BCtt6n8"//"5KP3u95bQpv"
    //    private let kClientKey  = "2NU5ph424e5PjZ57p76PquLtBj9MT2smPCKpm43NEFhZ4gr8358zpG5dtBJSy2Qf"
    
    let kClientKey  = "5nKXgA5vg93r5A95drWZy246Ja32rS85nQv2N8HahH2Dum94B63HR3M8wsA5eBs2"
    let kClientName = "8eeT945T5" // This is API Login ID
    let kClientTransationKey  = "7aBFH3a37p49nc92"
    let ApplePayMerchantID = "merchant.redecharge.com"
    let kAuthorisedAPI =  "https://api.authorize.net/" //"https://apitest.authorize.net/"
    var aryCreatePayProf = [String:Any]()
    @IBOutlet  var imgDotLine: [UIImageView]!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblSessionfee: UILabel!
    @IBOutlet weak var lblvariablefee: UILabel!
    @IBOutlet weak var lblparkingfee: UILabel!
    @IBOutlet weak var lblbuffertime: UILabel!
    @IBOutlet weak var lblNoInfoFound: UILabel!
    @IBOutlet weak var vwPriceInfo: UIView!
    @IBOutlet weak var collectionConnectors: UICollectionView!
    @IBOutlet weak var heightofImage: NSLayoutConstraint!
    
    var qrCode: String?
    fileprivate var chargerStation:ChargerStation?
    fileprivate var transaction: Transaction?
    fileprivate var authId: String?
    
    private var selectedCellIndex: Int?
    private let margin: CGFloat = 4
    var tryAgainCount = 0
    var isChargingSlotFree = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.isRightButtonHidden = true
        self.fetchChargerDetails()
        
        //        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        let width = UIScreen.main.bounds.width
        //        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        //        layout.itemSize = CGSize(width: 128, height: 142)
        //        layout.minimumInteritemSpacing = 0
        //        layout.minimumLineSpacing = 0
        //        collectionConnectors.collectionViewLayout = layout
        
        guard let flowLayout = collectionConnectors.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        let image = UIImage(named: "dotted_line")?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(.red)
        for imgview in imgDotLine{
            imgview.image = image
        }
        if screenHeight < 700 {
            heightofImage.constant = 30
        }else{
            heightofImage.constant = 80
        }
        
    }
    
    func updateUI(){
        lblLocation.text = chargerStation?.site?.getFullAdress()
        lblId.text = chargerStation?.name
        collectionConnectors.reloadData()
        collectionConnectors.allowsSelection = true
        if chargerStation?.chargerType == "DC"{
            if let plan = chargerStation?.site?.price_plan{
                lblSessionfee.text = "$\(plan.fixed_fee ?? 0)"
                lblvariablefee.text =  (plan.variable_fee ?? 0.0) > 0.0 ? "$\(plan.variable_fee ?? 0) / KWH DC unit" : "NONE"
                lblparkingfee.text =  (plan.parking_fee ?? 0) > 0 ?  "$\(plan.parking_fee ?? 0) / \(plan.parking_fee_unit ?? "")" : "NONE"
                lblbuffertime.text =  (plan.buffer_time ?? 0) > 0 ? "$\(plan.buffer_time ?? 0)" : "NONE"
                self.vwPriceInfo.isHidden = false
                self.lblNoInfoFound.isHidden = true
            }else{
                self.vwPriceInfo.isHidden = true
                self.lblNoInfoFound.isHidden = false
            }
        }else{
            if let plan = chargerStation?.site?.ac_price_plan{
                lblSessionfee.text = "$\(plan.fixed_fee ?? 0)"
                lblvariablefee.text =  (plan.variable_fee ?? 0.0) > 0.0 ? "$\(plan.variable_fee ?? 0) / KWH AC unit" : "NONE"
                lblparkingfee.text =  (plan.parking_fee ?? 0) > 0 ?  "$\(plan.parking_fee ?? 0) / \(plan.parking_fee_unit ?? "")" : "NONE"
                lblbuffertime.text =  (plan.buffer_time ?? 0) > 0 ? "\(plan.buffer_time ?? 0)" : "NONE"
                self.vwPriceInfo.isHidden = false
                self.lblNoInfoFound.isHidden = true
            }else{
                self.vwPriceInfo.isHidden = true
                self.lblNoInfoFound.isHidden = false
            }
        }
    }
}

extension ChargerDetailsViewController {
    
    @IBAction func onClickConfirm(){
        guard let index = self.selectedCellIndex, let _ = self.chargerStation?.connectors[index] else {
            self.showAlert(title: "RED E", message: "Select a connector")
            return
        }
        
        if self.chargerStation?.pricePlanId != nil {
            self.checkRfidForLoggedInUser()
        }
        else{
            self.startCharging()
        }
     
    }
    
    func openActionSheet(){
        let alert:UIAlertController=UIAlertController(title: "Choose Payment Type", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let applePayAction = UIAlertAction(title: "Apple Pay", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.btnApplePayTapped()
        }
        let CardAction = UIAlertAction(title: "Credit Card/Debit Card", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.getCardList()
//            self.openCardPayment()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(applePayAction)
        alert.addAction(CardAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openCardPayment(){
        guard let controller = UIViewController.instantiateVC(viewController: AuthorizePaymentViewController.self) else { return }
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func gotoStopCharging(){
        guard let controller = UIViewController.instantiateVC(viewController: StopChargingViewController.self) else { return }
        controller.chargerStation = self.chargerStation
        controller.transaction = self.transaction
        controller.authId = self.authId
        controller.isChargingSlotFree = self.isChargingSlotFree
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoLastScreen(){
        //self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChargerDetailsViewController {
    
    func checkRfidForLoggedInUser(){
        SVProgressHUD.show()
        NetworkManager().checkRfidForUser(siteId: self.chargerStation?.siteID ?? 0, chargerId: self.chargerStation?.id ?? 0) { response, error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if response?.status ?? false {
                    self.isChargingSlotFree = true
                    self.startCharging()
                }else{
                    self.openActionSheet()
                }
            }
        }
    }
    func fetchChargerDetails(){
        
        guard let qrCode = self.qrCode else { return }
        
        SVProgressHUD.show()
        NetworkManager().fetchChargerDetails(qrCode: qrCode) { charger, error  in
            guard let _ = charger else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error){
                            self.gotoLastScreen()
                        }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chargerStation?.connectors.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectorCell", for: indexPath) as? ConnectorCell
        
        let connector = self.chargerStation?.connectors[indexPath.row]
        
        cell?.lblOutputPower.text = "\(connector?.connector_output ?? 0) KW"
        
        if connector?.type.elementsEqual("CHADEMO") ?? false {
            cell?.imgView.image = UIImage.init(named: "chademo_1")
        } else if connector?.type.elementsEqual("J1772") ?? false {
            cell?.imgView.image = UIImage.init(named: "j1772")
        }else if connector?.type.elementsEqual("CCS A") ?? false {
            cell?.imgView.image = UIImage.init(named: "ccs_a")
        }else if connector?.type.elementsEqual("CCS B") ?? false {
            cell?.imgView.image = UIImage.init(named: "ccs_b")
        }else{
            cell?.imgView.image = UIImage.init(named: "ccs")
        }
        if connector?.status == "AVAILABLE" {
            if let index = selectedCellIndex,  index == indexPath.item {
                cell?.showCheck()
            }
            else{
                cell?.hideCheck()
            }
        }else{
            cell?.makeConnectorUnavailable()
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let connector = self.chargerStation?.connectors[indexPath.row]
        if connector?.status != "AVAILABLE" {
            // Not available
        }else{
            if indexPath.item == selectedCellIndex {
                selectedCellIndex = nil
            }
            else{
                selectedCellIndex = indexPath.item
            }
            collectionView.reloadData()
        }
    }
}

extension ChargerDetailsViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2  //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 100)
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
        
        guard let index = selectedCellIndex, let connector = self.chargerStation?.connectors[index] else {
            return
        }
        
        self.getToken(cardNumber: card.cardNumber, expirationMonth: month, expirationYear: year, cardCode: card.CVVNumber, connectorId: connector.id)
    }
    
    func getToken(cardNumber: String, expirationMonth: String, expirationYear: String, cardCode: String, connectorId: Int) {
        
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
            
            //print("Token--->%@", inResponse.getOpaqueData().getDataValue())
            
            var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
            output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
            //print(output)
            
            self.makePayment(cardNumber: cardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, token: inResponse.getOpaqueData().getDataValue(), connectorId: connectorId)
            
        }) { (inError:AcceptSDKErrorResponse) -> () in
            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            //print(output)
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showAlert(title: "RED E", message: output){
                    if self.chargerStation?.pricePlanId != nil {
                        //self.openCardPayment()
                        self.getCardList()
                    }
                }
            }
        }
    }
}
extension ChargerDetailsViewController : SavedCardListDelegate{
    func OpenCardView() {
        self.openCardPayment()
    }
    
    func payWithCard(id: Int) {
        self.chargeSelectedCard(id: id)
    }
}

//MARK: Save Card Info Flow
extension ChargerDetailsViewController{
    // Create this method to charge customer using saved credit card id and call server api to send selected credit card Id.
    func chargeSelectedCard(id : Int){
        SVProgressHUD.show()
        NetworkManager().ChargeCustomerWithSavedCard(id: id, qrcode: self.qrCode ?? "") { response, error in
            if let authId = response?.authId {
                self.authId = authId
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.startCharging()
                }
            }
            else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error){}
                    }
                }
            }
        }
    }
    
    func openSavedCardList(list : [CreditCard]){
        guard let controller = UIViewController.instantiateVC(viewController: SavedCardListViewController.self) else { return }
        controller.cardList = list
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Get all saved credit card list from server
    func getCardList(){
        SVProgressHUD.show()
        NetworkManager().getSavedCardList { response, error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard let data = response else{
                return
            }
            if data.count == 0{
                DispatchQueue.main.async {
                    self.openCardPayment()
                }
            }else{
                DispatchQueue.main.async {
                    self.openSavedCardList(list: data)
                }
            }
        }
    }
}

extension ChargerDetailsViewController{

    func makePayment(cardNumber: String, expirationMonth: String, expirationYear: String, token: String, connectorId: Int){
        
        guard let qrCode = self.qrCode else{
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            return
        }
        
        NetworkManager().makePayment(qrCode: qrCode, /*cardDate: "\(expirationYear)-\(expirationMonth)", cardNumber: cardNumber,*/ cryptogram: token, connectorId: connectorId) { success, authId, error in
            
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
                    
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error){
                            if self.chargerStation?.pricePlanId != nil {
//                                self.openCardPayment()
                                self.getCardList()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startCharging(){
        guard let ocppCbid = self.chargerStation?.ocppCbid, let index = selectedCellIndex, let connector = self.chargerStation?.connectors[index] else {
            return
        }
        
        let authId = self.authId ?? ""
        
        SVProgressHUD.show()
        NetworkManager().startCharging(ocppCbid: ocppCbid, sequenceNumber: connector.sequence_number, authId: authId) { transaction, error in
            guard let transaction = transaction, transaction.transactionId > 0 else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    //                    self.showAlert(title: "RED E", message: "Some error occurred"){
                    //                        self.gotoLastScreen()
                    //                    }
                    
                    let alert = UIAlertController(title: "RED E", message: "Some error occurred", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction.init(title: "Try again", style: .default, handler: { _ in
                        if self.tryAgainCount >= 3{
                            
                            if self.chargerStation?.pricePlanId != nil {
                                self.mobilePaymentSettlement()
                            }else{
                                self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                            }
                            
                        }else{
                            self.tryAgainCount += 1
                            self.startCharging()
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { _ in
                        if self.chargerStation?.pricePlanId != nil {
                            self.mobilePaymentSettlement()
                        }else{
                            self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.transaction = transaction
                if self.chargerStation?.pricePlanId != nil && self.isChargingSlotFree != true{
                    self.updatePayment()
                }else{
                    self.gotoStopCharging()
                }
                
            }
        }
    }
    
    func startFreeCharging(){
        guard let ocppCbid = self.chargerStation?.ocppCbid, let index = selectedCellIndex, let connector = self.chargerStation?.connectors[index] else {
            return
        }
        
        let authId = self.authId ?? ""
        
        SVProgressHUD.show()
        NetworkManager().startCharging(ocppCbid: ocppCbid, sequenceNumber: connector.sequence_number, authId: authId) { transaction, error in
            guard let transaction = transaction, transaction.transactionId > 0 else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    //                    self.showAlert(title: "RED E", message: "Some error occurred"){
                    //                        self.gotoLastScreen()
                    //                    }
                    
                    let alert = UIAlertController(title: "RED E", message: "Some error occurred", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction.init(title: "Try again", style: .default, handler: { _ in
                        if self.tryAgainCount >= 3{
                            
                            if self.chargerStation?.pricePlanId != nil {
                                self.mobilePaymentSettlement()
                            }else{
                                self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                            }
                            
                        }else{
                            self.tryAgainCount += 1
                            self.startCharging()
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { _ in
                        if self.chargerStation?.pricePlanId != nil {
                            self.mobilePaymentSettlement()
                        }else{
                            self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.transaction = transaction
                self.gotoStopCharging()
//                if self.chargerStation?.pricePlanId != nil {
//                    self.updatePayment()
//                }else{
//                    self.gotoStopCharging()
//                }
                
            }
        }
    }
    
    func getChargingProgressDetails(){
        
        guard let transactionId = self.transaction?.transactionId else {
            return
        }
        SVProgressHUD.show()
        NetworkManager().getTransactionDetails(transactionId: transactionId) { [unowned self] data, error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard var transaction = data?.data else {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
                }
                return
            }
            
            DispatchQueue.main.async {
                if (error?.elementsEqual("Your session has been expired.") ?? false){
                    self.showAlert(title: "RED E", message: "Your session has been expired.") {
                        self.logout()
                    }
                }
                else{
                    if (transaction.connectorStatus?.uppercased().elementsEqual("CHARGING") ?? false)
                        || (transaction.connectorStatus?.uppercased().elementsEqual("SUSPENDEDEVSE") ?? false)
                        || (transaction.connectorStatus?.uppercased().elementsEqual("SUSPENDEDEV") ?? false)
                        ||
                        (transaction.connectorStatus?.uppercased().elementsEqual("PREPARING") ?? false){
                        self.gotoStopCharging()
                    }
                }
            }
        }
    }
    func mobilePaymentSettlement(){
        guard let authId = self.authId else {
            return
        }
        SVProgressHUD.show()
        NetworkManager().mobilePaymentSettlementAPI(authId: authId) { response, error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.navigationController?.popToViewController(ofClass: DashboardViewController.self)
            }
        }
    }
    func updatePayment(){
        
        guard let authId = self.authId, let transactionId = self.transaction?.transactionId else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().updatePaymentWithTransaction(authId: authId, sessionId: transactionId) { response, error in
            
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error){
                            self.gotoLastScreen()
                        }
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if response.status{
                    self.gotoStopCharging()
                }
                else{
                    self.showAlert(title: "RED E", message: response.data){
                        self.gotoLastScreen()
                    }
                }
            }
        }
    }
}
//MARK: Apple Pay
extension ChargerDetailsViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")
        // completion(PKPaymentAuthorizationStatus.success)
        if payment.token.paymentData.count > 0 {
//            let base64str = self.base64forData(payment.token.paymentData)
//            let message = String(format: "Data Value: %@", base64str)
//            let alert = UIAlertController(title: "Authorization Success", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            completion(PKPaymentAuthorizationStatus.success)
            //call api
            self.MakeApplePayment(payment: payment)
        } else {
            let alert = UIAlertController(title: "Authorization Failed!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            completion(PKPaymentAuthorizationStatus.failure)
            return self.performApplePayCompletion(controller, alert: alert)
        }
    }
    
    //MARK: apple payment is finished then this method calls
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
    
    func MakeApplePayment(payment: PKPayment)
    {
        SVProgressHUD.show()
        let token = payment.token.paymentData.base64EncodedString()
        NetworkManager().makeApplePayment(qrCode: self.qrCode ?? "", cryptogram: token) { success, authId, error in
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
                    
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error){}
                    }
                }
            }
        }
    }
}


extension ChargerDetailsViewController {
    func shippingMethodCalculator() -> [PKShippingMethod] {
        // Calculate the pickup date.
        
        let today = Date()
        let calendar = Calendar.current
        
        let shippingStart = calendar.date(byAdding: .day, value: 3, to: today)!
        let shippingEnd = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
        let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
        
        let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
        shippingDelivery.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
        shippingDelivery.detail = "Ticket sent to you address"
        shippingDelivery.identifier = "DELIVERY"
        
        let shippingCollection = PKShippingMethod(label: "Collection", amount: NSDecimalNumber(string: "0.00"))
        shippingCollection.detail = "Collect ticket at festival"
        shippingCollection.identifier = "COLLECTION"
        
        return [shippingDelivery, shippingCollection]
    }
    func btnApplePayTapped() {
        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }
        
        //checks apple pay is available then opens wallet app
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks) == false {
            openWalletApp()
        }
        //        let tempDict = cartDetailsFetch?.value(forKey: "data") as! Dictionary <String, Any>
        var totalPay : NSDecimalNumber?
        
        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.shippingType = .delivery
        request.shippingMethods = shippingMethodCalculator()
        request.requiredShippingContactFields = [.name, .postalAddress]
        let amount = self.chargerStation?.planPrice ?? 0
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: amount))
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        self.present(applePayController!, animated: true, completion: nil)
    }
    //opens wallet app
    func openWalletApp() {
        let library = PKPassLibrary()
        library.openPaymentSetup()
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
