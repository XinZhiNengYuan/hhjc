//
//  HandleDate.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/12.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class HandleDate: NSObject {
    
    //指定年月的开始日期
    func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
    
    //指定年月的结束日期
    func endOfMonth(year: Int, month: Int, returnEndTime:Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month:month))!
        return endOfYear
    }
    
    ///获取选中月的第一天或者最后一天
    /// - Parameter changeDate: 选中年月的字符串
    /// - Parameter startOrEnd: 日期类型：0为第一天，1为最后一天
    func getNeedDate(changeDate:String, startOrEnd:Int) -> String {
        
        let needDate:String
        let getYear = ((changeDate.split(separator: "-")[0]) as NSString).integerValue
        let getMonth = ((changeDate.split(separator: "-")[1]) as NSString).integerValue
        
        //创建一个日期格式器
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        switch startOrEnd {
        case 0:
            let startDate = startOfMonth(year: getYear, month: getMonth)
            needDate = dateFormatter.string(from: startDate)
        default:
            let endDate = endOfMonth(year: getYear, month: getMonth, returnEndTime: true)
            needDate = dateFormatter.string(from: endDate)
        }
        return needDate
    }
    
    ///比较新日期与当前日期
    func compareWithCurrent(newDate:String)->Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        var date1=NSDate()
        date1 = formatter.date(from: newDate)! as NSDate
        
        let currentMonth = NSDate()
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy/MM"
        let date2 = dateFormater.string(from: currentMonth as Date)
        
        let currentDate = formatter.date(from: date2)! as NSDate
        
        let result:ComparisonResult = date1.compare(currentDate as Date)
        
        var resultBool:Bool
        if result == ComparisonResult.orderedAscending{
            resultBool = true
        }else if result == ComparisonResult.orderedSame {
            resultBool = false
        }else{
            resultBool = false
        }
        return resultBool
    }
    
    func changeDate(changeDate:String, chageType:Int)->String{
        var year = ((changeDate.split(separator: "-")[0]) as NSString).integerValue
        var month = ((changeDate.split(separator: "-")[1]) as NSString).integerValue
        switch chageType {
        case 1://减
            if month == 01 {
                year = year - 1
                month = 12
            }else{
                month = month - 1
            }
            
        default://增
            if month == 12 {
                year = year + 1
                month = 01
            }else{
                month = month + 1
            }
        }
        let newDate = "\(year)" + "-" + formateNum(num: month)
        
        return newDate
    }
    
    func formateNum(num:Int) ->String{
        var formateString:String = ""
        if num < 10 {
            formateString = "0\(num)"
        }else{
            formateString = "\(num)"
        }
        return formateString
    }
}
