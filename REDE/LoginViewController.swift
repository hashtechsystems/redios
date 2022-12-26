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
        
        //self.txtUsername.text = "1234567890"
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
}

extension LoginViewController {
    
    @IBAction func onClickLogin(){
        
        guard let phoneNumber = txtUsername.text, let password = txtPassword.text else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().login(phone_number: phoneNumber, password: password) { user, error in
            guard let _ = user else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.gotoDashboard()
            }
        }
    }
    
    func gotoDashboard(){
        guard let controller = UIViewController.instantiateVC(viewController: DashboardViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func showRegistration(_ sender: Any) {
        guard let controller = UIViewController.instantiateVC(viewController: RegistrationViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onForgetPassword(){
    }
}


