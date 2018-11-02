//
//  DeviceManagementModel.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/2.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation

class DeviceManagementModule : NSObject{
    private var id : String!
    private var text : String!
    private var open : String!
    private var stationId : String!
    private var pid : String!
    
//    func init(id:String,text:String,open:String,stationId:String,pid:String) -> Dictionary<String,String>{
//        return ["id":id,"text":text,"open":open,"stationId":stationId,"pid":pid]
    //    }
//    override init(){
//        super.init()
//    }
    init(id:String,text:String,open:String,stationId:String,pid:String) {
        
        self.id = id
        self.text = text
        self.open = open
        self.stationId = stationId
        self.pid = pid
        super.init()
    }
}
