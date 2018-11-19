//
//  AlarmAnalysisViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/2.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
class AlarmAnalysisViewService : common{
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    
    func gitData(contentData : Dictionary<String,Any>){
        super.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            if result["status"] == "success"{
                print("报警详情：\(result["data"])")
            }else{
                print("网络错误提示:\(result["status"])")
            }
        }) { (error) in
            print(error)
        }
    }
}
