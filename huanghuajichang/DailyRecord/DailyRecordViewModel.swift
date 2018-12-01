//
//  DailyRecordViewModel.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DailyRecordViewModel: NSObject {
    ///描述
    var describe:String
    ///图片数组ID
    var filesId:String
    ///该项纪录的ID
    var id:Int
    ///创建时间
    var opeTime:Int
    ///处理人ID
    var staId:Int
    ///处理人名字
    var staName:String
    ///处理时间
    var staTime:Int
    ///状态标志
    var state:Int
    ///标题
    var title:String
    ///创建人ID
    var userId:Int
    ///创建人名字
    var userName:String
    init(describe:String,filesId:String,id:Int,opeTime:Int,staId:Int,staName:String,staTime:Int,state:Int,title:String,userId:Int,userName:String){
            self.describe = describe
            self.filesId = filesId
            self.id = id
            self.opeTime = opeTime
            self.staId = staId
            self.staName = staName
            self.staTime = staTime
            self.state = state
            self.title = title
            self.userId = userId
            self.userName = userName
    }
}
