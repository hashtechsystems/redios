//
//  ProfileViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var navbar: NavigationBar!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgvwProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.hideKeyboardWhenTappedAround()
        
        self.enableEdit(enable: false)
        
        self.navbar.setOnClickLeftButton {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    @IBAction func onEdit(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.setTitle("Edit", for: .normal)
            sender.setTitle("Edit", for: .selected)
        }
        else{
            sender.isSelected = true
            sender.setTitle("Done", for: .normal)
            sender.setTitle("Done", for: .selected)
        }
        self.enableEdit(enable: sender.isSelected)
        self.view.endEditing(true)
    }
    
    func enableEdit(enable: Bool) {
        self.txtName.isUserInteractionEnabled = enable
        self.txtEmail.isUserInteractionEnabled = enable
        self.txtPhone.isUserInteractionEnabled = enable
        self.txtAddress.isUserInteractionEnabled = enable
    }
    
    @IBAction func onEditPicture(_ sender: UIButton) {
        if btnEdit.isSelected {
            print(#function)
        }
    }
}
