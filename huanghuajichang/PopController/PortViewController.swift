//
//  PortViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/9.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PortViewController: UIViewController,UITextFieldDelegate {
    
    var userDefault = UserDefaults.standard
    var portText : UITextField!
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
        
        contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        contentView.frame.origin.x = Screen_w/2
        contentView.frame.origin.y = Screen_h/2
        contentView.bounds = CGRect(x: 0, y: 0, width: Screen_w, height: Screen_h)
        
        
        let mView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_w-80, height: 180))
        mView.center.x = Screen_w/2
        mView.center.y = Screen_h/2
        mView.layer.cornerRadius = 10
        mView.layer.backgroundColor = UIColor.white.cgColor
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: mView.frame.width-40, height: 40))
        titleLabel.text = "端口设置"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        mView.addSubview(titleLabel)
        
        let portName = UILabel(frame: CGRect(x: 20, y: 70, width: 50, height: 40))
        portText = UITextField(frame: CGRect(x: 90, y: 70, width: Screen_w - 200, height: 40))
        portName.text = "端口:"
        portName.font = UIFont.boldSystemFont(ofSize: 18)
        portText.text = userDefault.string(forKey: "AppUrlAndPort") ?? ""
        mView.addSubview(portName)
        
        portText.adjustsFontSizeToFitWidth = true
        portText.minimumFontSize = 11
        portText.placeholder = "127.0.0.1:8080"
        portText.contentVerticalAlignment = .center
        portText.contentHorizontalAlignment = .left
        portText.clearButtonMode = .whileEditing
        portText.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
        portText.layer.borderWidth = 1
        portText.layer.cornerRadius = 20
        portText.keyboardType = .default
        portText.returnKeyType = .done
        mView.addSubview(portText)
        
        let ok = UIButton(frame: CGRect(x: mView.frame.width/2+0.5, y: 1, width: mView.frame.width/2, height: 40))
        let cancel = UIButton(frame: CGRect(x: 0, y: 1, width: mView.frame.width/2-0.5, height: 40))
        let buttonItemView = UIView(frame: CGRect(x: 0, y: 132, width: mView.frame.width, height: 41))
        buttonItemView.backgroundColor = UIColor.gray
        
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
        cancel.addTarget(self, action: #selector(touchCancel(_:)), for: UIControlEvents.touchUpInside)
        cancel.backgroundColor = UIColor.white
        buttonItemView.addSubview(ok)
        buttonItemView.addSubview(cancel)
        mView.addSubview(buttonItemView)
        contentView.addSubview(mView)
         view.addSubview(contentView)
    }
    @objc fileprivate func touchOk(_ button:UIButton){
        print("记住端口号")
        if portText.text != nil{
            userDefault.set(portText.text, forKey: "AppUrlAndPort")
            self.dismiss(animated: false, completion: nil)
        }
        
    }

    @objc fileprivate func touchCancel(_ button:UIButton){
        print("不用记住端口号")
        self.dismiss(animated: true, completion: nil)
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
