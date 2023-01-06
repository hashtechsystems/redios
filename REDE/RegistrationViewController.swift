//
//  RegistrationViewController.swift
//  REDE
//
//  Created by Avishek on 05/08/22.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var txtUsername: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        self.txtUsername.delegate = self
        self.txtPhoneNumber.delegate = self
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self

        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}


extension RegistrationViewController: UITextFieldDelegate{
    
    //UITextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUsername {
            textField.resignFirstResponder()
            txtPhoneNumber.becomeFirstResponder()
        } else if textField == txtPhoneNumber {
            textField.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension RegistrationViewController {
    
    @IBAction func onSubmit(){
        
        guard let name = txtUsername.text, let password = txtPassword.text, let phoneNumber = txtPhoneNumber.text else {
            return
        }
        
        let email = txtEmail.text ?? ""
        
        SVProgressHUD.show()
        NetworkManager().register(name: name, email: email, phone_number: phoneNumber, password: password) { response, error in
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "RED E", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showAlert(title: "RED E", message: response){
                    self.txtUsername.text = ""
                    self.txtPhoneNumber.text = ""
                    self.txtEmail.text = ""
                    self.txtPassword.text = ""
                    self.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func showLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
}


