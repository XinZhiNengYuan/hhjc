//
//  PersonTableViewCellModel.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/6.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class PersonTableViewCellModel: NSObject {
    var itemUrlId:String
    var itemImage:String
    var itemTitle:String
    var itemRightIcon:String
    var itemRightTitle:String
    init(itemId:String,itemImage:String, itemTitle:String,itemRightIcon:String,itemRightTitle:String) {
        self.itemUrlId = itemId
        self.itemImage = itemImage
        self.itemTitle = itemTitle
        self.itemRightIcon = itemRightIcon
        self.itemRightTitle = itemRightTitle
    }
}
