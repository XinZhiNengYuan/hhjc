//
//  LoginViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoginViewController: UIViewController,UIScrollViewDelegate,UITextFieldDelegate {
    
    var scrollView : UIScrollView = UIScrollView()
    var textPassField : UITextField = UITextField()
    var textNameField : UITextField = UITextField()
    let contentView = UIView()
    let flagButton = UIButton()
    let eyes = UIButton()
    var flageStatus : Bool = false //是否记住密码
    var seePass : Bool = false //查看密码
    let commonClass = common()
    let popViewController = PortViewController()
    let appUpdate = AppUpdateAlertService()
    var popView : UIView!
    //本地存储
    var userDefault = UserDefaults.standard
    
    var netStatus:Bool = false
    let manager = NetworkReachabilityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textNameField.delegate = self
        textPassField.delegate = self
        scrollView.delegate = self
        flageStatus = self.userDefault.bool(forKey: "buttonStatus")
        setLayoutFrame()
        // Do any additional setup after loading the view.
    }
    
    //MARK:app更新接口
    func getUpdate(){
        let contentData = ["method":"version","info":""]
        appUpdate.getData(contentData: contentData, finished: { (resultData) in
            if resultData["status"].stringValue == "success"{
                let deviceInfo = self.DeviceInfo()
                let vision = deviceInfo.split(separator: ".")
                let tempVision = resultData["data"]["versionNum"].description.split(separator: ".")
                for index in 0..<vision.count{
                    if vision[index] < tempVision[index]{
                        //自定义弹框调用方式
                        //                            var topRootViewController = UIApplication.shared.keyWindow?.rootViewController
                        //                            while ((topRootViewController?.presentedViewController) != nil){
                        //                                topRootViewController = topRootViewController!.presentedViewController
                        //                            }
                        AppUpdateAlert.showUpdateAlert(version: "\(resultData["data"]["versionNum"])", description: "\(resultData["data"]["versionInformation"])",ipIos:"\(resultData["data"]["ipIos"])")
                    }
                }
                
            }else {
                print(resultData)
                self.windowAlert(msges: resultData["msg"].stringValue)
            }
        }) { (error) in
            self.windowAlert(msges: "网络请求失败")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        (self.userDefault.string(forKey: "AppUrlAndPort") != nil) ? self.userDefault.set(self.userDefault.string(forKey: "AppUrlAndPort"), forKey: "AppUrlAndPort") : self.userDefault.set("10.4.65.103:8086", forKey: "AppUrlAndPort")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        manager?.startListening()
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height
            let rect = CGRect(x: 0, y: -156, width: width, height: height)
            self.view.frame = rect
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        self.view.frame = rect
    }
    func setLayoutFrame(){
        
        contentView.backgroundColor = UIColor.white
        
        let logoView = UIImageView(image: UIImage(named: "登录bg"))
        logoView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240)
        let logoLabel = UILabel(frame: CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 20))
        logoLabel.text = "智慧能源管理系统"
        logoLabel.textColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        logoLabel.font = UIFont.boldSystemFont(ofSize: 17)
        logoLabel.textAlignment = .center
        contentView.addSubview(logoLabel)
        contentView.addSubview(logoView)
        
        let inputView = UIView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height*2/5+20, width: view.frame.width-40, height: 90))
        let inputNameView = UIView(frame: CGRect(x: 0, y: 0, width: inputView.frame.width, height: 40))
        
        textNameField.frame = CGRect(x: 30, y: 0, width: inputNameView.frame.width-30, height: inputNameView.frame.height)
        textNameField.adjustsFontSizeToFitWidth=true  //当文字超出文本框宽度时，自动调整文字大小
        textNameField.minimumFontSize=11  //最小可缩小的字号
        /** 水平对齐 **/
        textNameField.textAlignment = .left
        /** 垂直对齐 **/
        textNameField.contentVerticalAlignment = .center
        textNameField.clearButtonMode = .whileEditing  //编辑时出现清除按钮
        //textField.clearButtonMode = .unlessEditing  //编辑时不出现，编辑后才出现清除按钮
        //textNameField.clearButtonMode = .always  //一直显示清除按钮
        textNameField.keyboardType = UIKeyboardType.default
        //textNameField.becomeFirstResponder()
        textNameField.font = UIFont.boldSystemFont(ofSize: 15)
        textNameField.tag = 1
        textNameField.returnKeyType = UIReturnKeyType.next
        textNameField.placeholder = "请输入手机号/账号"
        textNameField.text = ""
        inputNameView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 0.8).cgColor
        inputNameView.layer.borderWidth = 1
        inputNameView.layer.cornerRadius = 20
        inputNameView.addSubview(textNameField)
        inputView.addSubview(inputNameView)
        
        
        let inputPassView = UIView(frame: CGRect(x: 0, y: 50, width: inputView.frame.width, height: 40))
        
        textPassField.frame = CGRect(x: 30, y: 0, width: inputPassView.frame.width-60, height: inputPassView.frame.height)
        textPassField.adjustsFontSizeToFitWidth=true  //当文字超出文本框宽度时，自动调整文字大小
        textPassField.minimumFontSize=11  //最小可缩小的字号
        /** 水平对齐 **/
        textPassField.textAlignment = .left
        /** 垂直对齐 **/
        textPassField.contentVerticalAlignment = .center
        textPassField.clearButtonMode = .whileEditing  //编辑时出现清除按钮
        //textField.clearButtonMode = .unlessEditing  //编辑时不出现，编辑后才出现清除按钮
        //textPassField.clearButtonMode = .always  //一直显示清除按钮
        textPassField.isSecureTextEntry = true //输入内容会显示成小黑点
        textPassField.keyboardType = UIKeyboardType.default
        textPassField.returnKeyType = UIReturnKeyType.done //表示完成输入
        textPassField.font = UIFont.boldSystemFont(ofSize: 15)
        textPassField.tag = 2
        textPassField.placeholder = "密码"
        textPassField.text = ""
        inputPassView.layer.borderWidth = 1
        inputPassView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1).cgColor
        inputPassView.layer.cornerRadius = 20
        
        inputPassView.addSubview(textPassField)
        
        
        eyes.setImage(UIImage(named: "眼睛"), for: UIControlState.normal)
        eyes.frame = CGRect(x: inputView.frame.width - 30, y: 10, width: 20, height: 20)
        eyes.addTarget(self, action: #selector(toSeePass(_:)), for: UIControlEvents.touchUpInside)
        inputPassView.addSubview(eyes)
        inputView.addSubview(inputPassView)
        contentView.addSubview(inputView)
        
        let flagPassView = UIView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height*2/5+120, width: 150, height: 20))
        flagButton.frame =  CGRect(x: 0, y: 2.5, width: 120, height: 15)
        flagButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        flagButton.setTitleColor(UIColor(red: 7/255, green: 128/255, blue: 237/255, alpha: 1), for: UIControlState.normal)
        flagButton.addTarget(self, action: #selector(LoginViewController.buttonStatus), for: UIControlEvents.touchUpInside)
        flagPassView.addSubview(flagButton)
        contentView.addSubview(flagPassView)
        
        
        let buttonView = UIButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.height*2/5+150, width: view.frame.width-40, height: 40))
        buttonView.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        buttonView.setTitle("登录", for: UIControlState.normal)
        buttonView.setTitle("登录", for: UIControlState.highlighted)
        buttonView.setTitleColor(UIColor.white,for: .normal) //普通状态下文字的颜色
        buttonView.setTitleColor(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1),for: .highlighted) //触摸状态下文字的颜色
        buttonView.layer.cornerRadius = 20
        buttonView.layer.backgroundColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor
        buttonView.addTarget(self, action: #selector(LoginViewController.startTouch(_:)), for: UIControlEvents.touchUpInside)
        contentView.addSubview(buttonView)
        
        let portButtonView = UIButton(frame: CGRect(x: 20, y: UIScreen.main.bounds.height*2/5+210, width: view.frame.width-40, height: 40))
        portButtonView.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        portButtonView.setTitle("端口设置", for: UIControlState.normal)
        portButtonView.setTitle("端口设置", for: UIControlState.highlighted)
        portButtonView.setTitleColor(UIColor.gray, for: UIControlState.normal)
        portButtonView.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.39),for: UIControlState.highlighted)
        portButtonView.layer.cornerRadius = 20
        portButtonView.layer.backgroundColor = UIColor.white.cgColor
        portButtonView.addTarget(self, action: #selector(changePort), for: UIControlEvents.touchUpInside)
        contentView.addSubview(portButtonView)
        //MARK:设置内容页大小
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: kScreenHeight)
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: kScreenHeight)
        scrollView.backgroundColor = UIColor.white
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        let name1 = self.userDefault.string(forKey: "name")
        textNameField.text = (name1 != nil) ? name1 : ""
        if flageStatus{//选中状态
            flagButton.set(image: UIImage(named: "复选2"), title: "记住密码", titlePosition: UIViewContentMode.right, additionalSpacing: 15, state: UIControlState.normal)
            let Value = self.userDefault.string(forKey: "password")
            textPassField.text = (Value != nil) ? Value : ""
        }else{//没有选中状态
            flagButton.set(image: UIImage(named: "复选1"), title: "记住密码", titlePosition: UIViewContentMode.right, additionalSpacing: 15, state: UIControlState.normal)
        }
        //MARK:设置端口按钮事件
        popViewController.ok.addTarget(self, action: #selector(touchOk), for: UIControlEvents.touchUpInside)
        popViewController.cancel.addTarget(self, action: #selector(touchCancel), for: UIControlEvents.touchUpInside)
        currentNetReachability()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 2{
            //收起键盘
            textField.resignFirstResponder()
            
            //登录
            requestLoginNet()
        }else{
            textPassField.becomeFirstResponder()
        }
        //打印出文本框中的值
        print(textField.text as Any)
        return true;
    }
    //MAEK:查看密码功能
    @objc func toSeePass(_ button:UIButton){
        if !seePass {
            textPassField.isSecureTextEntry = false
            seePass = true
        }else{
            textPassField.isSecureTextEntry = true
            seePass = false
        }
    }
    //MARK:记住密码功能
    @objc func buttonStatus(){
        if !flageStatus {//选中状态
            flagButton.setImage(UIImage(named: "复选2"), for: UIControlState.normal)
            flageStatus = true
            self.userDefault.set(flageStatus, forKey: "buttonStatus")
        }else{//没有选中状态
            flagButton.setImage(UIImage(named: "复选1"), for: UIControlState.normal)
            flageStatus = false
            self.userDefault.set(flageStatus, forKey: "buttonStatus")
        }
    }
    //MARK:端口按钮
    @objc func changePort(){
        //            self.present(PortViewController(), animated: false, completion: nil)
        
        popView = popViewController.creatAlertView()
        view.addSubview(popView)
        
    }
    //MARK:端口按钮确认键
    @objc fileprivate func touchOk(_ button:UIButton){
        if (popViewController.ipText.text?.isEmpty)!{
            windowAlert(msges: "ip不能为空！")
            return
        }
        if (popViewController.portText.text?.isEmpty)!{
            windowAlert(msges: "端口不能为空！")
            return
        }
        userDefault.set("\(popViewController.ipText.text ?? "127.0.0.1"):\(popViewController.portText.text ?? "8080")", forKey: "AppUrlAndPort")
        popView.removeFromSuperview()
    }
    //MARK:端口按钮取消键
    @objc fileprivate func touchCancel(_ button:UIButton){
        
        popView.removeFromSuperview()
    }
    
    //MARK:登录按钮
    @objc func startTouch(_ button:UIButton){
        UIView.animate(withDuration: 0.2, animations: {
            button.layer.backgroundColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 0.5).cgColor
        }) { (true) in
            button.layer.backgroundColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor
            self.requestLoginNet()
        }
        
    }
    func requestLoginNet(){
        let username : String = textNameField.text!
        let password : String = textPassField.text!
        if username == ""{
            windowAlert(msges: "用户名不能为空")
            return
        }
        if password == ""{
            windowAlert(msges: "密码不能为空")
            return
        }
        let userDefalutUrl = userDefault.string(forKey: "AppUrlAndPort")
        let urlStr = "http://\(userDefalutUrl ?? "10.4.65.103:8086")/interface"
        let contentData : [String : Any] = ["method":"login","info":["username":username,"password":password]]
        self.isCanLogin()
        if netStatus == true{
            //网络请求
            commonClass.requestData(urlStr: urlStr, outTime: 10, contentData: contentData, finished: { (resultData) in
                print(resultData)
                if resultData["status"].stringValue == "success"{
                    let json = resultData["data"]
                    let token = json["token"].object
                    let userId = json["user_id"].object
                    self.userDefault.set(urlStr, forKey: "AppUrl")
                    self.userDefault.set(token, forKey: "userToken")
                    self.userDefault.set(userId, forKey: "userId")
                    self.userDefault.set(username,forKey: "name")
                    if self.flageStatus {//判断是否保存密码
                        self.userDefault.set(password,forKey: "password")
                    }
                    ///实例化将要跳转的controller
                    let sb = UIStoryboard(name: "Main", bundle:nil)
                    let vc = sb.instantiateViewController(withIdentifier: "mainStoryboardViewController") as! MainTabViewController
                    self.present(vc, animated: false, completion: nil)
                }else if resultData["status"].stringValue == "err_token" {
                    
                }else if resultData["status"].stringValue == "err_namepwd"{
                    self.windowAlert(msges: "用户名或密码错误")
                }
                
            }) { (errorData) in
                self.windowAlert(msges: "网络请求失败")
                print("error:\(errorData)")
                return
            }
        }else{
            self.windowAlert(msges: "网络已断开,请检查网络")
        }
        
    }
    
    //MARK:alert弹框
    func windowAlert(msges : String){
        let alertView = UIAlertController(title: "提示", message: msges, preferredStyle: UIAlertControllerStyle.alert)
        let yes = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
        alertView.addAction(yes)
        self.present(alertView,animated:true,completion:nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func DeviceInfo() -> String{
        let infoDictionary = Bundle.main.infoDictionary!
        //        let appDisplayName = infoDictionary["CFBundleDisplayName"] //程序名称
        let majorVersion = infoDictionary["CFBundleShortVersionString"]//主程序版本号
        //        let minorVersion = infoDictionary["CFBundleVersion"]//版本号(内部标示)
        return majorVersion as! String
    }
    
    func currentNetReachability() {
        
        manager?.listener = { status in
            var statusStr: String?
            switch status {
            case .unknown:
                statusStr = "未识别的网络"
                break
            case .notReachable:
                statusStr = "不可用的网络(未连接)"
            case .reachable:
                if (self.manager?.isReachableOnWWAN)! {
                    statusStr = ""//"2G,3G,4G...的网络"
                } else if (self.manager?.isReachableOnEthernetOrWiFi)! {
                    statusStr = ""//"wifi的网络";
                }
                break
            }
            if statusStr == "" {
                self.netStatus = true
                self.getUpdate()
            }else{
                self.netStatus = false
                self.windowAlert(msges: "网络已断开,请检查网络")
            }
        }
        
    }
    
    func isCanLogin() {
        
        manager?.listener = { status in
            var statusStr: String?
            switch status {
            case .unknown:
                statusStr = "未识别的网络"
                break
            case .notReachable:
                statusStr = "不可用的网络(未连接)"
            case .reachable:
                if (self.manager?.isReachableOnWWAN)! {
                    statusStr = ""//"2G,3G,4G...的网络"
                } else if (self.manager?.isReachableOnEthernetOrWiFi)! {
                    statusStr = ""//"wifi的网络";
                }
            }
            if statusStr == "" {
                self.netStatus = true
            }else{
                self.netStatus = false
            }
        }
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        manager?.stopListening()
    }
}
