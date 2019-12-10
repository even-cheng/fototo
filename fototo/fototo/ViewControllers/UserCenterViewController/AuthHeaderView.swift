//
//  AuthHeaderView.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 2019/9/20.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import LeanCloud

class AuthHeaderView: UICollectionReusableView {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open var backDone = {}
    private var nameField: UITextField?
    private var introduceField: UITextField?
    private var receiveLikesLabel: UILabel?
    private var productsLabel: UILabel?
    private var imagePicker = UIImagePickerController()

    private lazy var avatarIcon: UIImageView = {
        
        let avatarImageView = UIImageView.init(frame: CGRect.init(x: 5, y: 10, width: 60, height: 60))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(avatarTap)))
        avatarImageView.image = UIImage.init(named: "default_avatar")
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        avatarImageView.layer.shadowOpacity = 0.35
        avatarImageView.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        avatarImageView.layer.shadowRadius = 3
        return avatarImageView
    }()
    
    open var usr: UserInfo? {
        didSet{
            guard let avatar = usr?.avatar?.value else {return}
            avatarIcon.kf.setImage(with: URL.init(string: avatar))
            nameField?.text = usr?.nickname?.value
            introduceField?.text = usr?.introduce?.value

            guard let posts = usr?.posted_products else {
                return
            }
            guard let posts_product = posts.value as? [Product] else {
                return
            }
            productsLabel?.text = "共\(posts_product.count)个作品"
            
            var receive_count = 0
            for product: Product in posts_product {
                receive_count += product.liked_users?.count ?? 0
            }
            self.receiveLikesLabel?.text = "共获得\(receive_count)个喜欢"
            
            if usr?.user_objectId == UserManager.sharedManager.current_user?.objectId {
                nameField!.isUserInteractionEnabled = true
                introduceField!.isUserInteractionEnabled = true
            }
        }
    }
    
    lazy var backButton: UIButton = {
        
        let logoutBtn = UIButton.init(frame: CGRect.init(x: frame.size.width-40, y: 20, width: 60, height: 40))
        logoutBtn.setImage(UIImage.init(named: "CloseButton"), for: UIControl.State.normal)
        logoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        logoutBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        logoutBtn.addTarget(self, action: #selector(backAction), for: UIControl.Event.touchUpInside)
     
        return logoutBtn
    }()
    
    lazy var avatarView: UIView = {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 80))
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.addSubview(avatarIcon)
        view.addSubview(backButton)

        return view
    }()
    
    lazy var infoView: UIView = {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 90, width: frame.size.width, height: 150))
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        let nameField = UITextField.init(frame: CGRect.init(x: 5, y: 0, width: self.frame.size.width-10, height: 30))
        self.nameField = nameField
        nameField.isUserInteractionEnabled = false
        nameField.text = "- - -"
        nameField.delegate = self as UITextFieldDelegate
        nameField.returnKeyType = .done
        nameField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nameField.font = UIFont.boldSystemFont(ofSize: 25)
        view.addSubview(nameField)
        
        let introduceField = UITextField.init(frame: CGRect.init(x: 5, y: 35, width: self.frame.size.width-10, height: 20))
        self.introduceField = introduceField
        introduceField.isUserInteractionEnabled = false
        introduceField.delegate = self as UITextFieldDelegate
        introduceField.returnKeyType = .done
        introduceField.text = "一句话介绍自己"
        introduceField.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        introduceField.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(introduceField)
        
        let postProductsLabel = UILabel.init(frame: CGRect.init(x: 0, y: view.bounds.size.height-40, width:
            self.frame.size.width, height: 30))
        self.productsLabel = postProductsLabel
        postProductsLabel.text = "共0个作品"
        postProductsLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        postProductsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        view.addSubview(postProductsLabel)
        
        let receiveLikeLabel = UILabel.init(frame: CGRect.init(x: 0, y: view.bounds.size.height-70, width: self.frame.size.width, height: 30))
        self.receiveLikesLabel = receiveLikeLabel
        receiveLikeLabel.text = "共获得0个喜欢"
        receiveLikeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        receiveLikeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        view.addSubview(receiveLikeLabel)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI() {
        
        addSubview(self.avatarView)
        addSubview(self.infoView)
    }
    
    @objc func backAction() {
        
        self.backDone()
    }
    
    @objc func avatarTap() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = avatarIcon
            alert.popoverPresentationController?.sourceRect = avatarIcon.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.currentViewController?.present(alert, animated: true, completion: nil)
    }
}

extension AuthHeaderView : UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 15
        if textField == self.introduceField {
            maxLength = 20
        }
        if textField.text!.count > maxLength {
            textField.text! = (textField.text! as NSString).substring(to: maxLength)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        let userinfo = UserManager.sharedManager.current_user?.userInfo!
        if textField == self.nameField {
            userinfo?.nickname = LCString(textField.text!)
        } else {
            userinfo?.introduce = LCString(textField.text!)
        }
        self.usr = userinfo
        _ = userinfo?.save()
        return true
    }
}

extension AuthHeaderView:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: - Open the camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.currentViewController?.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.currentViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.currentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[.editedImage] as! UIImage?{
            let resizeimg = editedImage.reSizeImage(CGSize.init(width: 100, height: 100))
            self.avatarIcon.image = resizeimg
            UserManager.sharedManager.updateAvatar(resizeimg, complete: { (img_url: String?) in
                if img_url != nil {
                    self.usr?.avatar = LCString(img_url!)
                }
            })
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    
    func reSizeImage(_ reSize:CGSize)->UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        let cornerPath = UIBezierPath(ovalIn: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
        cornerPath.addClip()
        self.draw(in: CGRect(x:0, y:0, width:reSize.width, height:reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return reSizeImage
    }
}
