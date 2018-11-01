//
//  DeviceManagementService.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/31.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import SwiftyJSON

class DeviceManagementService : common{
    
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    let oneMeanList : NSMutableArray = NSMutableArray()
    let subMeanList : NSMutableArray = NSMutableArray()
    let commonClass = common()
    func getData(contentData : Dictionary<String,Any>){
        commonClass.requestData(urlStr: appUrl!, outTime: 60, contentData: contentData, finished: { (result) in
            print(result)
            //json 的可用性判断
//            if !JSONSerialization.isValidJSONObject(result) {
//                print("不能转化")
//                return
//            }
            for index in 0..<result["data"].count{
                let data = try? JSONSerialization.data(withJSONObject: result["data"][index]["text"], options: [])
                let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
                

                //json 字符串转换为data
//                guard let data = try? JSONSerialization.data(withJSONObject: result["data"][index]["text"], options: .prettyPrinted) else { return }
                //data 转为字符串
//                let jsonstr = String(data: data, encoding: .utf8)
                self.oneMeanList.add(jsonStr as Any)
//                self.subMeanList.add(result["data"][index]["children"])
            }
            print(self.oneMeanList)
//            print(self.subMeanList)
        }) { (errorData) in
            print("失败：\(errorData)")
        }
    }
}
