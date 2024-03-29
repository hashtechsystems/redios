//
//  LoginViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD
import SimpleCheckbox

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtUsername: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var checkbox: Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        self.txtUsername.delegate = self
        self.txtPassword.delegate = self
        
        self.txtUsername.text = "+1"
        //self.txtPassword.text = "123456"
        
        self.checkbox.borderStyle = .square
        self.checkbox.checkmarkStyle = .tick
        self.checkbox.checkmarkColor = .blue
        self.checkbox.valueChanged = { (isChecked) in
            UserDefaults.standard.setActiveVisit(value: isChecked)
        }
        
        self.hideKeyboardWhenTappedAround()
        
        if UserDefaults.standard.getActiveVisit(){
            self.gotoDashboard()
        }
        self.txtUsername.isSelected = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if !UserDefaults.standard.getActiveVisit(){
            self.checkbox.isChecked = false
        }
    }
}


extension LoginViewController: UITextFieldDelegate{
    
    //UITextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUsername {
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == txtUsername{
            if textField.text?.isEmpty == true {
                textField.text = "+1"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtUsername{            
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

extension LoginViewController {
    
    @IBAction func onClickLogin(){
        
        guard let phoneNumber = txtUsername.text, let password = txtPassword.text, phoneNumber.count > 0, password.count > 0 else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().login(phone_number: phoneNumber, password: password) { user, error in
            guard let _ = user else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "RED E", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.txtUsername.text = ""
                self.txtPassword.text = ""
                self.gotoDashboard()
            }
        }
    }
    
    func gotoDashboard(){
        guard let controller = UIViewController.instantiateVC(viewController: DashboardViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    @IBAction func showRegistration(_ sender: Any) {
        guard let controller = UIViewController.instantiateVC(viewController: RegistrationViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onForgetPassword(){
        guard let controller = UIViewController.instantiateVC(viewController: ForgetPasswordViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: false)
    }
}


