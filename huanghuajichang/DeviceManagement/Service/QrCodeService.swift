//
//  QrCodeService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/30.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import SwiftyJSON

class QrCodeService: common {
    func getQrCode(contentData : Dictionary<String,Any>,finishedData : @escaping (_ successData:JSON)->(),errorCall:@escaping (_ errorData:Error)->()){
        super.requestData(urlStr: appUrl, outTime: 10, contentData: contentData, finished: { (result) in
            finishedData(result)
        }) { (errorData) in
            errorCall(errorData)
        }
    }
}
