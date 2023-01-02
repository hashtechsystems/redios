//
//  DashboardViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit

class DashboardViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class BaseViewController: UIViewController{
    
    @IBOutlet weak var navbar: NavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.hideKeyboardWhenTappedAround()
                
        self.navbar.setOnClickLeftButton {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.navbar.setOnClickRightButton {
            self.logout()
        }
    }
    
    final func logout(){
        UserDefaults.standard.clearAll()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
