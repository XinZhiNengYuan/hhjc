//
//  AlarmAnalysisModule.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/19.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation

struct AlarmAnalysisViewModule {
    var yearData : [YearData] = []
    var monthData : [MonthData] = []
    var dayData : [DayData] = []
    
}

struct YearData {
    var lineData : String = ""
    var lineName : String = ""
}

struct MonthData {
    var lineData : String = ""
    var lineName : String = ""
}

struct DayData {
    var lineData : String = ""
    var lineName : String = ""
}
