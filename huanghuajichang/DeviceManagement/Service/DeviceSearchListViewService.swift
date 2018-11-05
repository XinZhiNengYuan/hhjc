//
//  DeviceSearchListViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/5.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation

class DeviceSearchListViewService : NSObject{
    let commonClass = common()
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    func getData(contentData : Dictionary<String,Any>){
        commonClass.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            print(result)
        }) { (error) in
            print(error)
        }
    }
}
