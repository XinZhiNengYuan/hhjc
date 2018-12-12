//
//  DeviceDetailViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/8.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import SwiftyJSON

class DeviceDetailViewService : common {
    var deviceDetailViewModule = DeviceDetailViewModule()
    func getData(contentData : Dictionary<String,Any>,finishedData:@escaping (_ resultDataOption:DeviceDetailViewModule)->(),finishedError:@escaping (_ errorData:Error)->()){
        super.requestData(urlStr: appUrl, outTime: 10, contentData: contentData, finished: { (result) in
            if result["status"].stringValue == "success"{
                self.deviceDetailViewModule.equName = result["data"]["equName"].stringValue
                self.deviceDetailViewModule.power = Int(result["data"]["power"].stringValue)!
                self.deviceDetailViewModule.specification = result["data"]["specification"].stringValue
                self.deviceDetailViewModule.spName = result["data"]["spName"].stringValue
                self.deviceDetailViewModule.equNo = result["data"]["equNo"].stringValue
                self.deviceDetailViewModule.categoryNameSmall = result["data"]["categoryNameSmall"].stringValue
                self.deviceDetailViewModule.coOne = result["data"]["coOne"].stringValue
                self.deviceDetailViewModule.coTwo = result["data"]["coTwo"].stringValue
                self.deviceDetailViewModule.manufactureDate = result["data"]["manufactureDate"].stringValue
                self.deviceDetailViewModule.installDate = result["data"]["installDate"].stringValue
                self.deviceDetailViewModule.photoList = []
                for i in 0..<result["data"]["equPhotos"].count{
                    var equPhoto = equPhotos()
                    equPhoto.fileId = Int(result["data"]["equPhotos"][i]["fileId"].stringValue)!
                    equPhoto.filePath = result["data"]["equPhotos"][i]["filePath"].stringValue

                    self.deviceDetailViewModule.photoList.append(equPhoto)
                }
            }
            finishedData(self.deviceDetailViewModule)
        }) { (error) in
            finishedError(error)
        }
    }
    

}
