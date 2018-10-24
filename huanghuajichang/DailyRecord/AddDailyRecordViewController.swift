//
//  AddDailyRecordViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class AddDailyRecordViewController: AddNavViewController {
    
    var pageType:String!
    var rightSaveBtn:UIBarButtonItem!
    
    var titleView:UIView!
    var titleTextField:UITextField!
    var pickerView:UIView!
    var describeTextView:UITextView!
    var imgsView:UIView!
    var imagsData:NSMutableArray! = []
    var haveImagsData:NSMutableArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if pageType == "edit" {
            self.title = "编辑记录"
        }else{
            self.title = "新增记录"
        }
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
            titleTextField.delegate = self
            titleTextField.tag = i
            titleView.addSubview(titleTextField)
            
            if i == 0 {
                titleLabel.text = "标题:"
                titleTextField.autocapitalizationType = UITextAutocapitalizationType.none//关闭首字母大写
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
        ///part3 -- 描述部分
        let textView = UIView.init(frame: CGRect(x: 0, y: 100, width: kScreenWidth, height: 320))
        textView.backgroundColor = UIColor.white
        self.view.addSubview(textView)
        
        let describeLabel = UILabel.init(frame: CGRect(x: 10, y: 5, width: 35, height: 30))
        describeLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        describeLabel.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        describeLabel.text = "描述:"
        textView.addSubview(describeLabel)
        
        describeTextView = UITextView.init(frame: CGRect(x: 50, y: 5, width: kScreenWidth-50-10, height: 310))
        describeTextView.returnKeyType = .done
        describeTextView.autocapitalizationType = UITextAutocapitalizationType.none
//        describeTextView.line
        describeTextView.delegate = self
        textView.addSubview(describeTextView)
        
        //textview弹出的键盘添加工具栏
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: kScreenWidth, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //对输入框进行设置
        describeTextView.inputAccessoryView = toolbar
        
        ///part4 -- 图片部分
        imgsView = UIView.init(frame: CGRect(x: 0, y: 430, width: kScreenWidth, height: 105))
        imgsView.backgroundColor = UIColor.white
        self.view.addSubview(imgsView)
        
        let addImgBtn = UIButton.init(frame: CGRect(x: 10, y: 15, width: 75, height: 75))
        addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addImgBtn.layer.borderWidth = 1
        addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addImgBtn.tag = 1001
        addImgBtn.addTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
        imgsView.addSubview(addImgBtn)
        imagsData.add(addImgBtn)
    }
    
    @objc func doneButtonAction() {
        describeTextView.resignFirstResponder()
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
    
    @objc func addImgBtn (sender:UIButton) {
        //对按钮自身进行操作
        let index = sender.tag - 1000
        let deleteBtn = UIButton.init(frame: CGRect(x: 66, y: -9, width: 18, height: 18))
        deleteBtn.setImage(UIImage(named: "删除"), for: UIControlState.normal)
        deleteBtn.tag = 2000+index
        deleteBtn.addTarget(self, action: #selector(deleteImgBtn(sender:)), for: UIControlEvents.touchUpInside)
        sender.addSubview(deleteBtn)
        sender.removeTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.allEvents)
        haveImagsData.add(sender)
        if index == 3{
            return
        }
        //新增的按钮
        let addImgBtn = UIButton.init(frame: CGRect(x: CGFloat(index*(75+15)+10), y: 15, width: 75, height: 75))
        addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addImgBtn.layer.borderWidth = 1
        addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addImgBtn.tag = index + 1001
        addImgBtn.addTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
        imgsView.addSubview(addImgBtn)
        imagsData.add(addImgBtn)
    }
    
    @objc func deleteImgBtn(sender:UIButton){
        let index = sender.tag - 2000
        let changeStartIndex = index + 1001
        let endIndex = imagsData.count + 1000
        //1.首先移除自身所在图片按钮
        let superBtn = imgsView.viewWithTag(index + 1000) as! UIButton
        imagsData.remove(superBtn)
        haveImagsData.remove(superBtn)
        superBtn.removeFromSuperview()
        //2.更改之后按钮的tag,以及按钮的删除按钮tag
        if changeStartIndex <= endIndex{
            for i in changeStartIndex...endIndex{
                let changeBtn = imgsView.viewWithTag(i) as! UIButton
                 changeBtn.tag = changeBtn.tag - 1
                UIView.animate(withDuration: 0.3) {
                    changeBtn.center = CGPoint(x: CGFloat((changeBtn.tag-1000-1) * (15+75)+10+75/2), y: 15+75/2)
                }
                if let changeDeleteBtn = changeBtn.viewWithTag(i+1000) {
                    changeDeleteBtn.tag = changeDeleteBtn.tag - 1
                }
            }
        }
        
        if haveImagsData.count == 2 && haveImagsData.count == imagsData.count{
            //3.最后新增一个空白按钮
            let addImgBtn = UIButton.init(frame: CGRect(x: CGFloat(85+90+15), y: 15, width: 75, height: 75))
            addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
            addImgBtn.layer.borderWidth = 1
            addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
            addImgBtn.tag = imagsData.count + 1001
            addImgBtn.addTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
            imgsView.addSubview(addImgBtn)
            imagsData.add(addImgBtn)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func backItemPressed(){
        //present出的页面用dismiss不然会找不到上一页
        if pageType == "edit"{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }

}
extension AddDailyRecordViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//实现页面的移动
extension AddDailyRecordViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
}
