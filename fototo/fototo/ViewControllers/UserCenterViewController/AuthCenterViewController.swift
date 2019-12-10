//
//  UserCenterViewController.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 2019/9/20.
//  Copyright © 2019 Even_cheng All rights reserved.
//
import UIKit
import JXPhotoBrowser

class AuthCenterViewController: ExpandingTableViewController {
 
    var user_objectid: String? = UserManager.sharedManager.current_user?.objectId?.value
    var browser: JXPhotoBrowser?
    var topConstraint: CGFloat = 80.0
    var bottomConstraint: CGFloat = 20.0
    var products: [Product] = []
    var currentBroswerIndex: Int = 0
    var currentUser: UserInfo?
    var hadMore: Bool = true
    private lazy var commentVc: ProductCommentController = {
        let vc = ProductCommentController.init()
        vc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        return vc
    }()

    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let collectionView = UICollectionView.init(frame: CGRect.init(x:15, y: kWindowBounds.size.height, width: kWindowBounds.size.width-30, height: kWindowBounds.size.height-100), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 5
        collectionView.layer.masksToBounds = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.jx.registerCell(AuthProductCell.self)
        collectionView.register(AuthHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AuthHeaderView")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "AuthFooterView")
        
        return collectionView
    }()
    
    fileprivate var scrollOffsetY: CGFloat = 0
    var backgroundImage : Image? {
        didSet {
            if backgroundImage != nil {
                tableView.backgroundView = UIImageView(image: backgroundImage)
            } else {
                tableView.backgroundColor = UIColor.init(white: 0, alpha: 0.9)
                self.topConstraint = 0
                self.bottomConstraint = 40
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        headerHeight = kWindowBounds.size.height
            
        self.loadProducts()
        self.loadUserInfo()
    }
    
    fileprivate func loadProducts() {
        
        DispatchQueue.global(qos: .background).async {
            UserManager.sharedManager.checkProducts(user_objectId:self.user_objectid!, offset: self.products.count, limit: 20) { (objs:[Product]?) in
                
                if (objs != nil) {
                    
                    self.products.append(contentsOf: objs!)
                    self.hadMore = objs?.count == 20
                    self.collectionView.reloadData()
                
                } else {
                    self.hadMore = false
                }
            }
        }
    }
    
    fileprivate func loadUserInfo() {
        
        UserManager.sharedManager.getUserInfo(objectId:self.user_objectid!) {[weak self] (user: UserInfo?) in
            if user == nil {
                return
            }
            self?.currentUser = user
            self?.collectionView.reloadData()
        }
    }
    
    fileprivate func back() {
        
        guard let navigationController = navigationController else {
            self.dismiss(animated: true) {
            }
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
        
            self.collectionView.frame = CGRect.init(x:15, y: kWindowBounds.size.height, width: kWindowBounds.size.width-30, height: kWindowBounds.size.height-100)
            
        }) { (Bool) in
            
            // buttonAnimation
            for case let viewController as DemoViewController in navigationController.viewControllers {
                if case let rightButton as AnimatingBarButton = viewController.navigationItem.rightBarButtonItem {
                    rightButton.animationSelected(false)
                }
            }
            self.popTransitionAnimation()
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        let viewControllers: [DemoViewController?] = navigationController?.viewControllers.map { $0 as? DemoViewController } ?? []

        for viewController in viewControllers {
            if let rightButton = viewController?.navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(false)
            }
        }
        popTransitionAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let header = tableView.tableHeaderView
        if collectionView.superview != nil {
            return
        }
        header?.addSubview(collectionView)
        UIView.animate(withDuration: 0.25) {
            self.collectionView.frame = CGRect.init(x:15, y: self.topConstraint, width: kWindowBounds.size.width-30, height: kWindowBounds.size.height-self.topConstraint-self.bottomConstraint)
        }
    }
}

// MARK: Helpers

extension AuthCenterViewController {
    
    fileprivate func configureNavBar() {
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }
}


// MARK: UIScrollViewDelegate

extension AuthCenterViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -130 , let _ = navigationController {
           
            self.back()
        }
        scrollOffsetY = scrollView.contentOffset.y
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return kWindowBounds.size.height - headerHeight;
    }
}

extension AuthCenterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPhotoBrowser(with: collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.jx.dequeueReusableCell(AuthProductCell.self, for: indexPath)
        cell.image_url = products[indexPath.item].file_url?.value
        cell.state = products[indexPath.item].state.intValue ?? 0
        
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {

            let view: AuthHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AuthHeaderView", for: indexPath) as! AuthHeaderView
            view.usr = self.currentUser
            view.backButton.isHidden = navigationController != nil
            view.backDone = {
                self.back()
            }
            return view
        
        } else {
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "AuthFooterView", for: indexPath)
            var indicate: UIActivityIndicatorView? = view.viewWithTag(100) as? UIActivityIndicatorView
            if indicate == nil {
                indicate = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium)
                indicate!.tag = 100
                indicate!.color = UIColor.white
                indicate!.frame = view.bounds
                indicate!.startAnimating()
                view.addSubview(indicate!)
            }
            
            if self.hadMore {
                indicate?.isHidden = false
                self.loadProducts()
            } else {
                indicate?.isHidden = true
            }

            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize.init(width: collectionView.bounds.size.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize.init(width: collectionView.bounds.size.width, height: 20)
    }
}

extension AuthCenterViewController {
  
    func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        
        let phototLoader = JXKingfisherLoader()
        let dataSource = JXNetworkingDataSource(photoLoader: phototLoader, numberOfItems: { () -> Int in
            
            // 共有多少项
            return self.products.count
            
        }, placeholder: { (index) -> UIImage? in
            
            return nil
            
        }) { (index) -> String? in
            
            // 每一项的图片对象
            let product = self.products[index]
            let img_url = product.file_url?.value
            return img_url
        }

        // 视图代理，实现了页码指示器
        let delegate = JXTitlePageDelegate()
        delegate.getTitle = { (index: Int) -> (String?) in
            
            // 每一项的图片对象
            let product = self.products[index]
            self.currentBroswerIndex = index
            self.commentVc.product = product
            
            return product.title?.value
        }
        
        // 转场动画
        let trans = JXPhotoBrowserZoomTransitioning { (browser, index, view) -> UIView? in
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? AuthProductCell
           
            return cell
        }
        
        // 打开浏览器
        self.browser = JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
        self.browser?.show(pageIndex: indexPath.item)
        
        let commentView = UIView.init()
        commentView.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        commentView.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height-40, width: UIScreen.main.bounds.width, height: 80)
        commentView.layer.cornerRadius = 10
        commentView.layer.masksToBounds = true
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 8, width: commentView.width, height: 20))
        commentView.addSubview(titleLabel)
        titleLabel.text = "上滑查看更多"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor.darkGray
        let upGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))) {
            $0.direction = .up
        }
        commentView.addGestureRecognizer(upGesture)
        self.browser?.view.addGestureRecognizer(upGesture)
        self.browser?.view.addSubview(commentView)
        addPopToComment(commentView)
    }
    
    private func addPopToComment(_ view: UIView) {
        let animation =  CAKeyframeAnimation.init(keyPath: "position.y")
        let finalY = UIScreen.main.bounds.height
        animation.values = [finalY+60,finalY-5,finalY]
        animation.duration  = 0.8
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.repeatCount = 1
        //动画速度变化
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false;
        view.layer.add(animation, forKey: nil)
    }
    
    @objc func swipeHandler(_ sender: UISwipeGestureRecognizer){
        
        let product = products[currentBroswerIndex]
        let state = product.state.intValue ?? 0
        if state != 1 {
            self.browser?.view.toastWarn("作品未通过审核")
            return
        }
        if self.products.count == 1 && currentBroswerIndex == 0 {
            self.commentVc.product = product
        }
        self.browser?.present(commentVc, animated: true, completion: nil)
    }
}
