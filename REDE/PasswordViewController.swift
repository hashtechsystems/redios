//
//  PasswordViewController.swift
//  REDE
//
//  Created by Avishek Chakraborty on 15/03/23.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD

class PasswordViewController: UIViewController {

    @IBOutlet weak var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtConfirmPassword: SkyFloatingLabelTextFieldWithIcon!

    var phoneNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

}

extension PasswordViewController: UITextFieldDelegate{
    
    //UITextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtPassword {
            if let password = txtPassword.text, password.isValidPassword {
                textField.resignFirstResponder()
                txtConfirmPassword.becomeFirstResponder()
            }
            else{
                self.showAlert(title: "RED E", message: "Password should be of at least 5 characters long.")
            }
        } else if textField == txtConfirmPassword {
            if let password = txtPassword.text, let confirmPassword = txtConfirmPassword.text, password.elementsEqual(confirmPassword) {
                textField.resignFirstResponder()
            }
            else{
                self.showAlert(title: "RED E", message: "Password & Confirm Password does not match.")
            }
        }
        return true
    }
    
    @IBAction func onConfirmClick(){
        
        guard let password = txtPassword.text, let confirmPassword = txtPassword.text, password.isValidPassword else {
            self.showAlert(title: "RED E", message: "Password should be of at least 5 characters long.")
            return
        }
        
        if !password.elementsEqual(confirmPassword) {
            self.showAlert(title: "RED E", message: "Password & Confirm Password does not match.")
            return
        }
        
        Task {
            SVProgressHUD.show()
            let response = await NetworkManager().resetPassword(phone_number: phoneNumber, password: password, confirmPassword: confirmPassword)
            await SVProgressHUD.dismiss()
            if response.0 {
                self.showAlert(title: "RED E", message: response.1){
                    self.navigationController?.popToRootViewController(animated: false)
                }
            }else{
                self.showAlert(title: "RED E", message: response.1)
            }
            
        }
        
    }
    
    @IBAction func onLoginClick(){
        self.navigationController?.popToRootViewController(animated: false)
    }
}
