//
//  PostProductsController.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 2019/9/27.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import JXPhotoBrowser
import LeanCloud
import Photos

class PostProductsController : UIViewController {
   
    weak var browser: JXPhotoBrowser?
    var isShotting: Bool?
    var postButton: UIButton?
    var postIndicator: UIActivityIndicatorView?
    var choosedItemIndex: Int = -1
    var lastChoosedItemIndex: Int = -1
    var products: NSMutableArray = []

    lazy var userAvatarButton: UIButton = {
        
        let userAvatarButton = UIButton.init(type: UIButton.ButtonType.custom)
        userAvatarButton.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 40, height: 40))
        userAvatarButton.addTarget(self, action: #selector(userCenterAction), for: UIControl.Event.touchUpInside)
        userAvatarButton.layer.cornerRadius = 20
        userAvatarButton.layer.masksToBounds = true
        return userAvatarButton
    }()
    
    typealias PostDoneBlock = (_ product: Product)->()
    var postDoneBlock: PostDoneBlock?
    
    lazy var captureView: UIView = {
        let view = UIView.init(frame: self.view.bounds)
        return view
    }()
    
    lazy var captureService: XDCaptureService = {
        let capture = XDCaptureService.init()
        capture.delegate = self as XDCaptureServiceDelegate
        capture.devicePosition = AVCaptureDevice.Position.back
        capture.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160.rawValue as NSString
        capture.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
        
        return capture
    }()
    
    lazy var shotBotton: UIButton = {
        let shot = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        shot.setImage(UIImage.init(named: "takeshot"), for: UIControl.State.normal)
        shot.alpha = 0.3
        shot.addTarget(self, action: #selector(takeShotAction), for: UIControl.Event.touchUpInside)
        
        return shot
    }()
    
    lazy var waveView: LXWaveProgressView = {
        
        let progressView1 = LXWaveProgressView.init(frame: CGRect.init(x: kWindowBounds.size.width*0.5-30, y: 100, width: 60, height: 60))
        progressView1.progress = 0.5
        progressView1.waveHeight = 3
        progressView1.speed = 0.5
        progressView1.progressLabel.isHidden = true
        progressView1.firstWaveColor = UIColor.init(red: 134/255.0, green: 116/255.0, blue: 210/255.0, alpha: 1)
        progressView1.secondWaveColor = UIColor.init(red: 90/255.0, green: 167/255.0, blue: 255/255.0, alpha: 0.5)

        return progressView1
    }()
    
    
    lazy var rightNavigationItemView: UIView = {
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        
        let postButton = UIButton.init(frame: view.bounds)
        self.postButton = postButton
        postButton.setTitle("发布", for: UIControl.State.normal)
        postButton.setTitle("", for: UIControl.State.disabled)
        postButton.setImage(UIImage.init(), for: UIControl.State.normal)
        postButton.setImage(UIImage.init(named: "success"), for: UIControl.State.disabled)
        postButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        postButton.setTitleColor(UIColor.white, for: UIControl.State.disabled)
        postButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        postButton.addTarget(self, action: #selector(editAction), for: UIControl.Event.touchUpInside)
        view.addSubview(postButton)
        
        let indicate = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium)
        indicate.color = UIColor.white
        self.postIndicator = indicate
        indicate.frame = view.bounds
        view.addSubview(indicate)

        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let collectionView = UICollectionView.init(frame: CGRect.init(x:15, y: 80, width: kWindowBounds.size.width-30, height: kWindowBounds.size.height-100), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 5
        collectionView.layer.masksToBounds = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.jx.registerCell(AuthProductCell.self)
        collectionView.alpha = 0
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = userAvatarButton
        view.backgroundColor = UIColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightNavigationItemView)
        
        view.addSubview(captureView)
        view.addSubview(waveView)
        waveView.addSubview(shotBotton)
        waveView.isHidden = true

        view.addSubview(collectionView)
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.alpha = 1
        }) { (Bool) in
            self.waveView.isHidden = false
        }

        getUser()
        getAssets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserManager.sharedManager.current_user == nil {
            cancelAction()
        }
    }

    private func getAssets() {
        
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            guard status == .authorized else {

                let del = UIApplication.shared.delegate as! AppDelegate
                del.window?.toastError("请前往设置-隐私-照片，打开Fototo的相关权限")
                return
            }
            AssetManager.fetchAll {[weak self] (assets: [PHAsset]) in
                
                self?.products.addObjects(from:assets)
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func getUser() { 
        UserManager.sharedManager.selfInfo { (userinfo: UserInfo?) in
            
            if userinfo == nil {
                return
            }
            guard let avatar = userinfo!.avatar?.value else {return}
            self.userAvatarButton.kf.setBackgroundImage(with: URL.init(string: avatar), for: UIControl.State.normal)
        }
    }
    
    @objc func userCenterAction() {
        
        let storyboard = UIStoryboard(storyboard: .Main)
        let toViewController: AuthCenterViewController = storyboard.instantiateViewController(withIdentifier: "AuthCenterViewController") as! AuthCenterViewController
        toViewController.backgroundImage = nil
        
        toViewController.tableView.tableHeaderView = UIView.init(frame: UIScreen.main.bounds)
        self.present(toViewController, animated: true, completion: nil)
    }
    
    func post(_ product: Product, img: Image) {
        
        postButton?.isHidden = true
        postButton?.isEnabled = false
        postIndicator?.startAnimating()
        collectionView.isUserInteractionEnabled = false
        
        FTAPI.postProduct(product, img: img) { (_ result) in
            
            switch result {
            case .success(_):
                if let done = self.postDoneBlock {
                    done(product)
                }
                self.showResult(success: true, result: nil)
            case .failure(let error):
                switch error {
                case .failureWithSaveObject:
                    self.showResult(success: false, result: "数据保存失败")
                case .failureWithThrowError:
                    self.showResult(success: false, result: "服务器异常")
                case .failureWithUploadFile:
                    self.showResult(success: false, result: "文件上传失败")
                }
            }
        }
    }
    
    func showResult(success: Bool, result: String?) {
        
        var disableImage = "success"
        if success == false {
            disableImage = "failed"
        }
        postButton?.setImage(UIImage.init(named: disableImage), for: UIControl.State.disabled)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            
            self.postIndicator?.stopAnimating()
            self.postButton?.isHidden = false
            if success {
                self.view.toastSuccess("发布成功")
            } else {
                self.view.toastError(result)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.postButton?.isEnabled = true
                self.collectionView.isUserInteractionEnabled = true
                
                if success {
                    self .back()
                }
            }
        }
    }
    
    @objc func takeShotAction() {
        captureService.capturePhoto()
    }
    
    @objc func cancelAction() {
        if self.isShotting == true {
            animatedToDefault()
        } else {
            back()
        }
    }
    
    private func back() {
        
        let transition = CATransition();
        transition.duration = 0.45
        transition.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
        transition.type = CATransitionType.fade;
        transition.subtype = CATransitionSubtype.fromTop;
        transition.delegate = self as CAAnimationDelegate;
  
        self.navigationController!.view.layer.add(transition, forKey: nil);
        self.navigationController?.popViewController(animated: false)
    }
}


extension PostProductsController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if self.isShotting == true {return}
        let contentY = Float(scrollView.contentOffset.y)
        var waveProgress: Float = 0.0
        if contentY < -80 {
            waveProgress = -(contentY+80)/60
        }
        if waveProgress >= 1.0 {
            waveProgress = 1.0
            animatedToShot()
        }
        waveView.progress = CGFloat(waveProgress)
    }
    
    func animatedToShot() {
        
        self.isShotting = true
        UIView.animate(withDuration: 0.35, animations: {
            
            self.collectionView.frame = CGRect.init(x: 15, y: kWindowBounds.height, width: kWindowBounds.size.width-30, height: kWindowBounds.height-100)
            self.waveView.frame = CGRect.init(x: kWindowBounds.width*0.5-30, y: kWindowBounds.height-100, width: 60, height: 60)
            
        }) { (Bool) in
            
            self.waveView.progress = 1
            self.rightNavigationItemView.isHidden = true
            self.navigationItem.title = "拍摄你的作品"
            
            self.captureService.startRunning()
            self.captureView.isHidden = false
        }
    }
    
    func animatedToDefault() {
        
        self.isShotting = false
        UIView.animate(withDuration: 0.35, animations: {
            
            self.collectionView.frame = CGRect.init(x: 15, y: 80, width: kWindowBounds.size.width-30, height: kWindowBounds.size.height-100)
            self.waveView.frame = CGRect.init(x: kWindowBounds.size.width*0.5-30, y: 100, width: 60, height: 60)
            
        }) { (Bool) in
            self.waveView.progress = 0
            self.rightNavigationItemView.isHidden = false
            self.navigationItem.title = "选择你的作品"
            
            self.captureService.stopRunning()
        }
    }
}

extension PostProductsController: CAAnimationDelegate{
    
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

    }
}

extension PostProductsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? AuthProductCell
        let product = products[indexPath.item]
        if let asset: PHAsset = product as? PHAsset {
            cell?.loadProgress = 0.0
            AssetManager.resolveAsset(asset, size:CGSize.init(width: UIScreen.main.nativeBounds.width, height: UIScreen.main.nativeBounds.height), progress: { (progress: Double, error: Error?, res: UnsafeMutablePointer<ObjCBool>, obj: [AnyHashable : Any]?) in
                
                DispatchQueue.main.async(execute: {
                    cell?.loadProgress = CGFloat(progress)
                })
                
            }) { (img: UIImage?) in
                
                cell?.image = img
                cell?.loadProgress = 1.0
                self.openPhotoBrowser(with: collectionView, indexPath: indexPath)
            }
        } else {
            cell?.image = product as? Image
            self.openPhotoBrowser(with: collectionView, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.jx.dequeueReusableCell(AuthProductCell.self, for: indexPath)
        cell.chooseEnabled = true
        cell.isChoosed = choosedItemIndex == indexPath.item
        let product = products[indexPath.item]
        if let asset = product as? PHAsset {
            cell.asset = asset
        } else {
            cell.image = product as? Image
        }
        cell.choosedImageDone = { [weak self] in
            
            if self?.lastChoosedItemIndex == indexPath.item {return}
            self?.lastChoosedItemIndex = self?.choosedItemIndex ?? -1
            self?.choosedItemIndex = indexPath.item
            
            if self!.lastChoosedItemIndex >= 0 {
                let lastCell = try? collectionView.cellForItem(at: IndexPath.init(item: self!.lastChoosedItemIndex, section: 0)) as? AuthProductCell
                lastCell?.isChoosed = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let wid = (kWindowBounds.size.width-33)/3
        return CGSize.init(width: wid, height: wid*1.78)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 1.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1.5
    }
}


extension PostProductsController {
    
    func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        
        // 数据源
        let dataSource = JXLocalDataSource(numberOfItems: {
            // 共有多少项
            return self.products.count
        }, localImage: { index -> UIImage? in
            // 每一项的图片对象
            let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? AuthProductCell
            return cell?.iconView.image
        })

        // 视图代理，实现了页码指示器
        let delegate = JXNumberPageControlDelegate()
        
        // 转场动画
        let trans = JXPhotoBrowserZoomTransitioning { (browser, index, view) -> UIView? in
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? AuthProductCell
            return cell
        }
        
        // 打开浏览器
        JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
            .show(pageIndex: indexPath.item)
    }
}


extension PostProductsController: XDCaptureServiceDelegate {
    
    func captureServiceDidStop(_ service: XDCaptureService!) {

        DispatchQueue.main.async {
            self.captureView.isHidden = true
        }
    }
    
    func captureServiceDidStart(_ service: XDCaptureService!) {
        
        DispatchQueue.main.async {
            self.captureView.isHidden = false
        }
    }
    
    func captureService(_ service: XDCaptureService!, serviceDidFailWithError error: Error!) {
        print(error ?? "error capture")
    }
    
    func captureService(_ service: XDCaptureService!, get previewLayer: AVCaptureVideoPreviewLayer!) {
        if (previewLayer != nil) {
            
            DispatchQueue.main.async {
                           
                self.captureView.layer.insertSublayer(previewLayer, at: 0)
                previewLayer.frame = self.captureView.bounds;
            }
        }
    }
    
    func captureService(_ service: XDCaptureService!, capturePhoto photo: UIImage!) {
        cancelAction()
        products.insert(photo!, at: 0)
        collectionView.reloadData()
    }
}


extension PostProductsController {
    
    @objc func editAction() {
        
        if choosedItemIndex < 0 || choosedItemIndex >= products.count {
            return
        }

        let indexPath = IndexPath(item: choosedItemIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? AuthProductCell else {
            return
        }
        let product = products[indexPath.item]
        if let asset: PHAsset = product as? PHAsset {
            
            cell.loadProgress = 0.0
            AssetManager.resolveAsset(asset, size:CGSize(width:1080, height:2048), shouldPreferLowRes: false, progress: { (progress: Double, error: Error?, res: UnsafeMutablePointer<ObjCBool>, obj: [AnyHashable : Any]?) in
                
                DispatchQueue.main.async(execute: {
                    cell.loadProgress = CGFloat(progress)
                })

            }) { (img: UIImage?) in
                
                cell.loadProgress = 1.0
                if let image = img {
                    self.showEditDialog(image: image, animated: true)
                }
            }
            
        } else {
            self.showEditDialog(image: product as! Image, animated: true)
        }
    }
    
    func showEditDialog(image:Image, animated: Bool = true) {

        // Create a custom view controller
        let editVC = PostEditController()
        editVC.bgImage = image

        // Create the dialog
        let popup = PopupDialog(viewController: editVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "取消", height: 50) { (button: PopupDialogButton?) in

        }

        // Create second button
        let buttonTwo = DefaultButton(title: "完成", height: 50) { (button: PopupDialogButton?) in
            
            let product = Product()
            
            let title = editVC.titleTextField.text!
            guard title.count > 0 && title.count <= 10 else {
                editVC.view.toastMessage("标题字数1~10")
                return
            }
            product.title = LCString(title)
            
            let location = editVC.locationField.text!
            guard location.count <= 15 else {
                editVC.view.toastMessage("地点字数0~15")
                return
            }
            product.location = LCString(location)
            
            let cameraName = editVC.cameraNameField.text!
            guard cameraName.count <= 15 else {
                editVC.view.toastMessage("器材字数0~15")
                return
            }
            product.camera = LCString(cameraName)
            
            popup.dismiss()
            
            self.post(product, img: image)
        }
        
        buttonTwo.dismissOnTap = false

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
}
