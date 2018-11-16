//
//  DeviceManagementModel.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/2.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
//MARK:一二级菜单列表
struct DeviceManagementModule {
    var parent : Bool = false
    var isData : String = ""
    var typ : String = ""
    var objCode : String = ""
    var equipmentCount : Int = -1
    var children : [ChildrenList] = []
    var id : String = ""
    var text : String = ""
    var open : Bool = false
    var stationId : String = ""
    var pid : String = ""
}

struct ChildrenList {
    var parent : Bool = false
    var isData : String = ""
    var typ : String = ""
    var objCode : String = ""
    var equipmentCount : Int = -1
    var id : String = ""
    var open : Bool = false
    var text : String = ""
    var stationId : String = ""
    var pid : String = ""
}

//MARK:设备列表
struct DeviceManagementContentListModule {
    var specification : String = ""
    var categoryNameSmall : String = ""
    var coTwo : String = ""
    var equId : Int = -1
    var dataStatus : String = ""
    var departmentIdTwo : Int = -1
    var filesId :String = ""
    var spName : String = ""
    var coOne : String = ""
    var departmentIdOne : Int = -1
    var equCategoryBig : Int = -1
    var categoryNameBig : String = ""
    var equNo : String = ""
    var coType : String = ""
    var power : Int = -1
    var equCategorySmall : String = ""
    var equName : String = ""
    var status : String = ""
    var coOneAndcoTwo : String{
        get{
            return "\(coOne)-\(coTwo)"
        }
    }
}

struct DeviceManagementContentListDiyModule {
    var equCategorySmall : String = ""
    var deviceManagementContentList : [DeviceManagementContentListModule] = []
}
