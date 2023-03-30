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
            if let phoneNumber = txtPhoneNumber.text, phoneNumber.isValidPhoneNumber {
                textField.resignFirstResponder()
                txtEmail.becomeFirstResponder()
            }
            else{
                self.showAlert(title: "RED E", message: "Phone Number is not valid.")
            }
        }
        else if textField == txtEmail {
            
            if let email = txtEmail.text, email.count > 0, !email.isValidEmail {
                self.showAlert(title: "RED E", message: "Email address is not valid.")
                return true
            }
            
            textField.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            if let password = txtPassword.text, password.isValidPassword {
                textField.resignFirstResponder()
            }
            else{
                self.showAlert(title: "RED E", message: "Password should be of at least 5 characters long.")
            }
        }
        return true
    }
}

extension RegistrationViewController {
    
    @IBAction func onSubmit(){
        
        guard let name = txtUsername.text, !name.isEmpty else {
            self.showAlert(title: "RED E", message: "Name cannot be empty.")
            self.txtUsername.becomeFirstResponder()
            return
        }
        
        guard let phoneNumber = txtPhoneNumber.text, phoneNumber.isValidPhoneNumber else {
            self.showAlert(title: "RED E", message: "Phone Number is not valid.")
            self.txtPhoneNumber.becomeFirstResponder()
            return
        }
        
        guard let password = txtPassword.text, password.isValidPassword else {
            self.showAlert(title: "RED E", message: "Password should be of at least 5 characters long.")
            self.txtPassword.becomeFirstResponder()
            return
        }
        
        let email = txtEmail.text ?? ""
        
        if email.count > 0 && !email.isValidEmail {
            self.showAlert(title: "RED E", message: "Email address is not valid.")
            self.txtEmail.becomeFirstResponder()
            return
        }

        SVProgressHUD.show()
        NetworkManager().register(name: name, email: email.isValidEmail ? email : "", phone_number: phoneNumber, password: password) { response, error in
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
        self.dismissKeyboard()
    }
    
    @IBAction func showLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
}

extension String {
    var isValidPhoneNumber: Bool {
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
        if let match = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count)).first?.phoneNumber {
            return match == self
        } else {
            return false
        }
    }
    
    var isValidEmail: Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: self)
        
        let emailPattern = #"^\S+@\S+\.\S+$"#
        let result = range(
            of: emailPattern,
            options: .regularExpression
        )

        let validEmail = (result != nil)
        return validEmail
    }
    
    var isValidPassword: Bool {
        let passwordPattern =
            // At least 5 characters
            #"(?=.{5,})"#
//        +
//            // At least one capital letter
//            #"(?=.*[A-Z])"# +
//            // At least one lowercase letter
//            #"(?=.*[a-z])"# +
//            // At least one digit
//            #"(?=.*\d)"# +
//            // At least one special character
//            #"(?=.*[ !$%&?._-])"#
        
        let result = range(
            of: passwordPattern,
            options: .regularExpression
        )

        let validPassword = (result != nil)
        return validPassword
    }
}
