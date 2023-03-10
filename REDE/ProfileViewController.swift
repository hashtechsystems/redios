//
//  ProfileViewController.swift
//  REDE
//
//  Created by Avishek on 25/06/22.
//

import UIKit
import AlamofireImage
import SVProgressHUD

class ProfileViewController: BaseViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgvwProfile: UIImageView!
    @IBOutlet weak var imgvwEditIcon: UIImageView!
    
    lazy var user: User? = {
        return UserDefaults.standard.getUser()
    }()
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtName.delegate = self
        self.txtEmail.delegate = self
        self.txtPhone.delegate = self
        self.txtAddress.delegate = self
        
        self.enableEdit(enable: false)
        
        self.navbar.isLeftButtonHidden = true
        
        let image = UIImage(systemName: "person.circle.fill")
        self.imgvwProfile.image = image
        
        updateUI(user: self.user)
    }
    
    
    @IBAction func onEdit(_ sender: UIButton) {
        if sender.isSelected {
            self.view.endEditing(true)
            sender.isSelected = false
            sender.setTitle("Edit", for: .normal)
            sender.setTitle("Edit", for: .selected)
            self.updateProfile()
        }
        else{
            sender.isSelected = true
            sender.setTitle("Done", for: .normal)
            sender.setTitle("Done", for: .selected)
        }
        self.enableEdit(enable: sender.isSelected)
    }
    
    func enableEdit(enable: Bool) {
        self.txtName.isUserInteractionEnabled = enable
        self.txtEmail.isUserInteractionEnabled = enable
        self.txtPhone.isUserInteractionEnabled = enable
        self.txtAddress.isUserInteractionEnabled = enable
        self.imgvwEditIcon.isHidden = !enable
        
        if enable {
            self.txtName.becomeFirstResponder()
        }
    }
    
    func updateUI(user: User?){
        self.txtName.text = user?.name
        self.txtEmail.text = user?.email
        self.txtPhone.text = user?.phoneNumber
        self.txtAddress.text = user?.address
        
//        guard let _imagePath = user?.imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//        let _fileName = user?.profilePic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//        let url = URL(string: "\(_imagePath)/\(_fileName)") else {
//            return
//        }
//        self.imgvwProfile.af.setImage(withURL: url)
    }
    
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Profile ?", message: "Deleting profile will permanently remove your profile data.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "Delete Profile", style: .destructive, handler: { _ in
            self.deleteUserProfile()
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEditPicture(_ sender: UIButton) {
        /*if btnEdit.isSelected {
            
            let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.camera)
            }
            let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.photoLibrary)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
            }
            
            // Add the actions
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }*/
    }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgvwProfile.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        
        var selectedImage: UIImage?
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        }

        guard let selectedImage = selectedImage else { return }
        self.imgvwProfile.image = selectedImage
        self.uploadProfilePic(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITextFieldDelegate{
    
    //UITextField delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtName {
            txtName.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        } else if textField == txtEmail {
            txtEmail.resignFirstResponder()
            txtPhone.becomeFirstResponder()
        } else if textField == txtPhone {
            txtPhone.resignFirstResponder()
            txtAddress.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
}


extension ProfileViewController {
    
    func updateProfile(){
        
        guard let id = user?.id, let name = txtName.text, let email = txtEmail.text, let phoneNumber = txtPhone.text, let address = txtAddress.text else {
            return
        }
        
        SVProgressHUD.show()
        NetworkManager().updateProfile(id: id, name: name, email: email, phone_number: phoneNumber, address: address) { response, error in
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.updateUI(user: self.user)
                    self.showAlert(title: "RED E", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showAlert(title: "RED E", message: response) {
                    self.getUserProfile()
                }
            }
        }
    }
    
    func uploadProfilePic(image: UIImage){
        
        SVProgressHUD.show()
        NetworkManager().uploadProfilePic(image: image, key: "profile_pic") { response, error in
            guard let response = response else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.updateUI(user: self.user)
                    self.showAlert(title: "RED E", message: error)
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if (error?.elementsEqual("Your session has been expired.") ?? false){
                    self.logout()
                }
                else{
                    self.showAlert(title: "RED E", message: response) {
                        self.getUserProfile()
                    }
                }
            }
        }
    }
    
    func getUserProfile(){
        
        SVProgressHUD.show()
        NetworkManager().fetchProfile(user: self.user) { user, error  in
            guard let _ = user else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if (error?.elementsEqual("Your session has been expired.") ?? false){
                        self.logout()
                    }
                    else{
                        self.showAlert(title: "RED E", message: error)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.user = user
                self.updateUI(user: self.user)
            }
        }
    }
    
    func deleteUserProfile(){
        SVProgressHUD.show()
        NetworkManager().deleteUser() { isSuccess, message  in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if (message?.elementsEqual("Your session has been expired.") ?? false){
                    self.logout()
                }
                else{
                    if isSuccess {
                        self.showAlert(title: "RED E", message: message){
                            self.logout()
                        }
                    }
                }
            }
        }
    }
    
}
