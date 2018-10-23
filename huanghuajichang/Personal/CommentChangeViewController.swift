//
//  CommentChangeViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class CommentChangeViewController: AddNavViewController,UITextFieldDelegate {
    
    var phoneText:String!
    var emailText:String!
    var pageType:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(changePost))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Do any additional setup after loading the view.
        
        createUI()
    }
    
    @objc func changePost(){
        print("执行提交操作")
    }
    
    func createUI(){
        let changeTextfield = UITextField.init(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 40))
        changeTextfield.delegate = self
        changeTextfield.borderStyle = UITextBorderStyle.none
        changeTextfield.clearButtonMode = .always
        changeTextfield.clearButtonRect(forBounds: CGRect(x: kScreenWidth-30, y: 10, width: 20, height: 20))
        changeTextfield.backgroundColor = UIColor.white
        changeTextfield.becomeFirstResponder()
        changeTextfield.adjustsFontSizeToFitWidth = true
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch pageType {
        case 1:
            if let text = textField.text {
                let textLength = text.utf8CString.count + string.count - range.length
//                print("\(text.utf8CString.count);"+"\(string.count);"+"\(range.length)")
//                print(textLength)
                if textLength == 12 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }else if textLength > 12 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return false
                }else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        default:
            if let text = textField.text {
                let mailPattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
                let matcher = MyRegex(mailPattern)
                if matcher.match(input: text) {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }else{
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
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
