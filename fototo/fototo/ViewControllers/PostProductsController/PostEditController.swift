//
//  PostEditController.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/10.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

class PostEditController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var cameraNameField: UITextField!
    
    open var bgImage: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        imgView.image = bgImage
        heightConstraint.constant = UIScreen.main.bounds.height*0.5
      
        titleTextField.attributedPlaceholder = NSMutableAttributedString.init(string: "作品标题(10个字符以内)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]);
        locationField.attributedPlaceholder = NSMutableAttributedString.init(string: "拍摄地点(可选,15个字符以内)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]);
        cameraNameField.attributedPlaceholder = NSMutableAttributedString.init(string: "拍摄器材(可选,15个字符以内)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

extension PostEditController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
