//
//  ForgetPasswordViewController.swift
//  REDE
//
//  Created by Avishek Chakraborty on 15/03/23.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD


class ForgetPasswordViewController: UIViewController {
    
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextFieldWithIcon!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        self.txtPhoneNumber.keyboardType = .default
        self.txtPhoneNumber.addDoneCancelToolbar(onDone: (target: self, action: #selector(self.onSubmitClick(_:))), onCancel: (target: self, action: #selector(self.dismissKeyboard)))
        self.txtPhoneNumber.text = "+1"
        self.txtPhoneNumber.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onSubmitClick(_ sender: Any) {
        
        if let phoneNumber = txtPhoneNumber.text, phoneNumber.isValidPhoneNumber {
            self.dismissKeyboard()
            
            
            Task {
                SVProgressHUD.show()
                let response = await NetworkManager().generateOtp(phone_number: phoneNumber)
                await SVProgressHUD.dismiss()
                if response.0{
                    guard let controller = UIViewController.instantiateVC(viewController: VerifyOTPViewController.self) else { return }
                    controller.dataOTP = response.1 ?? ""
                    controller.phoneNumber = phoneNumber
                    self.navigationController?.pushViewController(controller, animated: false)
                }else{
                    self.showAlert(title: "RED E", message: response.1)
                }
            }
        }
        else{
            self.showAlert(title: "RED E", message: "Phone Number is not valid.")
        }
    }

    @IBAction func onLoginClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
}
extension ForgetPasswordViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == txtPhoneNumber{
            if textField.text?.isEmpty == true {
                textField.text = "+1"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhoneNumber{
            if textField.text?.isEmpty == true && string.isEmpty {
                textField.text = "+1"
                return false
            } else if textField.text == "+1" {
                textField.text = "+1" + string
                return false
            }
        }
        return true
    }
}
extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
