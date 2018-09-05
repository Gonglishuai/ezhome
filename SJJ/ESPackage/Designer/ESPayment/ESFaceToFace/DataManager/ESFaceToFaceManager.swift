//
//  ESFaceToFaceManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import CoreImage

class ESFaceToFaceManager: NSObject {
    
    static func requestQRUrl(_ assetId: String,
                             _ amount: Double,
                             _ payType: String,
                             success: @escaping (_ url: String) -> Void,
                             failure: @escaping (String) -> Void) {
        let dict = ["projectNum": assetId, "orderAmount": String(amount), "payType": payType]
        ESPackageOrderApi.orderFace2Face(info: dict, success: { (response) in
            if let data = response {
                let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if let dic = dict as? [String: Any?], let qrUrl = dic["url"] as? String {
                    
                    success(qrUrl)
                    return
                }
            }
            
            failure("生成二维码失败，请稍后重试!")
        }) { (error) in
            failure("生成二维码失败，请稍后重试!")
        }
    }
    
    static func checkPayStatus(_ assetId: String,
                               success: @escaping (_ complete: Bool) -> Void,
                               failure: @escaping (String) -> Void) {
        ESAppointApi.getGatheringDetail(assetId, success: { (data) in
            
            let deatilModel = try? JSONDecoder().decode(ESGatheringDetailsModel.self, from: data)
            
            if let unPaidAmount = deatilModel?.data?.unPaidAmount {
                if unPaidAmount == 0 {
                    success(true)
                } else {
                    success(false)
                }
                return
            }
            
            failure("网络错误, 请稍后重试!")
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    static func createQRCode(_ url: String?, complete: @escaping (_ qrImage: UIImage?) -> Void ) {
        if let qrUrl = url, !qrUrl.isEmpty {
            DispatchQueue.global().async {
                let filter = CIFilter(name: "CIQRCodeGenerator")
                filter?.setDefaults()
                let data = qrUrl.data(using: String.Encoding.utf8)
                filter?.setValue(data, forKey: "inputMessage")
                filter?.setValue("M", forKey: "inputCorrectionLevel")
                let outputImage = filter?.outputImage
                let image = ESFaceToFaceManager.createUIImage(outputImage, 300.0)
                DispatchQueue.main.async {
                    complete(image)
                }
            }
        }
    }
    
    static private func createUIImage(_ ciimage: CIImage?, _ width: CGFloat) -> UIImage? {
        var result: UIImage?
        if let image = ciimage {
            let extent = image.extent.integral
            let scale = min((width / extent.width), (width / extent.height))
            let width = extent.width * scale
            let height = extent.height * scale
            let cs = CGColorSpaceCreateDeviceGray()
            let bitmapRef = CGContext.init(data: nil,
                                           width: Int(width),
                                           height: Int(height),
                                           bitsPerComponent: 8,
                                           bytesPerRow: 0,
                                           space: cs,
                                           bitmapInfo: CGImageAlphaInfo.none.rawValue)
            let context = CIContext(options: nil)
            bitmapRef?.interpolationQuality = .none
            bitmapRef?.scaleBy(x: scale, y: scale)
            
            if let bitmapImage = context.createCGImage(image, from: extent) {
                bitmapRef?.draw(bitmapImage, in: extent)
                let scaledImage = bitmapRef?.makeImage()
                if let sImage = scaledImage {
                    result = UIImage(cgImage: sImage)
                }
            }
        }
        
        return result
    }
}
