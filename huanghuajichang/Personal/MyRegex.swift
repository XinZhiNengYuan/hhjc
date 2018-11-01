//
//  MyRegex.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//


import Foundation
class MyRegex{
    enum ValidatedType {
        
        case Email
        
        case PhoneNumber
        
    }
    
    //类内部的方法，外部调用需要实例
    func ValidateText(validatedType type: ValidatedType, validateString: String) -> Bool {
        
        do {
            
            let pattern: String
            
            if type == ValidatedType.Email {
                pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            } else {
                pattern = "^1[0-9]{10}$"
            }
            
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let matches = regex.matches(in: validateString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (validateString as NSString).length))
            
            return matches.count > 0
            
        }
        catch {
            
            return false
            
        }
        
    }
    
    //当调用静态方法时，需要使用类型而不是实例。这里使用类型调用了自定义的静态方法。静态方法使用方便，所以项目中的工具类，往往包含大量的静态方法。
    //利用class func定义的方法，可以被重写；
    //而static func写的方法不可被重写，class final func写的方法不可被重写
    
    ///邮箱验证
    class func EmailIsValidated(vStr: String) -> Bool {
        let commentTool = MyRegex()
        return commentTool.ValidateText(validatedType: ValidatedType.Email, validateString: vStr)
        
        
    }
    
    ///手机号码验证
    class func PhoneNumberIsValidated(vStr: String) -> Bool {
        let commentTool = MyRegex()
        return commentTool.ValidateText(validatedType: ValidatedType.PhoneNumber, validateString: vStr)
        
    }
}
