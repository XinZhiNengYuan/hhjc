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

class DeviceManagementService : common{//token失效的字段:sign_app_err
    
    //MARK:获取一二级菜单
    var dataList : [DeviceManagementModule] = []
    func getData(contentData : Dictionary<String,Any>,finished:@escaping (_ dataList:Array<DeviceManagementModule>,_ meanList : Array<String>) -> (),finishedError:@escaping (_ errorData: Error) -> ()){
        super.requestData(urlStr: appUrl, outTime: 10, contentData: contentData, finished: { (result) in
            if result["status"].stringValue == "success"{
                var oneMeanList : [String] = []
                for item in result["data"].arrayValue{
                    var deviceManagementModule = DeviceManagementModule()
                    deviceManagementModule.parent = item["parent"].boolValue
                    deviceManagementModule.isData = item["isData"].stringValue
                    deviceManagementModule.typ = item["typ"].stringValue
                    deviceManagementModule.equipmentCount = item["equipmentCount"].intValue
                    deviceManagementModule.id = item["id"].stringValue
                    deviceManagementModule.text = item["text"].stringValue
                    oneMeanList.append(item["text"].stringValue)
                    deviceManagementModule.open = item["open"].boolValue
                    deviceManagementModule.stationId = item["stationId"].stringValue
                    deviceManagementModule.pid = item["pid"].stringValue
                    for childrenItem in item["children"].arrayValue{
                        var children = ChildrenList()
                        children.parent = childrenItem["parent"].boolValue
                        children.isData = childrenItem["isData"].stringValue
                        children.typ = childrenItem["typ"].stringValue
                        children.objCode = childrenItem["objCode"].stringValue
                        children.equipmentCount = childrenItem["equipmentCount"].intValue
                        children.id = childrenItem["id"].stringValue
                        children.open = childrenItem["open"].boolValue
                        children.text = childrenItem["text"].stringValue
                        children.stationId = childrenItem["stationId"].stringValue
                        children.pid = childrenItem["pid"].stringValue
                    deviceManagementModule.children.append(children)
                    }
                    self.dataList.append(deviceManagementModule)
                }
                finished(self.dataList,oneMeanList)
            }
            
        }) { (errorData) in
            finishedError(errorData)
        }
    }
    
    //MARK:获取设备列表
    func getDeviceListData(contentData : Dictionary<String,Any>,finished:@escaping (_ resultData:[DeviceManagementContentListDiyModule])->(),finishedError:@escaping(_ errorData : Error)->()){
        super.requestData(urlStr: appUrl, outTime: 60, contentData: contentData, finished: { (result) in
            if result["status"].stringValue == "success"{
                var contentListDiyData : [DeviceManagementContentListDiyModule] = []
                for item in result["data"]["resultData"].arrayValue{
                    if contentListDiyData.count > 0{
                        var equCategorySmallList : [String] = []
                        for i in 0..<contentListDiyData.count{
                            equCategorySmallList.append(contentListDiyData[i].equCategorySmall)
                            //在已经存在的数据对象当中检查是不是有equCategorySmall存在，如果存在的话检查是不是有equCategorySmall相同的，如果有相同的就直接给equCategorySmall追加新的对象，没有就创建一个新的对象
                            
                        }
                        if equCategorySmallList.contains(item["equCategorySmall"].stringValue){
                            for j in 0..<contentListDiyData.count{
                                if contentListDiyData[j].equCategorySmall == item["equCategorySmall"].stringValue{
                                    var deviceManagementContentListModule = DeviceManagementContentListModule()
                                    deviceManagementContentListModule.specification = item["specification"].stringValue
                                    deviceManagementContentListModule.categoryNameSmall = item["categoryNameSmall"].stringValue
                                    deviceManagementContentListModule.coTwo = item["coTwo"].stringValue
                                    deviceManagementContentListModule.equId = item["equId"].intValue
                                    deviceManagementContentListModule.dataStatus = item["dataStatus"].stringValue
                                    deviceManagementContentListModule.departmentIdTwo = item["departmentIdTwo"].intValue
                                    deviceManagementContentListModule.filesId = item["filesId"].stringValue
                                    deviceManagementContentListModule.spName = item["spName"].stringValue
                                    deviceManagementContentListModule.coOne = item["coOne"].stringValue
                                    deviceManagementContentListModule.departmentIdOne = item["departmentIdOne"].intValue
                                    deviceManagementContentListModule.equCategoryBig = item["equCategoryBig"].intValue
                                    deviceManagementContentListModule.categoryNameBig = item["categoryNameBig"].stringValue
                                    deviceManagementContentListModule.equNo = item["equNo"].stringValue
                                    deviceManagementContentListModule.coType = item["coType"].stringValue
                                    deviceManagementContentListModule.power = item["power"].intValue
                                    deviceManagementContentListModule.equCategorySmall = item["equCategorySmall"].stringValue
                                    deviceManagementContentListModule.equName = item["equName"].stringValue
                                    deviceManagementContentListModule.status = item["status"].stringValue
                                    contentListDiyData[j].deviceManagementContentList.append(deviceManagementContentListModule)
                                }
                            }
                            
                        }else {
                            var deviceManagemengContentListDiyModule = DeviceManagementContentListDiyModule()
                            var deviceManagementContentListModule = DeviceManagementContentListModule()
                            deviceManagementContentListModule.specification = item["specification"].stringValue
                            deviceManagementContentListModule.categoryNameSmall = item["categoryNameSmall"].stringValue
                            deviceManagementContentListModule.coTwo = item["coTwo"].stringValue
                            deviceManagementContentListModule.equId = item["equId"].intValue
                            deviceManagementContentListModule.dataStatus = item["dataStatus"].stringValue
                            deviceManagementContentListModule.departmentIdTwo = item["departmentIdTwo"].intValue
                            deviceManagementContentListModule.filesId = item["filesId"].stringValue
                            deviceManagementContentListModule.spName = item["spName"].stringValue
                            deviceManagementContentListModule.coOne = item["coOne"].stringValue
                            deviceManagementContentListModule.departmentIdOne = item["departmentIdOne"].intValue
                            deviceManagementContentListModule.equCategoryBig = item["equCategoryBig"].intValue
                            deviceManagementContentListModule.categoryNameBig = item["categoryNameBig"].stringValue
                            deviceManagementContentListModule.equNo = item["equNo"].stringValue
                            deviceManagementContentListModule.coType = item["coType"].stringValue
                            deviceManagementContentListModule.power = item["power"].intValue
                            deviceManagementContentListModule.equCategorySmall = item["equCategorySmall"].stringValue
                            deviceManagementContentListModule.equName = item["equName"].stringValue
                            deviceManagementContentListModule.status = item["status"].stringValue
                            deviceManagemengContentListDiyModule.equCategorySmall = item["equCategorySmall"].stringValue
                            deviceManagemengContentListDiyModule.deviceManagementContentList.append(deviceManagementContentListModule)
                            contentListDiyData.append(deviceManagemengContentListDiyModule)
                        }
                    }else{
                        //第一次循环直接构造新的数据对象
                        var deviceManagemengContentListDiyModule = DeviceManagementContentListDiyModule()
                        var deviceManagementContentListModule = DeviceManagementContentListModule()
                        deviceManagementContentListModule.specification = item["specification"].stringValue
                        deviceManagementContentListModule.categoryNameSmall = item["categoryNameSmall"].stringValue
                        deviceManagementContentListModule.coTwo = item["coTwo"].stringValue
                        deviceManagementContentListModule.equId = item["equId"].intValue
                        deviceManagementContentListModule.dataStatus = item["dataStatus"].stringValue
                        deviceManagementContentListModule.departmentIdTwo = item["departmentIdTwo"].intValue
                        deviceManagementContentListModule.filesId = item["filesId"].stringValue
                        deviceManagementContentListModule.spName = item["spName"].stringValue
                        deviceManagementContentListModule.coOne = item["coOne"].stringValue
                        deviceManagementContentListModule.departmentIdOne = item["departmentIdOne"].intValue
                        deviceManagementContentListModule.equCategoryBig = item["equCategoryBig"].intValue
                        deviceManagementContentListModule.categoryNameBig = item["categoryNameBig"].stringValue
                        deviceManagementContentListModule.equNo = item["equNo"].stringValue
                        deviceManagementContentListModule.coType = item["coType"].stringValue
                        deviceManagementContentListModule.power = item["power"].intValue
                        deviceManagementContentListModule.equCategorySmall = item["equCategorySmall"].stringValue
                        deviceManagementContentListModule.equName = item["equName"].stringValue
                        deviceManagementContentListModule.status = item["status"].stringValue
                        deviceManagemengContentListDiyModule.equCategorySmall = item["equCategorySmall"].stringValue
                        deviceManagemengContentListDiyModule.deviceManagementContentList.append(deviceManagementContentListModule)
                        contentListDiyData.append(deviceManagemengContentListDiyModule)
                    }
                }
                finished(contentListDiyData)
            }
            
        }) { (error) in
            print(error)
            finishedError(error)
        }
    }
}
