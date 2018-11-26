//
//  ChartDataValueFormatter.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/11/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Charts
///直接对值进行格式化
class ChartDataValueFormatter: NSObject,IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        //value为百分比值；entry.y是该项实际值
        return NSString.init(format: "%.1f%%", value) as String
    }
}
