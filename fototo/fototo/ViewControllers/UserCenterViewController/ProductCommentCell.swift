//
//  ProductCommentCell.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/11.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation

class ProductCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    open var comment: Comment? {
        didSet{
            guard let comment = comment else {return}
            
            self.avatarImageView.kf.setImage(with: URL.init(string: comment.user!.avatar!.value))
            self.contentLabel.text = comment.content?.value
//            self.nicknameLabel.text = "获得\(product.liked_users?.count ?? 0)人喜欢"
//            self.dateLabel.text = "\(product.comments?.count ?? 0)人正在讨论"
        }
    }
}
