//
//  DemoCollectionViewCell.swift
//  TestCollectionView
//
//  Created by Even_cheng on 12/09/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import LeanCloud

class DemoCollectionViewCell: BasePageCollectionCell {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet weak var leftNameLabel: UILabel!
    @IBOutlet weak var leftCaremaLabel: UILabel!
    @IBOutlet weak var rightTopLabel: UILabel!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var backViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var frontViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var frontViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var authIconView: UIImageView!
    @IBOutlet weak var authNameLabel: UILabel!
    
    @IBOutlet weak var stateIconView: UIImageView!
    @IBOutlet weak var favoriteButton: DOFavoriteButton!
    @IBOutlet weak var likeButton: DOFavoriteButton!
    @IBOutlet weak var moreCommmentButton: UIButton!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var download_bgButton: DownloadButton!
    
    typealias MoreActionsClickBlock = ()->()
    var moreClick:MoreActionsClickBlock?
    var authClick:MoreActionsClickBlock?

    open var product: Product? {
        didSet {
            guard let product = product else{
                return
            }
            
            let like = UserManager.sharedManager.isLike(product: product)
            self.favoriteButton?.isSelected = like
            self.likeButton?.isSelected = like
            self.moreCommmentButton.setTitle(" \(product.comments?.count ?? 0)", for: UIControl.State.normal)
            self.buildAvatarForLikes(product)
            self.productTitleLabel.text = product.title?.value
            stateIconView.isHidden = product.state.intValue == 1
            stateIconView.image = UIImage.init(named: product.state.intValue == -1 ? "check_failed" : "checking")
            leftNameLabel.text = product.location?.value
            leftCaremaLabel.text = product.camera?.value
            authLabel.text = product.auth_name?.value
            authNameLabel.text = product.auth_name?.value
            if product.auth_avatar?.value != nil {
                authIconView.kf.setImage(with: URL.init(string: product.auth_avatar!.value))
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        backViewWidthConstraint.constant = kWindowBounds.width*0.85;
        backViewHeightConstraint.constant = kWindowBounds.height*0.7;
        frontViewWidthConstraint.constant = kWindowBounds.width*0.85;
        frontViewHeightConstraint.constant = kWindowBounds.height*0.7;
        
        super.awakeFromNib()
        
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 0.1

        stateIconView.layer.shadowRadius = 1
        stateIconView.layer.shadowOffset = CGSize(width: 0, height: 0)
        stateIconView.layer.shadowOpacity = 0.65
        
        moreCommmentButton.layer.shadowRadius = 0.5
        moreCommmentButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        moreCommmentButton.layer.shadowOpacity = 1
        moreCommmentButton.layer.shadowColor = UIColor.white.cgColor

        leftNameLabel.layer.shadowRadius = 0.5
        leftNameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        leftNameLabel.layer.shadowOpacity = 0.7
        
        leftCaremaLabel.layer.shadowRadius = 0.5
        leftCaremaLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        leftCaremaLabel.layer.shadowOpacity = 0.7
        
        rightTopLabel.layer.shadowRadius = 0.5
        rightTopLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        rightTopLabel.layer.shadowOpacity = 0.7

        authLabel.layer.shadowRadius = 0.5
        authLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        authLabel.layer.shadowOpacity = 0.7
    }
    
    func buildAvatarForLikes(_ product: Product) {
             
        guard let like_users = product.liked_users else {
            self.likesCountLabel.text = "暂无人喜欢，快去抢沙发~"
            return
        }
        if like_users.count > 0 {
            self.likesCountLabel.text = "获得\(like_users.count)人喜欢"
        } else {
            self.likesCountLabel.text = "暂无人喜欢，快去抢沙发~"
        }
    }
    
    @IBAction func likeAction(_ sender: DOFavoriteButton) {

        guard let product = product else {
            return;
        }
        
        if sender.isSelected {
            FTAPI.unLike(product)
            likeButton.deselect()
            favoriteButton.deselect()
        } else {
            FTAPI.like(product)
            likeButton.select()
            favoriteButton.select()
        }
        
        buildAvatarForLikes(product)
    }
    
    @IBAction func saveImageAction(_ sender: DownloadButton) {
        guard let url = product?.file_url?.value else {return}
        sender.startDownload(url)
    }
    
    @IBAction func authCenterAction(_ sender: Any) {
        
        authClick?()
    }
    
    @IBAction func showMoreAction(_ sender: Any) {

        moreClick?()
    }
}

extension DemoCollectionViewCell {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
     
        var view = super.hitTest(point, with:event);
        if view == nil && self.isOpened == true{
            // 转换坐标系
            let likePoint = likeButton.convert(point, from:self)
            let commentPoint = moreCommmentButton.convert(point, from:self)

            if likeButton.bounds.contains(likePoint) {
                view = likeButton;
            } else if moreCommmentButton.bounds.contains(commentPoint) {
                view = moreCommmentButton;
            }
        }

        return view;
        
    }
}
