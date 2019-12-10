//
//  FTAPI.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/26.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import LeanCloud

struct FTAPI {
    
    enum APIErrorType: Error {
        case failureWithUploadFile
        case failureWithSaveObject
        case failureWithThrowError
    }
    
    static func uploadFileData(_ data: Data, complete: @escaping (LCFile?) -> ()){
        
        let file = LCFile(payload: .data(data: data))
        _ = file.save { result in
            switch result {
            case .success:
                complete(file)
            case .failure(error: let error):
                // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                print(error)
                complete(nil)
            }
        }
    }
    
    static func postProduct(_ product: Product, img: Image, complete: @escaping (Result<Int, APIErrorType>) -> ()){
        
        guard let imgData = img.pngData() else {
            complete(.failure(.failureWithUploadFile))
            return
        }
        uploadFileData(imgData) { (_ file) in
            
            if file != nil {
    
                product.file_id = file?.objectId
                product.file_url = file?.url
                product.userid = UserManager.sharedManager.current_user?.objectId
                product.auth_name = UserManager.sharedManager.current_user?.userInfo?.nickname
                product.auth_avatar = UserManager.sharedManager.current_user?.userInfo?.avatar
                let result = product.save()
                if let error = result.error {
                    print(error)
                    complete(.failure(.failureWithSaveObject))
                } else {
                    
                    //查询用户数据
                    guard let userInfo: UserInfo = UserManager.sharedManager.current_user?.userInfo else {return}
                    guard let posted_products = userInfo.posted_products else {
                        userInfo.posted_products = [product]
                        if userInfo.save().isSuccess {
                            UserManager.sharedManager.current_user?.userInfo = userInfo
                            print("发布成功")
                            complete(.success(1))
                        } else {
                            complete(.failure(.failureWithSaveObject))
                        }
                        return;
                    }
                    var posts: [Product] = posted_products.value as! [Product]
                    posts.append(product)
                    try? userInfo.set("posted_products", value: posts)
                    if userInfo.save().isSuccess {
                        print("发布成功")
                        complete(.success(1))
                    } else {
                        complete(.failure(.failureWithSaveObject))
                    }
                }
    
            } else {
                complete(.failure(.failureWithUploadFile))
            }
        }
    }
    
    static func checkNewProducts(offset: Int, limit: Int = 20, complete: @escaping ([Product]?) -> ()) {
        
        //查询用户数据
        let query = LCQuery(className: "Product")
        query.whereKey("createdAt", .descending)
        query.whereKey("state", .equalTo(LCNumber(1)))
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
    
    static func like(_ product: Product) {
        
        //查询用户数据
        guard let userInfo: UserInfo = UserManager.sharedManager.current_user?.userInfo else {return}
        guard let liked_products = userInfo.liked_products else {
            userInfo.liked_products = [product]
            _ = userInfo.save(completion: { (_: LCBooleanResult) in
                
            })
            UserManager.sharedManager.current_user?.userInfo = userInfo

            if product.liked_users == nil {
                product.liked_users = LCArray.init()
            }
            try? product.append("liked_users", element: userInfo.user_objectId!, unique: true)
            _ = product.save(completion: { (_: LCBooleanResult) in
                
            })
            return;
        }
        let likes: [Product] = liked_products.value as! [Product]
        if !likes.contains(product)
        {
            try? userInfo.append("liked_products", element: product, unique: true)
            _ = userInfo.save(completion: { (_: LCBooleanResult) in
                
            })
            
            if product.liked_users == nil {
                product.liked_users = LCArray.init()
            }
            try? product.append("liked_users", element: userInfo.user_objectId!, unique: true)
            _ = product.save(completion: { (_: LCBooleanResult) in
                
            })
        }
    }
    
    static func unLike(_ product: Product) {
        
        //查询用户数据
        guard let userInfo = UserManager.sharedManager.current_user?.userInfo else {return}
        guard let liked_products = userInfo.liked_products else {
            return;
        }
        let likes: [Product] = liked_products.value as! [Product]
        if likes.contains(product)
        {
            try? userInfo.remove("liked_products", element: product)
            _ = userInfo.save(completion: { (_: LCBooleanResult) in
                
            })
            UserManager.sharedManager.current_user?.userInfo = userInfo
            if product.liked_users != nil {
                try? product.remove("liked_users", element: userInfo.user_objectId!)
                _ = product.save(completion: { (_: LCBooleanResult) in
                        
                })
            }
        }
    }
    
    static func addComment(to product: Product, content: String) {
        
        guard let userInfo = UserManager.sharedManager.current_user?.userInfo else {return}
        let comment = Comment()
        comment.content = LCString(content)
        try? comment.set("user", value: userInfo)
        var product_comment: [Comment] = product.comments?.value as! [Comment]
        product_comment.append(comment)
        try? product.set("comments", value: product_comment)
        product.save { (res: LCBooleanResult) in
            if res.isSuccess {
                print("评论成功")
            }
        }
    }
}

