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
    let oneMean : NSMutableArray = NSMutableArray()
    let subMean : NSMutableArray = NSMutableArray()
    let commonClass = common()
    func getData(contentData : Dictionary<String,Any>){
        print(contentData)
        commonClass.requestData(urlStr: appUrl!, outTime: 60, contentData: contentData, finished: { (result) in
            print(type(of: result["data"][0]["text"]))
//            let str = String(result:Data, encoding: String.Encoding.utf8)
        
            for index in 0..<result["data"].count{
                self.oneMean.add(JSON(result["data"])[index]["text"])
                self.subMean.add(result["data"][index]["children"].description)
            }
            print(self.oneMean)
            print(self.subMean)
        }) { (errorData) in
            print("失败：\(errorData)")
        }
    }
}
