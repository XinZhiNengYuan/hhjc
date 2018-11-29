//
//  AddDeviceManagementService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/29.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddDeviceManagementService:common{
    var addDeviceManagementModule = AddDeviceManagementModule()
    //获取设备类别和单位
    func getEquipmentAndOrganization(contentData : Dictionary<String,Any>,finished:@escaping (_ resultData:JSON)->(),finishedError:@escaping (_ retErrorData:Error)->()) {
        super.requestData(urlStr: appUrl, outTime: 10, contentData: contentData, finished: { (result) in
            print("--------------------------------")
            print(result)
            if result["status"].stringValue == "success"{
                for item in result["data"]["organizationInfoList"].arrayValue{
                    if item["parentId"].intValue == 0{//j一级单位
                        var organizationOneList = OrganizationOneList()
                        organizationOneList.description = item["description"].stringValue
                        organizationOneList.organizationNo = item["organizationNo"].stringValue
                        organizationOneList.parentName = item["parentName"].stringValue
                        organizationOneList.phone = item["phone"].stringValue
                        organizationOneList.unitCategory = item["unitCategory"].stringValue
                        organizationOneList.locationY = item["locationY"].stringValue
                        organizationOneList.unitType = item["unitType"].stringValue
                        organizationOneList.unitState = item["unitState"].stringValue
                        organizationOneList.cimCode = item["cimCode"].stringValue
                        organizationOneList.email = item["email"].stringValue
                        organizationOneList.capacityName = item["capacityName"].stringValue
                        organizationOneList.createTime = item["createTime"].stringValue
                        organizationOneList.needAttr = item["needAttr"].stringValue
                        organizationOneList.organizationName = item["organizationName"].stringValue
                        organizationOneList.contacts = item["contacts"].stringValue
                        organizationOneList.capacityId = item["capacityId"].intValue
                        organizationOneList.organizationId = item["organizationId"].intValue
                        organizationOneList.locationX = item["locationX"].stringValue
                        organizationOneList.parentId = item["parentId"].intValue
                        self.addDeviceManagementModule.organizatinoOneList.append(organizationOneList)
                    }else{//二级单位
                        var organizationTwoList = OrganizationTwoList()
                        organizationTwoList.description = item["description"].stringValue
                        organizationTwoList.organizationNo = item["organizationNo"].stringValue
                        organizationTwoList.parentName = item["parentName"].stringValue
                        organizationTwoList.phone = item["phone"].stringValue
                        organizationTwoList.unitCategory = item["unitCategory"].stringValue
                        organizationTwoList.locationY = item["locationY"].stringValue
                        organizationTwoList.unitType = item["unitType"].stringValue
                        organizationTwoList.unitState = item["unitState"].stringValue
                        organizationTwoList.cimCode = item["cimCode"].stringValue
                        organizationTwoList.email = item["email"].stringValue
                        organizationTwoList.capacityName = item["capacityName"].stringValue
                        organizationTwoList.createTime = item["createTime"].stringValue
                        organizationTwoList.needAttr = item["needAttr"].stringValue
                        organizationTwoList.organizationName = item["organizationName"].stringValue
                        organizationTwoList.contacts = item["contacts"].stringValue
                        organizationTwoList.capacityId = item["capacityId"].intValue
                        organizationTwoList.organizationId = item["organizationId"].intValue
                        organizationTwoList.locationX = item["locationX"].stringValue
                        organizationTwoList.parentId = item["parentId"].intValue
                        self.addDeviceManagementModule.organizationTwoList.append(organizationTwoList)
                    }
                }
                //设备大类
                for item in result["equCategoryBig"].arrayValue{
                    var equCategoryBig = EquCategoryBig()
                    equCategoryBig.displayNo = item["displayNo"].intValue
                    equCategoryBig.categoryId = item["categoryId"].intValue
                    equCategoryBig.categoryName = item["categoryName"].stringValue
                    equCategoryBig.pCategoryId = item["pCategoryId"].intValue
                    self.addDeviceManagementModule.equCategoryBig.append(equCategoryBig)
                }
                //设备小类
                for item in result["equCategorySmall"].arrayValue{
                    var equCategorySmall = EquCategorySmall()
                    equCategorySmall.cimCode = item["cimCode"].stringValue
                    equCategorySmall.bigType = item["bigType"].intValue
                    equCategorySmall.id = item["id"].intValue
                    equCategorySmall.classType = item["classType"].stringValue
                    equCategorySmall.cimName = item["cimName"].stringValue
                    equCategorySmall.cimNameEn = item["cimNameEn"].stringValue
                    self.addDeviceManagementModule.equCategorySmall.append(equCategorySmall)
                }
            }else if result["status"].stringValue == "sign_app_err"{
                print("token失效")
            }else{
                
            }
            finished(result)
        }) { (error) in
            print("--------------------------------")
            print(error)
            finishedError(error)
        }
    }
}
