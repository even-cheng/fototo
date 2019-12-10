//
//  UserInfo.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/30.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import LeanCloud

class UserInfo: LCObject {
    
    override static func objectClassName() -> String {
        return "UserInfo"
    }
    
    @objc dynamic var user_objectId: LCString?
    @objc dynamic var username: LCString?
    @objc dynamic var nickname: LCString?
    @objc dynamic var introduce: LCString?
    @objc dynamic var avatar: LCString?
    
    @objc dynamic var liked_products: LCArray?
    @objc dynamic var posted_products: LCArray?
}

