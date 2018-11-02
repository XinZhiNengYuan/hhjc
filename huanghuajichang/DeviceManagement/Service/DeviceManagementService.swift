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
    var oneMeanIdList : Array<String>!
    var subMeanNameList : Array<String>!
    var subMeanIdList : Array<String>!
    var subMeanList : NSMutableArray!
    func getData(contentData : Dictionary<String,Any>,finished:@escaping (_ successData:JSON,_ oneMeanList : NSMutableArray) -> (),finishedError:@escaping (_ errorData: Error) -> ()){
        commonClass.requestData(urlStr: appUrl!, outTime: 60, contentData: contentData, finished: { (result) in
            print(result)
            print(result["data"].count)
            for i in 0..<result["data"].count{
                
                print(result["data"][i]["text"].description)
                self.oneMeanNameList.add(result["data"][i]["text"].stringValue)
            }
            finished(result,self.oneMeanNameList)
            
        }) { (errorData) in
            finishedError(errorData)
        }
    }
}
