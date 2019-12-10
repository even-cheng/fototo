//
//  ProductCommentController.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/11.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

class ProductCommentController: UIViewController {

    open var product: Product? {
        didSet{
            guard let product = product else{
                return
            }
           
            self.commentLabel?.text = "\(product.liked_users?.count ?? 0)人喜欢"
            self.likeButton?.isSelected = UserManager.sharedManager.isLike(product: product)
            commentTableView.reloadData()
        }
    }

    fileprivate var likeButton: DOFavoriteButton?
    fileprivate var commentLabel: UILabel?

    lazy var commentTableView: UITableView = {
        
        let commentTab = UITableView.init(frame: CGRect.init(x: 0, y: 60, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-60-40), style: UITableView.Style.plain)
        commentTab.delegate = self
        commentTab.dataSource = self
        commentTab.register(UINib.init(nibName: "ProductCommentCell", bundle: nil), forCellReuseIdentifier: "ProductCommentCell")
        
        return commentTab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        
        setupViews()
    }

    func setupViews() {
        
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 59))
        topView.backgroundColor = UIColor.white
        
        let titleLab = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 120, height: 59))
        titleLab.text = "评论列表"
        titleLab.textColor = UIColor.darkText
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        topView.addSubview(titleLab)
        
        let commentLab = UILabel.init(frame: CGRect.init(x: 120, y: 20, width: self.view.width-120-90, height: 20))
        commentLabel = commentLab
        if product != nil {
            commentLab.text = "获得\(product!.liked_users?.count ?? 0)人喜欢"
        } else {
            commentLab.text = "获得0人喜欢"
        }
        commentLab.textColor = UIColor.lightGray
        commentLab.font = UIFont.systemFont(ofSize: 12)
        commentLab.textAlignment = NSTextAlignment.right
        topView.addSubview(commentLab)
        
        let favorite = DOFavoriteButton.init(frame: CGRect.init(x: self.view.width-85, y: 12, width: 36, height: 36))
        likeButton = favorite
        favorite.image = UIImage.init(named: "heart")
        favorite.imageColorOn = UIColor.red
        favorite.imageColorOff = UIColor.lightGray
        favorite.circleColor = UIColor.orange
        favorite.lineColor = UIColor.purple
        if product != nil {
            favorite.isSelected = UserManager.sharedManager.isLike(product: product!)
        }
        favorite.addTarget(self, action: #selector(favoriteAction(_:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(favorite)
        
        let download = DownloadButton.init(frame: CGRect.init(x: self.view.width-50, y: 10, width: 40, height: 40))
        download.addTarget(self, action: #selector(downloadAction(_:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(download)

        view.addSubview(topView)
        view.addSubview(self.commentTableView)
    }
    
    @objc func downloadAction(_ sender: DownloadButton?) {

        guard let url = product?.file_url?.value else {return}
        sender?.startDownload(url)
    }
    
    @objc func favoriteAction(_ sender: DOFavoriteButton?) {
        guard let product = product else{
            return
        }
        if sender!.isSelected {
            sender!.deselect()
            FTAPI.unLike(product)
        } else {
            sender!.select()
            FTAPI.like(product)
        }
        commentLabel?.text = "获得\(product.liked_users?.count ?? 0)人喜欢"
    }
}


extension ProductCommentController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.product?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCommentCell", for: indexPath) as! ProductCommentCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
}

extension ProductCommentController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100  {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
