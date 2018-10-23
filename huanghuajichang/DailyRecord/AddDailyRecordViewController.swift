//
//  AddDailyRecordViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class AddDailyRecordViewController: AddNavViewController {
    
    var rightSaveBtn:UIBarButtonItem!
    
    var titleView:UIView!
    var titleTextField:UITextField!
    var pickerView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "新增记录"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:(UIFont(name: "PingFangSC-Regular", size: 18))!]
        self.view.backgroundColor = allListBackColor
        rightSaveBtn = UIBarButtonItem.init(title: "保存", style: UIBarButtonItemStyle.done, target: self, action: #selector(addPost))
        rightSaveBtn.isEnabled = false
        rightSaveBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightSaveBtn
        // Do any additional setup after loading the view.
        createUI()
    }
    ///新增日常记录
    @objc func addPost(){
        print("执行新增操作")
    }
    
    func createUI(){
        for i in 0...1{
            titleView = UIView.init(frame: CGRect(x: 0, y: CGFloat(i*50), width: kScreenWidth, height: 40))
            titleView.backgroundColor = UIColor.white
            self.view.addSubview(titleView)
            
            let titleLabel = UILabel.init(frame: CGRect(x: 10, y: 5, width: 35, height: 30))
            titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
            titleLabel.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
            titleView.addSubview(titleLabel)
            
            titleTextField = UITextField.init(frame: CGRect(x: 50, y: 5, width: kScreenWidth-50-10, height: 30))
            titleTextField.textColor = allFontColor
            titleTextField.tag = i
            titleView.addSubview(titleTextField)
            
            if i == 0 {
                titleLabel.text = "标题:"
            }else{
                titleLabel.text = "时间:"
                pickerView = UIView.init(frame: CGRect(x: 0, y: kScreenHeight - 200, width: kScreenWidth, height: 200))
                
                let cancelBtn = UIButton.init(frame: CGRect(x: 10, y: 10, width: 50, height: 20))
                cancelBtn.setTitle("取消", for: UIControlState.normal)
                pickerView.addSubview(cancelBtn)
                let okBtn = UIButton.init(frame: CGRect(x: kScreenWidth-60, y: 10, width: 50, height: 20))
                okBtn.setTitle("确定", for: UIControlState.normal)
                pickerView.addSubview(okBtn)
                
                let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 160))
                datePicker.datePickerMode = .date
                //        datePicker.setDate(NSDate., animated: da)
                datePicker.locale = Locale.init(identifier: "zh_CN")
                datePicker.calendar = Calendar.current
                datePicker.timeZone = TimeZone.current
                datePicker.tag = 1001
                pickerView.addSubview(datePicker)
                cancelBtn.addTarget(self, action: #selector(closePick), for: UIControlEvents.touchUpInside)
                okBtn.addTarget(self, action: #selector(getDate), for: UIControlEvents.touchUpInside)
                titleTextField.inputView = pickerView
            }
        }
        
        let textView = UIView.init(frame: CGRect(x: 0, y: 100, width: kScreenWidth, height: 320))
        textView.backgroundColor = UIColor.white
        self.view.addSubview(textView)
        
        let describeLabel = UILabel.init(frame: CGRect(x: 10, y: 5, width: 35, height: 30))
        describeLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        describeLabel.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        describeLabel.text = "描述:"
        textView.addSubview(describeLabel)
        
        let describeTextView = UITextView.init(frame: CGRect(x: 50, y: 5, width: kScreenWidth-50-10, height: 310))
        describeTextView.returnKeyType = .done
//        describeTextView.delegate = self
        textView.addSubview(describeTextView)
        
    }
    ///关闭自定义日期选择器
    @objc func closePick(){
        let dateTextField = titleView.viewWithTag(1) as! UITextField
        dateTextField.resignFirstResponder()
    }
    
    /// MARK: - 日期选择器选择处理方法
    @objc func getDate() {
        let datePicker = pickerView.viewWithTag(1001) as! UIDatePicker
        let formatter = DateFormatter()
        let date = datePicker.date
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateStr = formatter.string(from: date)
        let dateTextField = titleView.viewWithTag(1) as! UITextField
        dateTextField.text = dateStr
        dateTextField.resignFirstResponder()
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
