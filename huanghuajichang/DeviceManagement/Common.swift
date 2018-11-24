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
//数据请求地址
let appUrl = UserDefaults.standard.string(forKey: "AppUrl") ?? "http://10.4.65.103:8086/interface"

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
    let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData
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
    func requestData(urlStr : String,outTime : Double , contentData : Dictionary<String, Any>,finished:@escaping (_ resultData : JSON)->(),finishedError: @escaping (_ resultDataError: Error)->()){
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
    
//    图片上传
    ///
    /// - Parameters:
    ///   - urlString: 服务器地址
    ///   - params: 参数 ["token": "89757", "userid": "nb74110"]
    ///   - images: image数组
    ///   - success: 成功闭包
    ///   - failture: 失败闭包
    func upload(params:[String:String]?, images: [UIImage], success: @escaping (_ response : JSON) -> (), failture : @escaping (_ error : Error)->()) {
        MyProgressHUD.showStatusInfo("上传中...")
        let userDefalutUrl = userDefault.string(forKey: "AppUrlAndPort")
        let urlStrPic = "http://\(userDefalutUrl ?? "10.4.65.103:8086")/app/uploadfile"
        Alamofire.upload(multipartFormData: { multipartFormData in
            if params != nil {
                for (key, value) in params! {
                    //参数的上传
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
            }
            for (index, value) in images.enumerated() {
                let imageData = UIImageJPEGRepresentation(value, 1.0)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let str = formatter.string(from: Date())
                let fileName = str+"\(index)"+".jpg"
                
                // 以文件流格式上传
                // 批量上传与单张上传，后台语言为java或.net等
                multipartFormData.append(imageData!, withName: "file", fileName: fileName, mimeType: "image/jpeg")
                // 单张上传，后台语言为PHP
//                multipartFormData.append(imageData!, withName: "fileupload", fileName: fileName, mimeType: "image/jpeg")
                // 批量上传，后台语言为PHP。 注意：此处服务器需要知道，前台传入的是一个图片数组
//                multipartFormData.append(imageData!, withName: "fileupload[\(index)]", fileName: fileName, mimeType: "image/jpeg")
            }
        },
                         to: urlStrPic,
                         headers: nil,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    let result = response.result
                                    if result.isSuccess {
                                        success(JSON(response.value as Any))
                                    }
                                    MyProgressHUD.dismiss()
                                }
                            case .failure(let encodingError):
                                MyProgressHUD.dismiss()
                                failture(encodingError)
                            }
        }
        )
    }
    
    
    //MARK:alert弹框
    func windowAlert(msges : String,callback:(_ alertView : UIAlertController)->()){
        let alertView = UIAlertController(title: "提示", message: msges, preferredStyle: UIAlertControllerStyle.alert)
        let yes = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
        alertView.addAction(yes)
        callback(alertView)
//        self.present(alertView,animated:true,completion:nil)
    }
    
    /// 动态计算Label宽度
    
    func getLabelWidth(str: String, font: UIFont, height: CGFloat)-> CGFloat {
        
        let statusLabelText: NSString = str as NSString
        
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
        
        return strSize.width
        
    }
    
    
    
    /// 动态计算Label高度
    
    func getLabelHegit(str: String, font: UIFont, width: CGFloat)-> CGFloat {
        
        let statusLabelText: NSString = str as NSString
        
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : AnyObject], context: nil).size
        
        return strSize.height
        
    }
    
}


extension String {
    //MARK:将unicode编码转为汉字
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
    //MARK:将时间戳转换成字符串
    static func timeStampToString(timeStamp:String)->String {
        let timeNormal = Int(timeStamp)!/1000
        let string = NSString(string: timeNormal.description)
        
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy/MM/dd HH:mm"
        
        let date = NSDate(timeIntervalSince1970: timeSta)
        
        //        print(dfmatter.string(from: date as Date))
        return dfmatter.string(from: date as Date)
    }
}
