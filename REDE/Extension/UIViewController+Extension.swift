//
//  UIViewController+Extension.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit

extension UIViewController {
   
    class func instantiateVC<T>(viewController: T.Type, storyboardName: String = "Main") -> T? where T: UIViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: String(describing: viewController.self))
        return destinationVC as? T
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String?, message: String?, completion:@escaping (()->()) = {} ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { _ in
            completion()
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

private var kAssociationKeyMaxLength: Int = 0
extension UITextField {
    @IBInspectable var maxLength: Int {
            get {
                if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                    return length
                } else {
                    return Int.max
                }
            }
            set {
                objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
                self.addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
            }
        }
        func isInputMethod() -> Bool {
            if let positionRange = self.markedTextRange {
                if let _ = self.position(from: positionRange.start, offset: 0) {
                    return true
                }
            }
            return false
        }


       @objc func checkMaxLength(textField: UITextField) {

            guard !self.isInputMethod(), let prospectiveText = self.text,
                prospectiveText.count > maxLength
            else {
                return
            }

            let selection = selectedTextRange
            let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
            text = prospectiveText.substring(to: maxCharIndex)
            selectedTextRange = selection
        }
}
