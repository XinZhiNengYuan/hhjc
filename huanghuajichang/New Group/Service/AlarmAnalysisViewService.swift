//
//  AlarmAnalysisViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/2.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
class AlarmAnalysisViewService : NSObject{
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    let commonClass = common()
    
    func gitData(contentData : Dictionary<String,Any>){
        commonClass.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            print(type(of: result))
        }) { (error) in
            print(error)
        }
    }
}
