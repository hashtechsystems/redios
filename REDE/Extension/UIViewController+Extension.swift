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
