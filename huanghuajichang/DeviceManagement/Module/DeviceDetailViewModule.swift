//
//  DeviceDetailViewModule.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/8.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation

struct DeviceDetailViewModule {
    
    var equName : String = "" //设备名称
    var specification : String = "" //规格型号
    var power : Int = 0 //功率
    var manufactureDate : Double = 0 //生产日期
    var installDate : Double = 0 //安装日期
    var spName : String  = "" //供应商
    var equNo : String = "" //编号
    var kksCode : String = "" //标识
    var resultData : String = "" //数据
    var photoList : [equPhotos] = [] //图片数组
    var categoryNameSmall : String = "" //所属类型
    var coOne : String = "" //一级单位
    var coTwo : String = "" //二级单位
    var buildingName : String = ""//楼
    var floorName : String = "" //层
    var roomName : String = "" //房间
    var coOneAndcoTwo : String{
        get{
            return coOne + coTwo
        }
    }
    var buildInfo : String {
        get{
            return buildingName + floorName + roomName
        }
    }
   
        init() {}
    init(equName:String,specification:String,power:Int,manufactureDate:Double,installDate:Double,spName:String,equNo:String,kksCode:String,resultData:String) {
        self.equName = equName
        self.specification = specification
        self.power = power
        self.manufactureDate = manufactureDate
        self.installDate = installDate
        self.spName = spName
        self.equNo =  equNo
        self.kksCode = kksCode
        self.resultData = resultData
    }
}

struct equPhotos  {
    var fileId : Int = 0 //图片id
    var filePath : String = "" //图片路径
}
