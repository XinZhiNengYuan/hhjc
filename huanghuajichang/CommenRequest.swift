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
}
