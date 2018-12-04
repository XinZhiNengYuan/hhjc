//
//  AlarmAnalysisViewService.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/2.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
class AlarmAnalysisViewService : common{
    //数据请求地址
    let appUrl = UserDefaults.standard.string(forKey: "AppUrl")
    
    func getData(contentData : Dictionary<String,Any>,successCall:@escaping (_ successData : AlarmAnalysisViewModule)->()){
        super.requestData(urlStr: appUrl!, outTime: 10, contentData: contentData, finished: { (result) in
            if result["status"] == "success"{
                var alarmAnalysisViewModule = AlarmAnalysisViewModule()
                //添加年的数据
                for yearItem in result["data"]["yearData"].arrayValue{
                    var yearData = YearData()
                    yearData.lineData = yearItem["lineData"].stringValue
                    yearData.lineName = self.getStringNum(num: yearItem["lineName"].stringValue)
                    alarmAnalysisViewModule.yearData.append(yearData)
                }
                //添加月的数据
                for monthItem in result["data"]["monthData"].arrayValue{
                    var monthData = MonthData()
                    monthData.lineData = monthItem["lineData"].stringValue
                    monthData.lineName = self.getStringNum(num: monthItem["lineName"].stringValue)
                    alarmAnalysisViewModule.monthData.append(monthData)
                }
                //添加日的数据
                for dayItem in result["data"]["dayData"].arrayValue{
                    var dayData = DayData()
                    dayData.lineData = dayItem["lineData"].stringValue
                    dayData.lineName = self.getStringNum(num: dayItem["lineName"].stringValue)
                    alarmAnalysisViewModule.dayData.append(dayData)
                }
                successCall(alarmAnalysisViewModule)
            }else{
                print("网络错误提示:\(result["status"])")
            }
        }) { (error) in
            print(error)
        }
    }
    func getStringNum(num:String)->String{
        let tempNum = Int(num)
        if tempNum! < 10{
            return "0\(num)"
        }else{
            return num
        }
    }
}
