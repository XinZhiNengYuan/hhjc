//
//  PortViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/9.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PortViewController: UIViewController,UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatAlertView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    //MARK:构建自定义弹框样式
    func creatAlertView(){
        
        let contentView  = UIView()
        let Screen_w = UIScreen.main.bounds.size.width
        let Screen_h = UIScreen.main.bounds.size.height
        
        contentView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        contentView.frame.origin.x = Screen_w/2
        contentView.frame.origin.y = Screen_h/2
        contentView.bounds = CGRect(x: 0, y: 0, width: Screen_w, height: Screen_h)
        
        
        let mView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_w-80, height: 120))
        mView.center.x = Screen_w/2
        mView.center.y = Screen_h/2
        mView.layer.cornerRadius = 10
        mView.layer.backgroundColor = UIColor.white.cgColor
        
        let portName = UILabel(frame: CGRect(x: 20, y: 20, width: 50, height: 40))
        let portText = UITextField(frame: CGRect(x: 90, y: 20, width: Screen_w - 100, height: 40))
        portName.text = "端口:"
        portName.font = UIFont.boldSystemFont(ofSize: 18)
        mView.addSubview(portName)
        
        portText.adjustsFontSizeToFitWidth = true
        portText.minimumFontSize = 11
        portText.placeholder = "127.0.0.1:8080"
        portText.contentVerticalAlignment = .center
        portText.contentHorizontalAlignment = .left
        portText.clearButtonMode = .whileEditing
        portText.keyboardType = .default
        portText.returnKeyType = .done
        mView.addSubview(portText)
        
        let ok = UIButton(frame: CGRect(x: mView.frame.width/2, y: 0, width: mView.frame.width/2, height: 40))
        let cancel = UIButton(frame: CGRect(x: 0, y: 0, width: mView.frame.width/2, height: 40))
        let buttonItemView = UIView(frame: CGRect(x: 0, y: 80, width: mView.frame.width, height: 41))
        buttonItemView.backgroundColor = UIColor.gray
        mView.addSubview(buttonItemView)
        
        ok.setTitle("确认", for: UIControlState.normal)
        ok.setTitleColor(UIColor.black, for: UIControlState.normal)
        ok.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        ok.setTitle("确认", for: UIControlState.highlighted)
        ok.backgroundColor = UIColor.white
        ok.addTarget(self, action: #selector(touchOk(_:)), for: UIControlEvents.touchUpInside)
        
        cancel.setTitle("取消", for: UIControlState.normal)
        cancel.setTitleColor(UIColor.black, for: UIControlState.normal)
        cancel.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        cancel.setTitle("取消", for: UIControlState.highlighted)
        cancel.backgroundColor = UIColor.white
        cancel.addTarget(self, action: #selector(touchCancel(_:)), for: UIControlEvents.touchUpInside)
        
        mView.addSubview(ok)
        mView.addSubview(cancel)
        
        contentView.addSubview(mView)
         view.addSubview(contentView)
    }
    @objc fileprivate func touchOk(_ button:UIButton){
        print("记住端口号")
        clearAll()
    }

    @objc fileprivate func touchCancel(_ button:UIButton){
        print("不用记住端口号")
        clearAll()
    }
    
    func clearAll(){
//        print(self.subviews.count)
//        if self.subviews.count > 0 {
//            self.subviews.forEach({ $0.removeFromSuperview()});
//            // xcode7会提示 Result of call to map is unused
//            //self.subviews.map { $0.removeFromSuperview()};
//        }
    }
}
