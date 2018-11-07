//
//  common.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/19.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

let KNavBarHeight : CGFloat = 44.0
let KStatusBarHeight : CGFloat = UIApplication.shared.statusBarFrame.size.height
let KUIScreenHeight : CGFloat = UIScreen.main.bounds.size.height
let KUIScreenWidth : CGFloat = UIScreen.main.bounds.size.width
let KNavStausHeight : CGFloat = KNavBarHeight + KStatusBarHeight

//tableView,collectionView,scrollView的frame
let KUIDefaultFrame : CGRect = CGRect(x: 0, y: KNavStausHeight, width: KUIScreenWidth, height: KUIScreenHeight - KNavStausHeight)

//判断机型
let isIphone4 : Bool = (UIScreen.main.bounds.height == 480) //4/4s
let isIphone5 : Bool = (UIScreen.main.bounds.height == 568) //5/5s
let isIphone6 : Bool = (UIScreen.main.bounds.height == 667) //6/6s/7/7s/8
let isIphone6P : Bool = (UIScreen.main.bounds.height == 736) //6p/6sp/7p/7sp/8p
let isIphoneX : Bool = (UIScreen.main.bounds.height == 812) //X

/**
 字典转换为JSONString
 
 - parameter dictionary: 字典参数
 
 - returns: JSONString
 */
func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
    if (!JSONSerialization.isValidJSONObject(dictionary)) {
        print("无法解析出JSONString")
        return ""
    }
    let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
    let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
    return JSONString! as String
    
}

/// JSONString转换为字典
///
/// - Parameter jsonString: <#jsonString description#>
/// - Returns: <#return value description#>
func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
    
    let jsonData:Data = jsonString.data(using: .utf8)!
    
    let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
    if dict != nil {
        return dict as! NSDictionary
    }
    return NSDictionary()
    
    
}




class common : NSObject{
    /*
     urlStr: 请求地址
     outTime: 请求超时事件
     info : 请求参数
     finished : 请求成功的回调
     finishedError : 请求不成功的回调
     */
    func requestData(urlStr : String,outTime : Double ,contentData : Dictionary<String, Any>,finished:@escaping (_ resultData : JSON)->(),finishedError: @escaping (_ resultDataError: Error)->()){
        MyProgressHUD.showStatusInfo("加载中...")
        //网络请求
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = outTime
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        sessionManager.request(urlStr, method: .post, parameters: contentData, encoding: JSONEncoding.default, headers: headers).responseJSON { (resultData) in
            
            switch resultData.result {
            case .success(let value):
                let json = JSON(value)
                MyProgressHUD.dismiss()
                finished(json)
            case .failure(let error):
                MyProgressHUD.dismiss()
                finishedError(error)
                return
                
            }
            
            }.session.finishTasksAndInvalidate()
        
    }
    
    //MARK:alert弹框
    func windowAlert(msges : String,callback:(_ alertView : UIAlertController)->()){
        let alertView = UIAlertController(title: "提示", message: msges, preferredStyle: UIAlertControllerStyle.alert)
        let yes = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
        alertView.addAction(yes)
        callback(alertView)
//        self.present(alertView,animated:true,completion:nil)
    }
    
}

//MARK:将unicode编码转为汉字
extension String {
    var unicodeStr:String {
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        var returnStr:String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            print(error)
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
}
