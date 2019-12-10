//
//  AuthProductCell.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 2019/9/20.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class AuthProductCell: UICollectionViewCell {
    
    lazy fileprivate var progressView: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.roundedCorners = false
        progress.thicknessRatio = 1
        progress.progressTintColor = UIColor.orange
        return progress
    }()
    
    lazy var iconView: UIImageView = {
        
        let imgView = UIImageView.init(frame: self.bounds)
        imgView.contentMode = ContentMode.scaleAspectFill
        imgView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        return imgView
    }()
        
    open var loadProgress: CGFloat? {
        didSet{
            self.progressView.updateProgress(loadProgress!, animated: false, initialDelay: 0)
            self.progressView.isHidden = loadProgress! >= CGFloat(1.0)
        }
    }
    
    open var image: Image? {
        didSet{
            iconView.image = image
        }
    }
    
    open var state: Int? {
        didSet{
            chooseButton.isHidden = state == 1
            progressView.isHidden = true
            
            switch state {
            case -1:
                chooseButton.setImage(UIImage.init(named: "check_failed"), for: UIControl.State.normal)
            case 0:
                chooseButton.setImage(UIImage.init(named: "checking"), for: UIControl.State.normal)
            default:
                break
            }
        }
    }
        
    open var asset: PHAsset? {
        didSet {
            guard let asset = asset else {
                return
            }
            AssetManager.resolveAsset(asset, size:CGSize(width:200, height:200),shouldPreferLowRes:true, progress: { (progress: Double, error: Error?, res: UnsafeMutablePointer<ObjCBool>, obj: [AnyHashable : Any]?) in
                
                DispatchQueue.main.async(execute: {

                    self.progressView.updateProgress(CGFloat(progress), animated: false, initialDelay: 0)
                })

            }) { (img: UIImage?) in
                
                self.image = img
                self.progressView.isHidden = true
            }
        }
    }
    
    open var image_url: String? {
     
        didSet{
            guard image_url != nil else {
               return
            }
            iconView.kf.setImage(with: URL.init(string: image_url!), placeholder: UIImage.init(named: "BackgroundImage"), options: [.transition(.fade(0.3)), .backgroundDecode], progressBlock: nil, completionHandler: nil)
        }
    }
    
    //是否支持选择
    open var chooseEnabled: Bool = false {
        didSet{
            chooseButton.isHidden = !chooseEnabled
        }
    }
    
    open var isChoosed: Bool = false {
        didSet{
            chooseButton.isSelected = isChoosed
        }
    }
    
    open var choosedImageDone = {
        
    }
        
    lazy var chooseButton: UIButton = {
        
        let chooseBtn = UIButton.init(frame:CGRect.init(x: self.bounds.size.width-40, y: 0, width: 40, height: 40))
        chooseBtn.setImage(UIImage.init(named: "news_unselected"), for: UIControl.State.normal)
        chooseBtn.setImage(UIImage.init(named: "news_selection"), for: UIControl.State.selected)
        chooseBtn.addTarget(self, action: #selector(chooseAction(_:)), for: UIControl.Event.touchUpInside)
        chooseBtn.isHidden = true
        return chooseBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        
        self.backgroundColor = UIColor.black
        self.addSubview(iconView)
        self.addSubview(chooseButton)
        chooseButton.addSubview(progressView)
        self.layer.masksToBounds = true
    }
    
    @objc func chooseAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        choosedImageDone()
    }
}
