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
        //        self.txtUsername.text = "neeta12@gmail.com"
        //        self.txtPassword.text = "Neetaj44@"
        
        self.checkbox.borderStyle = .square
        self.checkbox.checkmarkStyle = .tick
        self.checkbox.checkmarkColor = .blue
        self.checkbox.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
        
        guard let controller = UIViewController.instantiateVC(viewController: DashboardViewController.self) else { return }
        self.navigationController?.pushViewController(controller, animated: true)
        
        /*guard let username = txtUsername.text, let pin = txtPassword.text else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().login(username: username, pin: pin) { career, error in
            guard let career = career else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Error", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard let controller = UIViewController.instantiateVC(viewController: EventListViewController.self), let sceneDelegate = UIApplication.shared.connectedScenes
                    .first?.delegate as? SceneDelegate else { return }
                controller.career = career
                let navCntrl = UINavigationController.init(rootViewController: controller)
                navCntrl.isNavigationBarHidden = true
                sceneDelegate.window?.rootViewController = navCntrl
            }
        }*/
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
}


