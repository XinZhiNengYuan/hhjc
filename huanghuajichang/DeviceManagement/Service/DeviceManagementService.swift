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
    var oneMeanList : Array<Dictionary<String,String>> = []
    var subMeanList : Array<Dictionary<String,String>> = []
    func getData(contentData : Dictionary<String,Any>,finished:@escaping (_ resultDataForOneMean : Array<Dictionary<String,String>>,_ resultDataForSubMean : Array<Dictionary<String,String>>) -> (),finishedError:@escaping (_ errorData: Error) -> ()){
        commonClass.requestData(urlStr: appUrl!, outTime: 60, contentData: contentData, finished: { (result) in
            for i in 0..<result["data"].count{
                //组装一级菜单
                self.oneMeanList.append(["id":result["data"][i]["id"].description,"text":result["data"][i]["text"].description,"open":result["data"][i]["open"].description,"stationId":result["data"][i]["stationId"].description,"pid":result["data"][i]["pid"].description])
                //二级菜单
                for j in 0..<result["data"][i]["children"].count{
                    
                    self.subMeanList.append(["id":result["data"][i]["children"][j]["id"].description,"stationId":result["data"][i]["children"][j]["stationId"].description,"text":result["data"][i]["children"][j]["text"].description])
                }
            }
            finished(self.oneMeanList,self.subMeanList)
//            print(self.oneMeanList)
        }) { (errorData) in
            finishedError(errorData)
        }
    }
}
