//
//  VerifyOTPViewController.swift
//  REDE
//
//  Created by B@db0Y on 15/03/23.
//

import UIKit
import OTPFieldView
import SVProgressHUD

class VerifyOTPViewController: UIViewController {

    @IBOutlet var otpTextFieldView: OTPFieldView!
    var phoneNumber: String = ""
    var otp: String = ""
    var dataOTP : String?
    var otpAttampt = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupOtpView()
    }

    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 4
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.defaultBorderColor = UIColor.darkGray
        self.otpTextFieldView.filledBorderColor = UIColor.systemRed
        self.otpTextFieldView.cursorColor = UIColor.blue
        self.otpTextFieldView.otpInputType = .numeric
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
}

extension VerifyOTPViewController: OTPFieldViewDelegate {

    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }

    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }

    func enteredOTP(otp otpString: String) {
        otp = otpString
    }
}

extension VerifyOTPViewController {
    
    @IBAction func onSubmitClick(){
        self.dismissKeyboard()
        
        if otp.isEmpty {
            self.showAlert(title: "RED E", message: "OTP not found!!")
            return
        }
        otpAttampt += 1
        if otp != dataOTP{            
            self.showAlert(title: "RED E", message: "Invalid OTP") {
                if self.otpAttampt > 2{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.otpTextFieldView.initializeUI()
                }
            }
        }else{
            guard let controller = UIViewController.instantiateVC(viewController: PasswordViewController.self) else { return }
            controller.phoneNumber = self.phoneNumber
            self.navigationController?.pushViewController(controller, animated: false)
        }
        //Verification is done inside this code locally so no need to check this api now.
        /*Task {
            SVProgressHUD.show()
            let response = await NetworkManager().verifyOtp(phone_number: phoneNumber, otp: otp)
            await SVProgressHUD.dismiss()
            self.showAlert(title: "RED E", message: response.1){
                if response.0 {
                    guard let controller = UIViewController.instantiateVC(viewController: PasswordViewController.self) else { return }
                    controller.phoneNumber = self.phoneNumber
                    self.navigationController?.pushViewController(controller, animated: false)
                }
            }
        }*/
    }
    
    @IBAction func onLoginClick(){
        self.navigationController?.popToRootViewController(animated: false)
    }
}
