//
//  ProductInfoCell.swift
//  fototo
//
//  Created by Even_cheng on 2019/11/1.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

class ProductInfoCell: UITableViewCell {
    
    @IBOutlet weak var receiveLikesLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: DOFavoriteButton!
    
    open var product: Product? {
        didSet{
            guard let product = product else {return}
            self.likeButton?.isSelected = UserManager.sharedManager.isLike(product: product)
            self.receiveLikesLabel.text = "获得\(product.liked_users?.count ?? 0)人喜欢"
            self.titleLabel.text = product.title?.value
            self.commentLabel.text = "\(product.comments?.count ?? 0)人正在讨论"
            self.likeButton?.isHidden = false
        }
    }

}
