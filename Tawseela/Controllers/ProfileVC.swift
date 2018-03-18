 //
 //  ProfileVC.swift
 //  ClinicSystem
 //
 //  Created by Sherif Ahmed on 1/29/18.
 //  Copyright © 2018 RKAnjel. All rights reserved.
 //
 
 import UIKit
 import Kingfisher
 import Firebase
 
 class ProfileVC: BaseViewController  {
    
    @IBOutlet weak var subtitlesLabel: UILabel!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var saveBtn:UIBarButtonItem!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var driverRateBtn:UIButton!
    var imagePicker = UIImagePickerController()
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("users")

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.driverRateBtn?.setTitle("rate_driver".localized(), for: .normal)
        self.nameTextfield.placeholder = "enter_name".localized()
        self.saveBtn.title = "save".localized()
        self.title = "my_profile".localized()
    }
    
    override func getData() {
        self.errorView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setData()
    }
    
    func setData() {
        DispatchQueue.main.async {
            self.nameTextfield.text = CURRENT_USER?.user?.name!
            self.subtitlesLabel.text = "\((CURRENT_USER?.user?.type!)!)"
            
            let url = URL(string: URL_IMAGE_PREFIX + (CURRENT_USER?.user?.image!)!)
            self.userImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
                self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RatesVC , segue.identifier  == "driverRate"{
            vc.ratesType = "driver_rate"
        }
    }
    
    @IBAction func saveTapped() {
        if !nameTextfield.text!.isEmpty{
            self.activityIndicator.startAnimating()
            channelRef.child((CURRENT_USER?.mobile!)!).child("name").setValue(nameTextfield.text!) { (error, ref) in
                if error == nil {
                    self.showAlertWithTitle(title: "Success", message: "Name Updated Successfully")
                    CURRENT_USER?.user?.name = self.nameTextfield.text!
                    userData.set((CURRENT_USER?.user?.name!)!, forKey: "name")
                    DispatchQueue.main.async {
                        self.nameTextfield.resignFirstResponder()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
 }

 //For Image Selection
 extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func chooseImageTapped(_ sender:UIButton?) {
        let picker = imagePicker

        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.navigationBar.tintColor = appColor
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if let _ = pickedImage.jpeg {
                
                let imageUrl = info[UIImagePickerControllerImageURL] as? URL
                self.activityIndicator.startAnimating()
                RequestManager.defaultManager.uploadPicture(WithURL: imageUrl!, compilition: { (error) in
                    if !error{
                        let splitedName:String! = String(describing: imageUrl!.absoluteString.split(separator: "/").last!)
                        self.channelRef.child((CURRENT_USER?.mobile!)!).child("logo").setValue(splitedName) { (error, ref) in
                            if error == nil {
                                self.showAlertWithTitle(title: "Success", message: "Image Updated Successfully")
                                CURRENT_USER?.user?.image = splitedName
                                userData.set(splitedName, forKey: "logo")
                                DispatchQueue.main.async {
                                    self.userImageView.image = pickedImage
                                    self.nameTextfield.resignFirstResponder()
                                }
                            }
                        }
                    }else{
                        self.showAlertWithTitle(title: "Failed", message: "Sorry, Failed to upload your image")
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                })
                
            }else{
                self.dismiss(animated: true, completion: {
                    self.showAlertWithTitle(title: "Failed", message: "Sorry,unsupported this image format")
                })
            }
        }else{
            self.dismiss(animated: true, completion: {
                self.showAlertWithTitle(title: "Failed", message: "Sorry,unsupported this image format")
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
 }


