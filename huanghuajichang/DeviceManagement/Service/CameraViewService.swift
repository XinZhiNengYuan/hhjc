//
//  CameraViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/13.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CameraViewService : common{
    //图片上传接口
    
    func upLoadPic(images : [UIImage],finished:@escaping (_ arr:String)->(),finishedError:()->()){
        var fileIdList : [Int] = []
        super.upload(params: nil, images: images, success: { (success) in
            if success["status"] == "success"{
                
                if let data = success["data"].arrayObject{
                    for item in data{
                        let it = item as! Dictionary<String,Any>
                        fileIdList.append(it["fileId"] as! Int)
                    }
                    var filesIdStr = ""
                    for i in fileIdList{
                        filesIdStr = filesIdStr + String(i) + ","
                    }
                    if filesIdStr.count > 0{
                        let endIndex = filesIdStr.index(filesIdStr.endIndex,offsetBy:-1)
                        filesIdStr = String(filesIdStr.prefix(upTo: endIndex))
                    }
                    finished(filesIdStr)
                }
            }
        }) { (error) in
            print(error)
        }
    func upLoadPic(contentData : Dictionary<String,Any>,finished:()->(),finishedError:()->()){
//        super.upload(params: <#T##[String : String]?#>, images: <#T##[UIImage]#>, success: <#T##(Any?) -> ()#>, failture: <#T##(Error) -> ()#>)
    }

    //MARK:图片id和设备id相互绑定
    func picIdAndEquId(contentData : Dictionary<String, Any>,successCall:@escaping ()->(),errorCall:@escaping()->()){
        super.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            if result["status"] == "success"{
                successCall()
            }
        }) { (error) in
            errorCall()
            print(error)
        }
    }
    
}
