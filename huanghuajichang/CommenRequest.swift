//
//  PublicParamter.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/1.
//  Copyright © 2018年 jun. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
enum MethodType {
    case get
    case post
}
var userDefault = UserDefaults.standard

class NetworkTools {
    class func requestData(_ type : MethodType, URLString : String, parameters : [String : Any]? = nil, finishedCallback :  @escaping (_ result : DataResponse<Any>) -> ()) {
        
        // 1.获取类型
        let method = type == .get ? HTTPMethod.get : HTTPMethod.post
        
        //2.基础配置
        let userDefalutUrl = userDefault.string(forKey: "AppUrlAndPort")
        let urlStr = "\(URLString)://\(userDefalutUrl ?? "10.4.65.103:8086")/interface"
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        //3.发送网络请求
        sessionManager.request(urlStr, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (resultData) in
            
            // 4.获取结果
//            guard let result = resultData.result.value else {
//                print(resultData.result.error!)
//                return
//            }
            
            // 5.将结果回调出去
            finishedCallback(resultData)
            
            }.session.finishTasksAndInvalidate()
    }
    /// 图片上传
    ///
    /// - Parameters:
    ///   - urlString: 服务器地址
    ///   - params: 参数 ["token": "89757", "userid": "nb74110"]
    ///   - images: image数组
    ///   - success: 成功闭包
    ///   - failture: 失败闭包
    class func upload(urlString : String, params:[String : String]?, images: [UIImage], success: @escaping (_ response : Any?) -> (), failture : @escaping (_ error : Error)->()) {
        
        let userDefalutUrl = userDefault.string(forKey: "AppUrlAndPort")
        let urlStr = "\(urlString)://\(userDefalutUrl ?? "10.4.65.103:8086")/app/uploadfile"
        let headers: HTTPHeaders = [
            "Accept": "application/json;charset=utf-8",
            "lang":"en-US"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if params != nil {
                for (key, value) in params! {
                    //参数的上传
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
            }
            for (index, value) in images.enumerated() {
                let imageData = UIImageJPEGRepresentation(value, 1.0)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let str = formatter.string(from: Date())
                let fileName = str+"\(index)"+".jpg"
                
                // 以文件流格式上传
                // 批量上传与单张上传，后台语言为java或.net等
                multipartFormData.append(imageData!, withName: "file", fileName: fileName, mimeType: "image/jpeg")
                // 单张上传，后台语言为PHP
                //                multipartFormData.append(imageData!, withName: "fileupload", fileName: fileName, mimeType: "image/jpeg")
                // 批量上传，后台语言为PHP。 注意：此处服务器需要知道，前台传入的是一个图片数组
                //                multipartFormData.append(imageData!, withName: "fileupload[\(index)]", fileName: fileName, mimeType: "image/jpeg")
            }
        },
                         to: urlStr,
                         headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
//                                    print("response = \(response)")
                                    let result = response.result
                                    if result.isSuccess {
                                        success(response.value)
                                    }
                                }
                            case .failure(let encodingError):
                                failture(encodingError)
                            }
        }
        )
    }
    

}
