//
//  PublicParamter.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/1.
//  Copyright © 2018年 jun. All rights reserved.
//

//#全局变量
import UIKit
///页面高度
let kScreenHeight = UIScreen.main.bounds.size.height
///页面宽度
let kScreenWidth = UIScreen.main.bounds.size.width
///statusBar的高度
let statusBarHeight = UIApplication.shared.statusBarFrame.height;
///导航栏高度
let navigationHeight = (statusBarHeight + 44)
///tabbar高度
let tabBarHeight = CGFloat(statusBarHeight == 44 ? 83 : 49)
///顶部的安全距离
let topSafeAreaHeight = (statusBarHeight - 20)
///底部的安全距离
let bottomSafeAreaHeight = (tabBarHeight - 49)

//另外一种方式动态获取高度
////底部的安全距离
//let bottomSafeAreaHeight =  UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
////顶部的安全距离
//let topSafeAreaHeight = (bottomSafeAreaHeight == 0 ? 0 : 24)
////导航栏高度
//let navigationHeight = (bottomSafeAreaHeight == 0 ? 64 : 88)
////tabbar高度
//let tabBarHeight = (bottomSafeAreaHeight + 49)

///navigationbar的高度
let KMaskHeight = 64
///蓝色字体颜色
let topValueColor:UIColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
///普遍字体颜色
let allFontColor:UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
///单位字体颜色
let allUnitColor:UIColor = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
///列表背景色
let allListBackColor:UIColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)

//MARK:alert弹框
func windowAlert(msges : String)->UIAlertController{
    let alertView = UIAlertController(title: "提示", message: msges, preferredStyle: UIAlertControllerStyle.alert)
    let yes = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
    alertView.addAction(yes)
    return alertView
//    self.present(alertView,animated:true,completion:nil)
}

/// - parameter pageName:    The session manager the request was executed on.
/// - parameter msg:    The message will show in view.
/// - parameter completion: The completion closure to be executed when retry decision has been determined.
func windowTotast(pageName:UIViewController, msg:String, completion: (() -> Void)? = nil){
    //利用GCD和UILabel实现,代码如下
    //在label下面添加遮盖层
    //设置修改成功提示
    let zgc = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
    zgc.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
    pageName.view.addSubview(zgc)
    let label = UILabel.init(frame: CGRect(x: (kScreenWidth-100)/2, y: (kScreenHeight-navigationHeight-80)/2, width: 100, height: 80))
    label.text = msg
    label.font = UIFont.systemFont(ofSize: 15)
    label.backgroundColor = UIColor.gray
    label.textAlignment = .center
    label.layer.cornerRadius = 4
    label.layer.masksToBounds = true
    zgc.addSubview(label)
    DispatchQueue.global().async {
        Thread.sleep(forTimeInterval: 2)//延时2秒执行
        //回到主线程
        DispatchQueue.main.async {
            zgc.removeFromSuperview()
            if completion != nil{
                completion!()
            }
        }
    }
    
}
extension UIView{
    func SetBorderWithView(_ view:UIView,top:Bool,left:Bool,bottom:Bool,right:Bool,width:CGFloat,color:UIColor)
        
    {
        
        if top
            
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: width)
            
            layer.backgroundColor = color.cgColor
            
            view.layer.addSublayer(layer)
            
        }
        
        if left
            
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.size.height)
            
            layer.backgroundColor = color.cgColor
            
            view.layer.addSublayer(layer)
            
        }
        
        if bottom
            
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: 0, y: view.frame.size.height - width, width: view.frame.size.width, height: width)
            
            layer.backgroundColor = color.cgColor
            
            view.layer.addSublayer(layer)
            
        }
        
        if right
            
        {
            
            let layer = CALayer()
            
            layer.frame = CGRect(x: view.frame.size.width - width, y: 0, width: width, height: view.frame.size.height)
            
            layer.backgroundColor = color.cgColor
            
            view.layer.addSublayer(layer)
            
        }
        
    }
}
