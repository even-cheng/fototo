//
//  DemoViewController.swift
//  TestCollectionView
//
//  Created by Even_cheng on 12/09/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import JXPhotoBrowser
import Kingfisher
import LeanCloud

class DemoViewController: ExpandingViewController {

    var inPaning = false
    var beginRefreshing = false
    var isMore = false
    weak var browser: JXPhotoBrowser?
    lazy var dragView: DO_EdgeDragView = {
        let view = DO_EdgeDragView.init(frame: kWindowBounds, edgeType: .left)
        view!.isUserInteractionEnabled = false
        view!.color = UIColor.black
        return view!
    }()
    lazy var refreshTipLabel: UILabel = {
        
        let tip = UILabel.init(frame: CGRect.init(x: -60, y: (UIScreen.main.bounds.height-200)*0.5, width: 15, height: 200))
        tip.text = "释放刷新"
        tip.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tip.numberOfLines = 0
        tip.font = UIFont.systemFont(ofSize: 14)
        return tip
    }()

    typealias ItemInfo = (imageName: String, title: String)
    var lastIndex: Int = -1
    fileprivate var cellsIsOpen = [Bool]()
    fileprivate var items: [Product] = []

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var fontView: UIView!
    
    @IBAction func scrollToFirst(_ sender: Any) {
        inPaning = false
        collectionView?.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        
        guard let info = items.first else {
//            pushToPostCenter()
            loadDatas()
            return
        }
        
        guard let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: info.file_url!.value) else {
            return
        }
        setBackgroundColorWithImage(img: image)
    }
    
    private func loadDatas() {
     
        if !isMore {
            self.titleLabel.textColor = UIColor.systemOrange
            self.titleLabel.text = "正在更新作品..."
            self.lastIndex = -1
            items.removeAll()
        }
        FTAPI.checkNewProducts(offset: items.count, limit: 10) {[weak self] (objs:[Product]?) in
            
            if (objs != nil) {
                
                if !self!.isMore {
                    self?.items.removeAll()
                    self?.titleView?.toastSuccess("作品已更新")
                }
                
                if objs!.count == 0 {
                    self?.titleView?.toastError("已是最后一幅")
                    if self!.items.count == 0 {
                        self?.titleLabel.text = "双击我刷新页面"
                    }
                    return
                }
                self?.items.append(contentsOf: objs!)
                self?.fillCellIsOpenArray()
                self?.collectionView?.reloadData()
                
                self?.titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            } else {
                self?.titleView?.toastError("暂无更多作品")
            }
            
            if self!.items.count == 0 {
                self?.titleLabel.text = "双击我刷新页面"
            }
        }
    }
}

// MARK: - Lifecycle 🌎
extension DemoViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.65, alpha: 0.65)

        registerCell()
        setupNavBar()
        addGesture(to: collectionView!)
        collectionView!.addSubview(refreshTipLabel)
        view.addSubview(dragView)
        loadDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
}

// MARK: Helpers

extension DemoViewController {

    fileprivate func setupNavBar(){
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        titleLabel.layer.shadowOpacity = 0.2
    }

    fileprivate func setBackgroundColorWithImage(img: UIImage?) {
        UIImage.setColorToFontView(fontView, back: backView, with: img)
    }
    
    fileprivate func registerCell() {

        let nib = UINib(nibName: String(describing: DemoCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: DemoCollectionViewCell.self))
    }

    fileprivate func fillCellIsOpenArray() {
        cellsIsOpen = Array(repeating: false, count: items.count)
    }

    fileprivate func getDetailController(product: Product?) -> ExpandingTableViewController {
        let storyboard = UIStoryboard(storyboard: .Main)
        let toViewController: DemoTableViewController = storyboard.instantiateViewController()
        toViewController.product = product
        toViewController.backgroundImage = fontView.takeSnapshot(kWindowBounds)
        return toViewController
    }
    
    fileprivate func getAuthCenterController(_ user_objectid: String?) -> ExpandingTableViewController {
        let storyboard = UIStoryboard(storyboard: .Main)
        let toViewController: AuthCenterViewController = storyboard.instantiateViewController(withIdentifier: "AuthCenterViewController") as! AuthCenterViewController
        toViewController.user_objectid = user_objectid
        toViewController.backgroundImage = fontView.takeSnapshot(kWindowBounds)
        return toViewController
    }
}

/// MARK: Gesture
extension DemoViewController {
    
    fileprivate func addGesture(to view: UIView) {

        let upGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(DemoViewController.swipeHandler(_:)))) {
            $0.direction = .up
        }

        let downGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(DemoViewController.swipeHandler(_:)))) {
            $0.direction = .down
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
   
        view.addGestureRecognizer(upGesture)
        view.addGestureRecognizer(downGesture)
        view.addGestureRecognizer(longPressGesture)
    }

    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        
        self.showReportDialog()
    }
    
    @objc func swipeHandler(_ sender: UISwipeGestureRecognizer) {
        
        if UserManager.sharedManager.current_user == nil {
            self.showLoginDialog()
            return
        }
        
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell = collectionView?.cellForItem(at: indexPath) as? DemoCollectionViewCell else { return }
        if !cell.stateIconView.isHidden {
            cell.toastWarn("作品正在审核")
            return
        }
 
        let info = items[currentIndex]
        if cell.isOpened == true && sender.direction == .up {
            
            pushToDetail(product: info)
            
        } else if cell.isOpened == false && sender.direction == .down {
           
            let originFrame = cell.frontContainerView.frame
            let aniFrame = CGRect.init(x: originFrame.origin.x, y: originFrame.origin.y+40, width: originFrame.size.width, height: originFrame.size.height);
            cell.backContainerView.isHidden = true;
            UIView.animate(withDuration: 0.2, animations: {
                cell.frontContainerView.frame = aniFrame
            }) { (Bool) in
                
                var duration = 0.5
            
                if cell.favoriteButton.isSelected {
                    duration = 0.1
                    FTAPI.unLike(info)
                    cell.favoriteButton.deselect()
                    cell.likeButton.deselect()
                } else {
                    FTAPI.like(info)
                    cell.favoriteButton.select()
                    cell.likeButton.select()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    UIView.animate(withDuration: 0.2 , animations: {
                        cell.frontContainerView.frame = originFrame
                    }) { (Bool) in
                        cell.backContainerView.isHidden = false;
                        cell.buildAvatarForLikes(info)
                    }
                }
            }
            
        } else {
            
            let open = sender.direction == .up ? true : false
            titleLabel.isHidden = open
            cell.cellIsOpen(open)
            cellsIsOpen[indexPath.row] = cell.isOpened
        }
    }
}


// MARK: UIScrollViewDelegate
extension DemoViewController {
    
    //获取最新
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if beginRefreshing && isMore == false {
            loadDatas()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if lastIndex == 0 && lastIndex == currentIndex && scrollView.contentOffset.x < -60 {
            self.isMore = false
             beginRefreshing = true
        } else {
            beginRefreshing = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        let isMoreSwipe = translation.x<0
        
        if lastIndex == currentIndex{
            
            if currentIndex == 0 && scrollView.contentOffset.x < 0{
                
                if scrollView.isDragging {
                    
                    inPaning = true
                    if UserManager.sharedManager.current_user != nil {
                        dragView.beginPan(scrollView.panGestureRecognizer)
                        if scrollView.contentOffset.x < -80 {
                            refreshTipLabel.text = "继续拖拽"
                        } else {
                            refreshTipLabel.text = "释放刷新"
                        }
                    } else if scrollView.contentOffset.x < -100{
                        self.showLoginDialog()
                    }

                } else if inPaning {
                    inPaning = false
                    dragView.endPan()
                    
                    dragView.fullScreenDone = { [weak self] in
                        self?.beginRefreshing = false
                        self?.pushToPostCenter()
                        self?.dragView.reset()
                    }
                }
            }
            return
        }
      
        if items.count > currentIndex {
            let info = items[currentIndex]
            titleLabel.text = info.title?.value
            if inPaning {
                
                guard let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: info.file_url!.value) else {
                    return
                }
                setBackgroundColorWithImage(img: image)
            }
            lastIndex = currentIndex;
            
            //加载更多
            if lastIndex == items.count-1 && currentIndex == lastIndex && isMoreSwipe{
                self.isMore = true
                beginRefreshing = true
                loadDatas()
            }
        }
        
        guard let cell = collectionView!.cellForItem(at: IndexPath.init(item: currentIndex, section: 0)) as? DemoCollectionViewCell else { return }
        titleLabel.isHidden = cell.isOpened
    }
    
    private func pushToPostCenter() {
        let postVc = PostProductsController()
        self.navigationController?.pushViewController(postVc, animated: false)
        postVc.postDoneBlock = {[weak self] (product: Product) in
            
            self?.lastIndex = -1
            self?.items.insert(product, at: 0)
            self?.fillCellIsOpenArray()
            self?.collectionView?.reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource
extension DemoViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        guard let cell = cell as? DemoCollectionViewCell else { return }
        if items.count == 0 {
            return
        }
        let index = indexPath.row % items.count
        let info = items[index]
        if let img_url = info.file_url?.value {
            cell.backgroundImageView?.kf.setImage(with: URL.init(string: img_url), placeholder: nil, options: [.transition(.fade(0.4))], progressBlock: nil, completionHandler: { (img: Image?, error: NSError?, type: CacheType, url: URL?) in
                if img != nil {
                    cell.backgroundImageView.image = img
                    if index == 0 && self.lastIndex == -1{
                        self.lastIndex = 0
                        self.titleLabel.text = info.title?.value
                        self.setBackgroundColorWithImage(img: img)
                    }
                }
            })
            cell.cellIsOpen(cellsIsOpen[index], animated: false)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DemoCollectionViewCell
            , currentIndex == indexPath.row, cell.isOpened == false else { return }
        if items.count > indexPath.item {
            openPhotoBrowser(with: collectionView, indexPath: indexPath, from: cell)
        }
    }
    
    func pushToDetail(product: Product?) {
        
        pushToViewController(getDetailController(product:product))
        if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
            rightButton.animationSelected(true)
        }
    }
    
    func pushToAuthCenter(_ user_objectid: String?) {
        
        let authVc = getAuthCenterController(user_objectid) as! AuthCenterViewController
        pushToViewController(authVc)
        if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
            rightButton.animationSelected(true)
        }
    }
}

// MARK: UICollectionViewDataSource
extension DemoViewController {

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let cell = collectionView.jx.dequeueReusableCell(DemoCollectionViewCell.self, for: indexPath)
        if items.count == 0 {
            return cell
        }
        let index = indexPath.row % items.count
        let info = items[index]
        cell.product = info
        
        cell.authClick = {
   
            self.pushToAuthCenter(info.userid?.value)
        }
        cell.moreClick = {
            self.pushToDetail(product: info)
        }
     
        return cell
    }
    
    func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath, from: UIView) {
        
        let phototLoader = JXKingfisherLoader()
        let dataSource = JXNetworkingDataSource(photoLoader: phototLoader, numberOfItems: { () -> Int in
            
            // 共有多少项
            return 1
            
        }, placeholder: { (index) -> UIImage? in
            
            return nil
            
        }) { (index) -> String? in
            
            // 每一项的图片对象
            let img_url = self.items[indexPath.item].file_url?.value
            return img_url
        }
        
        // 视图代理，实现了光点型页码指示器
        let delegate = JXDefaultPageControlDelegate()
        // 转场动画
        let trans = JXPhotoBrowserZoomTransitioning { (browser, index, view) -> UIView? in
            return from
        }
        // 打开浏览器
        JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
            .show(pageIndex: 0)
    }
    
    private func showReportDialog() {
        
        // Create a custom view controller
        let reportVC = FT_ReportController()
        
        
        // Create the dialog
        let popup = PopupDialog(viewController: reportVC,
                                buttonAlignment: .vertical,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: true)
        
        let product = items[currentIndex]
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell = collectionView?.cellForItem(at: indexPath) as? DemoCollectionViewCell else { return }
        
        // Create second button
        let buttonReport = DefaultButton(title: "立即举报", height: 50) { (button: PopupDialogButton?) in
            cell.toastWarn("举报成功")
        }
        popup.addButtons([buttonReport])
        

        // Present dialog
        present(popup, animated: true, completion: nil)
    }
    
    private func showLoginDialog() {

        if UserManager.sharedManager.current_user != nil {
            return
        }
        // Create a custom view controller
        let loginVC = FT_LoginController()
       

        // Create the dialog
        let popup = PopupDialog(viewController: loginVC,
                                buttonAlignment: .vertical,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true)
        
        loginVC.closeDone = {
            popup.dismiss()
        }
     

        // Present dialog
        present(popup, animated: true, completion: nil)
    }
}
