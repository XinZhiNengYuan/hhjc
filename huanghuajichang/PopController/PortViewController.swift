//
//  PortViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/9.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PortViewController: UIView,UITextFieldDelegate {
    
    var userDefault = UserDefaults.standard
    var portText : UITextField!
    var ipText : UITextField!
    let ok = UIButton()
    let cancel = UIButton()
    
    override func layoutSubviews() {
//        creatAlertView()
    }
    //MARK:构建自定义弹框样式
    func creatAlertView() -> UIView{
        
        let contentView  = UIView()
        let Screen_w = UIScreen.main.bounds.size.width
        let Screen_h = UIScreen.main.bounds.size.height
        let ipAndPort = userDefault.string(forKey: "AppUrlAndPort")
        let ipIndex = ipAndPort?.index((ipAndPort?.endIndex)!, offsetBy: -5)
        let ipData = ipAndPort?.prefix(upTo: ipIndex!)
        let portIndex = ipAndPort?.index((ipAndPort?.endIndex)!, offsetBy: -4)
        let portData = ipAndPort?.suffix(from: portIndex!)
        contentView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        contentView.frame.origin.x = Screen_w/2
        contentView.frame.origin.y = Screen_h/2
        contentView.bounds = CGRect(x: 0, y: 0, width: Screen_w, height: Screen_h)
        
        
        let mView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_w-80, height: 228))
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
        let portViewForPortText = UIView(frame: CGRect(x: 90, y: 70, width: Screen_w - 200, height: 40))
        ipText = UITextField(frame: CGRect(x: 20, y: 0, width: portViewForPortText.frame.width-20, height: 40))
        portName.text = "IP:"
        portName.font = UIFont.boldSystemFont(ofSize: 15)
        ipText.text = String(ipData!)
        ipText.delegate = self
        mView.addSubview(portName)
        
        let port = UILabel(frame: CGRect(x: 20, y: 120, width: 50, height: 40))
        let rPortText = UIView(frame: CGRect(x: 90, y: 120, width: Screen_w - 200, height: 40))
        portText = UITextField(frame: CGRect(x: 20, y: 0, width: rPortText.frame.width-20, height: 40))
        port.text = "端口:"
        port.font = UIFont.boldSystemFont(ofSize: 15)
        portText.text = String(portData!)
        mView.addSubview(port)
        portText.delegate = self
        
        ipText.adjustsFontSizeToFitWidth = true
        ipText.minimumFontSize = 11
        ipText.placeholder = "127.0.0.1"
        ipText.contentVerticalAlignment = .center
        ipText.contentHorizontalAlignment = .left
        ipText.clearButtonMode = .whileEditing
        portText.adjustsFontSizeToFitWidth = true
        portText.minimumFontSize = 11
        portText.placeholder = "8080"
        portText.contentVerticalAlignment = .center
        portText.contentHorizontalAlignment = .left
        portText.clearButtonMode = .whileEditing
        portViewForPortText.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
        portViewForPortText.layer.borderWidth = 1
        portViewForPortText.layer.cornerRadius = 20
        rPortText.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
        rPortText.layer.borderWidth = 1
        rPortText.layer.cornerRadius = 20
        ipText.keyboardType = .decimalPad
        ipText.returnKeyType = .done
        portViewForPortText.addSubview(ipText)
        rPortText.addSubview(portText)
        mView.addSubview(rPortText)
        mView.addSubview(portViewForPortText)
        
        
        let buttonItemView = UIView(frame: CGRect(x: 0, y: 180, width: mView.frame.width, height: 41))
        buttonItemView.backgroundColor = UIColor.gray
        ok.frame = CGRect(x: mView.frame.width/2+0.5, y: 1, width: mView.frame.width/2, height: 40)
        ok.setTitle("确认", for: UIControlState.normal)
        ok.setTitleColor(UIColor.black, for: UIControlState.normal)
        ok.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        ok.setTitle("确认", for: UIControlState.highlighted)
        ok.backgroundColor = UIColor.white
        
        cancel.frame = CGRect(x: 0, y: 1, width: mView.frame.width/2-0.5, height: 40)
        cancel.setTitle("取消", for: UIControlState.normal)
        cancel.setTitleColor(UIColor.black, for: UIControlState.normal)
        cancel.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        cancel.setTitle("取消", for: UIControlState.highlighted)
        cancel.backgroundColor = UIColor.white
        buttonItemView.addSubview(ok)
        buttonItemView.addSubview(cancel)
        mView.addSubview(buttonItemView)
        contentView.addSubview(mView)
         return contentView
    }
    
    func clearAll(){
//        print(self.subviews.count)
//        if self.subviews.count > 0 {
//            self.subviews.forEach({ $0.removeFromSuperview()});
//            // xcode7会提示 Result of call to map is unused
//            //self.subviews.map { $0.removeFromSuperview()};
//        }
    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            //收起键盘
//            textField.resignFirstResponder()
//            
//        return true;
//    }
}
