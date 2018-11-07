//
//  DeviceSearchListViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/5.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import SwiftyJSON

class DeviceSearchListViewService : NSObject{
    let commonClass = common()
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    var arrDic : Array<Dictionary<String,Any>> = []
    func getData(contentData : Dictionary<String,Any>,finished:@escaping (_ resultData:JSON,_ newArr : Array<Dictionary<String,Any>>)->(),finishedError:@escaping (_ errorData : Error)->()){
        commonClass.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            //JSON转化为Dictionary字典（[String: AnyObject]?）
            if let dic = result.dictionaryObject {
                //Do something you want
                if dic["status"] as! String == "success"{
                    //                    print(dic["data"] as Any)
                }
                //JSON转化为Array数组（[AnyObject]?）
                let arr = result["data"]["resultData"].arrayValue
                if !arr.isEmpty {
                    for item in arr{
                        self.arrDic.append(item.dictionaryObject!)
                    }
                    finished(result,self.arrDic)
                }
            }
        }) { (error) in
            print(error)
            finishedError(error)
        }
    }
}
