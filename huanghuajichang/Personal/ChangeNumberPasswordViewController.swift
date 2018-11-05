//
//  ChangeNumberPasswordViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/20.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChangeNumberPasswordViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var oldTextField: UITextField!
    
    @IBOutlet weak var newTextField: UITextField!
    
    @IBOutlet weak var confrimTextField: UITextField!
    
    var oldHave:Bool = false
    
    var newHave:Bool = false
    
    var confrimHave:Bool = false
    
    var rightBar:UIBarButtonItem!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "密码修改"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        let leftBar:UIBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backTolast))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        
        rightBar = UIBarButtonItem.init(title: "完成", style: UIBarButtonItemStyle.done, target: self, action: #selector(changePassword))
        rightBar.isEnabled = false
        rightBar.tintColor = UIColor.blue
        self.navigationItem.rightBarButtonItem = rightBar
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false//去掉导航栏的半透明效果
        
        oldTextField.delegate = self
        newTextField.delegate = self
        confrimTextField.delegate = self
        
        oldTextField.tag = 0
        newTextField.tag = 1
        confrimTextField.tag = 2
        
        //设置清除按钮的显示样式
        oldTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        newTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        confrimTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backTolast (){
        //由于本页面是present进来的所以用dismiss返回
        self.dismiss(animated: true, completion: nil)
    }
    @objc func changePassword () {
        if newTextField.text != confrimTextField.text{
            self.present(windowAlert(msges: "两次输入密码不同，请重新输入"), animated: true, completion: nil)
        }else {
            if oldTextField.text == newTextField.text{
                self.present(windowAlert(msges: "新旧密码相同，请重新输入"), animated: true, completion: nil)
            }else{
                let infoData = ["newpassword":newTextField.text, "password":oldTextField.text]
                let contentData : [String : Any] = ["method":"updatePassword","info":infoData,"token":userToken,"user_id":userId]
                NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
                    print(resultData)
                    switch resultData.result {
                    case .success(let value):
                        print(JSON(value).description)
                        if JSON(value)["status"].stringValue == "success"{
                            windowTotast(pageName: self, msg: "修改成功") {
                                self.backTolast ()
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
        }
    }
    
    //textField - editChange判断按钮的状态
   
    @IBAction func checkOld(_ sender: Any) {
        let oldText = sender as! UITextField
        print(oldText.text as Any)
        if oldText.text != ""{
            oldHave = true
            if newHave == true, confrimHave == true{
                rightBar.isEnabled = true
            }else{
                rightBar.isEnabled = false
            }
        }else{
            oldHave = false
            rightBar.isEnabled = false
        }
    }
    
    @IBAction func checkNew(_ sender: Any) {
        let newText = sender as! UITextField
        print(newText.text as Any)
        if newText.text != ""{
            newHave = true
            if oldHave == true, confrimHave == true{
                rightBar.isEnabled = true
            }else{
                rightBar.isEnabled = false
            }
        }else{
            newHave = false
            rightBar.isEnabled = false
        }
    }
    
    
    @IBAction func checkConfrim(_ sender: Any) {
        let confrimText = sender as! UITextField
        print(confrimText.text as Any)
        if confrimText.text != ""{
            confrimHave = true
            if newHave == true, oldHave == true{
                rightBar.isEnabled = true
            }else{
                rightBar.isEnabled = false
            }
        }else{
            confrimHave = false
            rightBar.isEnabled = false
        }
    }
    
    //#MARK - textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        //更改return键
        newTextField.returnKeyType = UIReturnKeyType.next
        
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField.tag == 1{
            confrimTextField.becomeFirstResponder()
            return false
        }else{
            textField.resignFirstResponder()
            return true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
