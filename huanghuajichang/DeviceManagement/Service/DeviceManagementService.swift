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
    let commonClass = common()
    var oneMeanNameList : NSMutableArray=[]
    var oneMeanIdList : NSMutableArray=[]
    var subMeanNameList : NSMutableArray=[]
    var subMeanIdList : NSMutableArray=[]
    var subMeanListForName : NSMutableArray = []
//    var a : [Any]!
    func getData(contentData : Dictionary<String,Any>,finished:@escaping (_ successData:JSON,_ meanList : Array<Any>) -> (),finishedError:@escaping (_ errorData: Error) -> ()){
        commonClass.requestData(urlStr: appUrl!, outTime: 60, contentData: contentData, finished: { (result) in
            //JSON转化为Dictionary字典（[String: AnyObject]?）
            if let dic = result.dictionaryObject {
                //Do something you want
                if dic["status"] as! String == "success"{
//                    print(dic["data"] as Any)
                }
                //JSON转化为Array数组（[AnyObject]?）
                if let arr = result["data"].arrayObject {
                    //Do something you want
//                    print(arr)
                    finished(result,arr)
                }
            }
            
        }) { (errorData) in
            finishedError(errorData)
        }
    }
}
