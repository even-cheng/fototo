//
//  UserManager.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/12.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import LeanCloud

extension LCUser {
    
    @objc dynamic var userInfo: UserInfo? {
        
        set{
            try? self.set("userInfo", value: newValue)
        }
        
        get{
            return self.value(forKey: "userInfo") as? UserInfo
        }
    }
}

class UserManager {
    
    var current_user: LCUser?
    
    static var sharedManager: UserManager = {
        let instance = UserManager()
        // setup code
        return instance
    }()
    
    public func registerUser(username:String?, pwd:String?, complete: @escaping (Bool) -> ()) {
        
        self.saveUserInfo(username: username!, nickname: nil, avatar: nil){ (info: UserInfo?) in
            if info != nil {
                
                let user = LCUser()
                user.username = LCString(username!)
                user.password = LCString(pwd!)
                _ = user.signUp() {[weak self] (result) in
                            
                    switch result {
                    case .success:
                        info?.user_objectId = user.objectId
                        if info?.save().isSuccess == true {
                            user.userInfo = info!
                            self?.current_user = user
                            complete(true)
                        } else {
                            complete(false)
                        }
                    case .failure:
                        complete(false)
                    }
                }
                
            } else {
                complete(false)
            }
        }
    }
    
    //保存用户资料
    public func saveUserInfo(username:String?, nickname:String?, avatar:String?, complete: @escaping (UserInfo?) -> ()) {
        
        let userinfo = UserInfo()
        if username != nil {
            userinfo.username = LCString(username!)
        }
        if nickname != nil {
            userinfo.nickname = LCString(nickname!)
        }
        if avatar != nil {
            userinfo.avatar = LCString(avatar!)
        }
        _ = userinfo.save { result in
            switch result {
            case .success:
                complete(userinfo)
            case .failure(error: let error):
                // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                print(error)
                complete(nil)
            }
        }
    }
    
    
    public func selfInfo(complete: @escaping (UserInfo?) -> ()) {
        
        //查询用户数据
        guard let current = LCApplication.default.currentUser else {
            complete(nil)
            return
        }

        self.getUserInfo(current.username!.value, complete: complete)
    }
    
    
    //查询用户资料
    public func getUserInfo(_ username:String, complete: @escaping (UserInfo?) -> ()) {
        
        //查询用户数据
        let query = LCQuery(className: "UserInfo")
        query.whereKey("username", .equalTo(username))
        _ = query.getFirst { (result: LCValueResult<UserInfo>) in

            switch result {
            case .success(object: let user):
                complete(user)
                break
            case .failure(error: let error):
                print(error)
                complete(nil)
            }
        }
    }
    
    //查询用户资料
    public func getUserInfo(objectId:String, complete: @escaping (UserInfo?) -> ()) {
        
        //查询用户数据
        let query = LCQuery(className: "UserInfo")
        query.whereKey("user_objectId", .equalTo(objectId))
        _ = query.getFirst { (result: LCValueResult<UserInfo>) in

            switch result {
            case .success(object: let user):
                DispatchQueue.global(qos: .background).async {
                    self.fetchProducts(user)
                }
                complete(user)
                break
            case .failure(error: let error):
                print(error)
                complete(nil)
            }
        }
    }
    
    //同步发布的作品信息
    private func fetchProducts(_ usr: UserInfo) {
        guard let posts = usr.posted_products else {
            return
        }
        guard let posts_product = posts.value as? [Product] else {
            return
        }
        for product: Product in posts_product {
            _ = product.fetch(keys: ["liked_users"])
        }
        
        guard let likes = usr.liked_products else {
            return
        }
        guard let likes_product = likes.value as? [Product] else {
            return
        }
        for product: Product in likes_product {
            _ = product.fetch(keys: ["liked_users"])
        }
    }
    
    public func login(username:String?, pwd:String?, complete: @escaping (Bool) -> ()) {

        _ = LCUser.logIn(username: username!, password: pwd!) {[weak self] (result: LCValueResult<LCUser>) in
            switch result {
            case .success:
                self?.getUserInfo(username!, complete: { (info: UserInfo?) in
                    if info == nil {
                        self?.saveUserInfo(username: username, nickname: nil, avatar: nil, complete: { (info :UserInfo?) in
                            
                            self?.current_user = result.object
                            self?.current_user?.userInfo = info
                            complete(true)
                        })
                    } else {
                        
                        self?.current_user = result.object
                        self?.current_user?.userInfo = info
                        complete(true)
                    }
                })
            case .failure:
                complete(false)
            }
        }
    }
  
    public func checkProducts(user_objectId: String, offset: Int, limit: Int = 20, complete: @escaping ([Product]?) -> ()) {
        
        //查询用户数据
        let query = LCQuery(className: "Product")
        query.whereKey("userid", .equalTo(user_objectId))
        if user_objectId != current_user?.userInfo?.user_objectId?.value {
            query.whereKey("state", .equalTo(1))
        }
        query.limit = limit
        query.skip = offset
        _ = query.find { (result: LCQueryResult<Product>) in
            
            switch result {
            case .success(objects: let products):
                // students 是包含满足条件的 Product 对象的数组
                complete(products)
                break
            case .failure(error: let error):
                print(error)
                complete(nil)
            }
        }
    }
    
    
    public func isLike(product: Product) -> Bool {
        
        guard let liked_products = current_user?.userInfo?.liked_products else {
            return false
        }
        let likes: [Product] = liked_products.value as! [Product]
        return likes.contains(product)
    }
    
    public func updateAvatar(_ image: Image, complete: @escaping (String?) -> ()) {
        
        guard let imgData = image.pngData() else {
            complete(nil)
            return
        }
        FTAPI.uploadFileData(imgData) { (_ file) in
            
            if file != nil {
                
                self.current_user?.userInfo?.avatar = file?.url
                complete(file?.url!.value)
                _ = self.current_user?.save(completion: { (_: LCBooleanResult) in
                    
                })
                
            } else {
                complete(nil)
            }
        }
    }
}
