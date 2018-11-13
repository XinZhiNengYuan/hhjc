//
//  AppUpdateAlertService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppUpdateAlertService : NSObject{
    
    let commonClass = common()
    //请求数据
    func getData(contentData:Dictionary<String,Any>,finished:@escaping (_ result : JSON)->(),finishedError:@escaping (_ : Error)->()){
        commonClass.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            print(result)
            finished(result)
        }) { (error) in
            print(error)
            finishedError(error)
        }
    }
}
