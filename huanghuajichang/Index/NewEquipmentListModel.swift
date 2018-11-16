//
//  NewEquipmentListModel.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/11/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class NewEquipmentListModel: NSObject {
    var equCategory:String
    var categoryName:String
    var childsNum:Int
    var childs:[[String:AnyObject]]
    init(equCategory:String,categoryName:String,childsNum:Int,childs:[[String:AnyObject]]){
        self.equCategory = equCategory
        self.categoryName = categoryName
        self.childsNum = childsNum
        self.childs = childs
    }
}
