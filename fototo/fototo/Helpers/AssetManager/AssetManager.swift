import Foundation
import UIKit
import Photos

open class AssetManager {
    
    public static func fetchAll(_ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            
            if status != .authorized {
                let del = UIApplication.shared.delegate as! AppDelegate
                del.window?.toastError("请前往设置-隐私-照片，打开Fototo的相关权限")
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
                
                if fetchResult.count > 0 {
                    var assets = [PHAsset]()
                    fetchResult.enumerateObjects({ object, _, _ in
                        assets.insert(object, at: 0)
                    })
                    
                    DispatchQueue.main.async {
                        completion(assets)
                    }
                }
            }
        }
    }
    
    public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, progress: PHAssetImageProgressHandler?, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.progressHandler = progress
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async(execute: {
                    completion(image)
                })
            }
        }
    }
    
    public static func synchronizeAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), progress: PHAssetImageProgressHandler?) -> UIImage? {
      
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.progressHandler = progress
        var backImage: UIImage?
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
            if let image = image {
                backImage = image
            }
        }
        return backImage
    }
}
