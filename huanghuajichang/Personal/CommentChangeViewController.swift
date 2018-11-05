//
//  CommentChangeViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentChangeViewController: AddNavViewController,UITextFieldDelegate {
    
    var changeTextfield:UITextField!
    var phoneText:String!
    var emailText:String!
    var pageType:Int!
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(changePost))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Do any additional setup after loading the view.
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        createUI()
    }
    
    @objc func changePost(){
        print("执行提交操作")
        var infoData:[String:Any] = [:]
        let oldEmail = self.userDefault.object(forKey: "UserEmail") as? String
        let oldMobile = self.userDefault.object(forKey: "UserMobile") as? String
        switch pageType {
        case 1://修改手机
            infoData = ["email":oldEmail!, "mobile":changeTextfield.text!]
        default://修改邮箱
            infoData = ["email":changeTextfield.text!, "mobile":oldMobile!]
        }
        let contentData : [String : Any] = ["method":"updateUserInfo","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                print(JSON(value).description)
                if JSON(value)["status"] == "success"{
                    windowTotast(pageName: self, msg: "修改成功") {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    self.present(windowAlert(msges: JSON(value)["msg"].description), animated: true, completion: nil)
                }
            case .failure(let error):
                self.present(windowAlert(msges: "修改失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    func createUI(){
        changeTextfield = UITextField.init(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 40))
        changeTextfield.delegate = self
        changeTextfield.borderStyle = UITextBorderStyle.none
        changeTextfield.clearButtonMode = .always
        changeTextfield.clearButtonRect(forBounds: CGRect(x: kScreenWidth-30, y: 10, width: 20, height: 20))
        changeTextfield.backgroundColor = UIColor.white
        changeTextfield.becomeFirstResponder()
        changeTextfield.adjustsFontSizeToFitWidth = true
        
        //添加textfield监听
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldValueChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        //左侧缩进
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 40))
        changeTextfield.leftView = leftView
        changeTextfield.leftViewMode = .always
        self.view.addSubview(changeTextfield)
        
        let changeLabel = UILabel.init(frame: CGRect(x: 10, y: 95, width: kScreenWidth, height: 20))
        if self.title == "修改手机号" {
            changeTextfield.text = phoneText
            changeTextfield.keyboardType = .numberPad
            changeLabel.text = "11位手机号"
            pageType = 1
        }else{
            changeTextfield.text = emailText
            changeTextfield.keyboardType = .emailAddress
            changeTextfield.autocapitalizationType = UITextAutocapitalizationType.none//关闭键盘默认首字母大写
            changeLabel.text = "邮箱账号"
            pageType = 2
        }
        changeLabel.font.withSize(10)
        changeLabel.textColor = allUnitColor
        self.view.addSubview(changeLabel)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        return true
    }
    
    @objc func textFieldValueChanged(sender: NSNotification){
        switch pageType {
        case 1:
            if let text = self.changeTextfield.text {
                if MyRegex.PhoneNumberIsValidated(vStr: text) {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }else{
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        default:
            if let text = self.changeTextfield.text {
               if MyRegex.EmailIsValidated(vStr: text) {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }else{
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    ///页面退出之前执行的操作
    override func viewWillDisappear(_ animated: Bool) {
        //推出键盘
        changeTextfield.resignFirstResponder()
        //移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
