//
//  DownloadButton.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/18.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import Photos
import Kingfisher

@IBDesignable
open class DownloadButton: UIButton {
    
    public convenience init() {
        self.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
    }

    internal override convenience init(frame: CGRect) {
        self.init(frame: frame, imageSize:CGSize.init(width: 20, height: 20))
        creatView()
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        creatView()
    }
    
    public init(frame: CGRect, imageSize: CGSize!) {
        super.init(frame: frame)
        self.imageSize = imageSize
    }
    
    @IBInspectable open var imageSize: CGSize = CGSize.init(width: 20, height: 20) {
        didSet {
            setupViewFrame()
        }
    }
    
    private var backgroundView: UIImageView?
    private var arrowView: UIImageView?
    private var successIcon: Image?
    private var failedIcon: Image?
    private var downloading: Bool = false
    
    private func creatView() {
        
        backgroundView = UIImageView.init(image: UIImage.init(named: "download_bg"))
        arrowView = UIImageView.init(image: UIImage.init(named: "download_arrow"))
        addSubview(backgroundView!)
        addSubview(arrowView!)
        setupViewFrame()
    }
    
    private func setupViewFrame() {
        
        backgroundView?.frame = CGRect.init(x: (self.bounds.width-imageSize.width)*0.5, y: (self.bounds.height-imageSize.height)*0.5, width: imageSize.width, height: imageSize.height)

        let arrowSize = CGSize.init(width: imageSize.width*0.5, height: imageSize.height*0.5)
        arrowView?.frame = CGRect.init(x: (self.bounds.width-arrowSize.width)*0.5, y: (self.bounds.width-arrowSize.height)*0.5+arrowSize.height*0.5, width: arrowSize.width, height: arrowSize.height)
    }
    
    public func startDownload(_ url: String) {
        
        if downloading == true {return}
        self.isUserInteractionEnabled = false
        downloading = true
        backgroundView?.alpha = 1
        arrowView?.layer.removeAnimation(forKey: "download")

        backgroundView?.alpha = 0.5
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.translation.y"
        animation.values = [-15,-10,-5,0,5]
        animation.duration = 1
        animation.repeatCount = MAXFLOAT
        animation.calculationMode = .linear
        animation.autoreverses = false
        arrowView?.layer.add(animation, forKey: "download")
        
        saveToLibrary(url)
    }
    
    private func saveToLibrary(_ url: String) {
        
        var image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url)
        if image == nil {
            guard let imageData = NSData.init(contentsOf: URL.init(string: url)!) else {
                kWindow.toastError("保存失败")
                failed()
                return
            }
            image = Image.init(data: imageData as Data)
        }
        if image == nil {
            kWindow.toastError("保存失败")
            failed()
            return
        }
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            
            if status != .authorized {
                
                DispatchQueue.main.async {
                    kWindow.toastError("请前往设置-隐私-照片，打开Fototo的相关权限")
                    self.failed()
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({

                _ = PHAssetChangeRequest.creationRequestForAsset(from: image!)}, completionHandler: { (success, error) in
                
                    DispatchQueue.main.async {

                        if success != true{
                            kWindow.toastError("保存失败")
                            self.failed()
                            return
                        }
                        
                        kWindow.toastSuccess("保存成功")
                        self.success()
                    }
            })
        }
    }
    
    private func endDownload() {
        
        downloading = false
        backgroundView?.alpha = 1
        arrowView?.image = UIImage.init(named: "download_arrow")
        self.isUserInteractionEnabled = true
    }
    
    private func success() {
        
        arrowView?.layer.removeAnimation(forKey: "download")
        arrowView?.image = UIImage.init(named: "download_success")
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.endDownload()
        }
    }
    
    private func failed() {
        
        arrowView?.layer.removeAnimation(forKey: "download")
        arrowView?.image = UIImage.init(named: "download_failed")
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.endDownload()
        }
    }
}
