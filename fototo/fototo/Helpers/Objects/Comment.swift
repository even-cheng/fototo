//
//  Comment.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/26.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import LeanCloud

class Comment: LCObject {
    
    override static func objectClassName() -> String {
        return "Comment"
    }
    
    @objc dynamic var user: UserInfo?
    @objc dynamic var content: LCString?
}
