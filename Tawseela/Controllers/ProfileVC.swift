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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
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
            self.nameLabel.text = CURRENT_USER?.user?.name!
            self.subtitlesLabel.text = "\((CURRENT_USER?.user?.type!)!)"
            
            let url = URL(string: URL_IMAGE_PREFIX + (CURRENT_USER?.user?.image!)!)
            self.userImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
                self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
            })
        }
    }
    
 }

 //For Image Selection
 extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func chooseImageTapped(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.navigationBar.tintColor = appColor
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if let jpegData = pickedImage.jpeg {
                
                let encodedImage = jpegData.base64EncodedString(options: .lineLength64Characters)
                
//                RequestManager.defaultManager.setImageForUser(image: encodedImage) { (error, recError) in
//                    print(error)
//                    if !error{
//                        if recError?.code == .Success{
//                            DispatchQueue.main.async {
//                                self.userImageView.image = pickedImage
//                            }
//                        }
//                    }
//                }
                
                
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

