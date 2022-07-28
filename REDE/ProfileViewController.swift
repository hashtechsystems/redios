//
//  ProfileViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit
import AlamofireImage

class ProfileViewController: BaseViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgvwProfile: UIImageView!
    
    lazy var user: User? = {
        return UserDefaults.standard.getUser()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        self.enableEdit(enable: false)
        
        self.navbar.isLeftButtonHidden = true
        
        updateUI(user: self.user)
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
    
    func updateUI(user: User?){
        self.txtName.text = user?.name
        self.txtEmail.text = user?.email
        self.txtPhone.text = user?.phoneNumber
        //self.txtAddress.text = user.
        
        guard let user = user else {
            return
        }

        let url = URL(string: "\(user.imagePath)/\(user.profilePic)")!
        self.imgvwProfile.af.setImage(withURL: url)
    }
    
    @IBAction func onEditPicture(_ sender: UIButton) {
        if btnEdit.isSelected {
            print(#function)
        }
    }
}
