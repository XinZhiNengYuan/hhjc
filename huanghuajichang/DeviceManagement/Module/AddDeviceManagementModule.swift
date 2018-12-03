//
//  AddDeviceManagementModule.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/29.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation

struct AddDeviceManagementModule {
    var organizatinoOneList : [OrganizationOneList] = []
    var organizationTwoList : [OrganizationTwoList] = []
    var equCategoryBig : [EquCategoryBig] = []
    var equCategorySmall : [EquCategorySmall] = []
    var building : [Building] = []
    var floor : [Floor] = []
    var room : [Room] = []
}
//一级单位
struct OrganizationOneList {
    var description = ""
    var organizationNo = ""
    var parentName = ""
    var phone = ""
    var unitCategory = ""
    var locationY = ""
    var unitType = ""
    var unitState = ""
    var cimCode = ""
    var email = ""
    var capacityName = ""
    var createTime = ""
    var needAttr = ""
    var organizationName = ""
    var contacts = ""
    var capacityId = -1
    var organizationId = -1
    var locationX = ""
    var parentId = -1
}
//二级单位
struct OrganizationTwoList {
    var description = ""
    var organizationNo = ""
    var parentName = ""
    var phone = ""
    var unitCategory = ""
    var locationY = ""
    var unitType = ""
    var unitState = ""
    var cimCode = ""
    var email = ""
    var capacityName = ""
    var createTime = ""
    var needAttr = ""
    var organizationName = ""
    var contacts = ""
    var capacityId = -1
    var organizationId = -1
    var locationX = ""
    var parentId = -1
}
//设备大类
struct EquCategoryBig{
    var displayNo = -1
    var categoryId = -1
    var categoryName = ""
    var pCategoryId = -1
}
//设备小类
struct EquCategorySmall{
    var cimCode = ""
    var bigType = -1
    var id = -1
    var classType = ""
    var cimName = ""
    var cimNameEn = ""
}
//楼
struct Building{
    var buildName = ""
    var id = -1
    var img = ""
    var landlord = ""
    var buildLat = -1
    var buildLng = -1
    var position = ""
}
//层
struct Floor{
    var buildId = -1
    var floorName = ""
    var id = -1
}
//房间
struct Room{
    var roomNum = ""
    var id = -1
    var notes = ""
    var contactor = ""
    var roomName = ""
    var floorId = -1
}
