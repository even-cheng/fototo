//
//  Product.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/26.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import LeanCloud

class Product: LCObject {
    
    override static func objectClassName() -> String {
        return "Product"
    }
    
    @objc dynamic var userid: LCString?
    @objc dynamic var auth_name: LCString?
    @objc dynamic var auth_avatar: LCString?
    @objc dynamic var file_url: LCString?
    @objc dynamic var file_id: LCString?
    @objc dynamic var title: LCString?
    @objc dynamic var location: LCString?
    @objc dynamic var camera: LCString?
    @objc dynamic var state: LCNumber = 0
    
    @objc dynamic var comments: LCArray?
    @objc dynamic var liked_users: LCArray?
}

