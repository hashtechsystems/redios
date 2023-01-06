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
    
    lazy var user: User? = {
        return UserDefaults.standard.getUser()
    }()
    
    var imagePicker = UIImagePickerController()
    
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
        self.txtAddress.text = user?.address
        
        guard let user = user else {
            return
        }
        
        let url = URL(string: "\(user.imagePath)/\(user.profilePic ?? "")")!
        self.imgvwProfile.af.setImage(withURL: url)
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
        if btnEdit.isSelected {
            
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
        }
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
        print("imagePickerController cancel")
    }
}

extension ProfileViewController {
    
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
                self.showAlert(title: "RED E", message: response) {
                    self.getUserProfile()
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
                    self.showAlert(title: "RED E", message: error)
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
                if isSuccess {
                    self.showAlert(title: "RED E", message: message){
                        self.logout()
                    }
                }
            }
        }
    }
    
}
