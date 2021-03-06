//
//  ViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/27.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import PGDatePicker
import MJRefresh
import Photos
import Kingfisher

class AddDeviceManagementViewController: UIViewController,PGDatePickerDelegate,AVCapturePhotoCaptureDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate {
    let commonClass = common()
    let cameraViewService = CameraViewService()
    var photoListr : [UIImage] = []
    let contentView : UIView = UIView()
    var selectorView:UIView = UIView()
    var selector:UIPickerView = UIPickerView()
    var clickedBtnTag = -1
    var eqCode = ""
    var selectorData:[[String:AnyObject]] = []
    var imageView = UIView()
    var addBut : UIButton!
    var mView = UIView()
    let addDeviceManagementService = AddDeviceManagementService()
    var addDeviceManagementModule = AddDeviceManagementModule()
    var selectedEquipmentId:String!
    var scrollView : UIScrollView = UIScrollView()
    var buildingId = ""
    var floorId = ""
    var roomId = ""
    var oneMeanId = ""
    var twoMeanId = ""
    var bigType = ""
    var smallType = ""
    let imageScrollViewWidth = Int(KUIScreenWidth-20)//图片区域的宽度
    var imageIndex = 0 //已经添加了的图片的数量
    var imageNumMax = 10//图片区域最多可放置的图片的数量
    var callBack = {(str:String)->Void in
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getOneAndTwo()
        // Do any additional setup after loading the view.
        callBack("测试")
    }
    
    func getOneAndTwo(){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentAndOrganization","user_id": userId as Any,"token": token as Any,"info":""]
        addDeviceManagementService.getEquipmentAndOrganization(contentData: contentData, finished: {(returnData) in
            print("--------------------------------")
            self.addDeviceManagementModule = returnData
            self.setLayout()
            print("--------------------------------")
        }, finishedError: {(errorData) in
            print("--------------------------------")
        })
    }
   
    override func viewWillAppear(_ animated: Bool){
        self.title = "新增设备"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromDeviceManagementViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadImgs))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if selectorView.isHidden == false{
            selectorView.isHidden = true
        }
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height
            let rect = CGRect(x: 0, y: -200, width: width, height: height)
            self.view.frame = rect
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        self.view.frame = rect
    }
    
    func setLayout(){
        
        contentView.frame = CGRect(x: 0, y: 0, width: KUIScreenWidth, height: UIApplication.shared.statusBarFrame.height+(navigationController?.navigationBar.frame.height)!+840)
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: KUIScreenWidth, height: KUIScreenHeight)
        scrollView.contentSize.height = contentView.frame.height
        scrollView.backgroundColor = UIColor.white
        scrollView.addSubview(contentView)
        
        contentView.backgroundColor = UIColor.white
        
        self.view.addSubview(scrollView)
        
//       单位选择部分
        let contentViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 121))
        contentViewHeader.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        let labelLeftStyle = UILabel(frame: CGRect(x: 10, y: 10, width: 5, height: 20))
        labelLeftStyle.backgroundColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        contentViewHeader.addSubview(labelLeftStyle)
        
        let labelRightcontent = UILabel(frame: CGRect(x: 20, y: 10, width: contentViewHeader.frame.width-40, height: 20))
        labelRightcontent.text = "单位选择"
        labelRightcontent.font = UIFont.boldSystemFont(ofSize: 15)
        labelRightcontent.textAlignment = .left
        contentViewHeader.addSubview(labelRightcontent)
        let fristStr = userDefault.object(forKey: "FristOriginal") as! String
        let secondStr = userDefault.object(forKey: "SecondOriginal") as! String
        //一级单位
        setContentOfSelectedListRow(top: 40, optionMode: contentViewHeader, text: "一级单位", selectTitle: fristStr, tag: 301)
        //二级单位
        setContentOfSelectedListRow(top: 81, optionMode: contentViewHeader, text: "二级单位", selectTitle: secondStr, tag: 302)
        //设置默认选中一二级单位
        for i in 0..<self.addDeviceManagementModule.organizatinoOneList.count{
            if fristStr == self.addDeviceManagementModule.organizatinoOneList[i].organizationName{
                oneMeanId = self.addDeviceManagementModule.organizatinoOneList[i].organizationId.description
            }
        }
        if oneMeanId != ""{
            let tempOrganizationTwoList = addDeviceManagementService.getOrganizationTwoList(organizationOneId: Int(oneMeanId)!, organizationTwoList: addDeviceManagementModule.organizationTwoList)
            for i in 0..<tempOrganizationTwoList.count{
                if secondStr == tempOrganizationTwoList[i].organizationName{
                    twoMeanId = tempOrganizationTwoList[i].organizationId.description
                }
            }
        }
        contentView.addSubview(contentViewHeader)
        
//        设备基本信息
        let contentForMode = UIView(frame: CGRect(x: 0, y: 121, width: contentView.frame.width, height: contentView.frame.height-121))
        let contentForModeHeader = UIView(frame: CGRect(x: 0, y: 0, width: contentForMode.frame.width, height: 40))
        contentForMode.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        let contentForModeHeaderLeftStyle = UILabel(frame: CGRect(x: 10, y: 10, width: 5, height: 20))
        contentForModeHeaderLeftStyle.backgroundColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        contentForModeHeader.addSubview(contentForModeHeaderLeftStyle)
        let contentForModeHeaderContentLabel = UILabel(frame: CGRect(x: 20, y: 10, width: contentForModeHeader.frame.width-20, height: 20))
        contentForModeHeaderContentLabel.text = "设备基本信息"
        contentForModeHeader.addSubview(contentForModeHeaderContentLabel)
        contentForMode.addSubview(contentForModeHeader)
        //建筑
        setContentOfSelectedListRow(top: 40, optionMode: contentForMode, text: "位置",selectTitle: "", tag: 200)
        //楼层和房间号
        setFloorAndRoomSelectedListRow(top: 80, optionMode: contentForMode, selectTitle: "测试", tag: 201)
        //设备大类
        setContentOfSelectedListRow(top: 122, optionMode: contentForMode, text: "设备大类",selectTitle: "", tag: 303)
        //设备小类
        setContentOfSelectedListRow(top: 163, optionMode: contentForMode, text: "设备小类",selectTitle: "", tag: 304)
        
        //设备标识
        setContentModeOptionOfInputView(top: 204, contentForInputMode: contentForMode, text: "设备标识",tag:400)
        //设备名称
        setContentModeOptionOfInputView(top: 245, contentForInputMode: contentForMode, text: "设备名称",tag:401)
        //设备型号
        setContentModeOptionOfInputView(top: 286, contentForInputMode: contentForMode, text: "设备型号",tag:402)
        //额定功率
        setContentModeOptionOfInputView(top: 327, contentForInputMode: contentForMode, text: "额定功率",tag:403)
        //供应商
        setContentModeOptionOfInputView(top: 368, contentForInputMode: contentForMode, text: "供应商",tag:404)
        //生产日期
        setDateView(top: 409, contentForDateMode: contentForMode, text: "生产日期", tag: 500)
        //安装日期
        setDateView(top: 450, contentForDateMode: contentForMode, text: "安装日期", tag: 520)
        //数据绑定
        setSelectView(top: 491, contentForSelectMode: contentForMode, text: "数据是否绑定", tag: 600)
        //是否有效
        setSelectView(top: 562, contentForSelectMode: contentForMode, text: "是否有效", tag: 620)
        //图片上传
        setPicView(top: 613, contentForPicMode: contentForMode, tag: 700)
        
        contentView.addSubview(contentForMode)
        
        
        ///选择弹出框
        selectorView.frame = CGRect(x: 0, y: KUIScreenHeight-240, width: KUIScreenWidth, height: 240)
        selectorView.isHidden = true
        self.view.addSubview(selectorView)
        
        let selectorToolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: 40))
        selectorToolBar.backgroundColor = UIColor.white
        let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        selectorToolBar.setItems([cancelBtn,flexSpace, doneBtn], animated: false)
        selectorToolBar.sizeToFit()
        selectorView.addSubview(selectorToolBar)
        
        selector.frame = CGRect(x: 0, y: 40, width: KUIScreenWidth, height: 200)
        selector.delegate = self
        selector.dataSource = self
        selector.backgroundColor = UIColor.white
        selectorView.addSubview(selector)
        
        
    }
    
    //设置楼层和房间的下拉
    func setFloorAndRoomSelectedListRow(top:Int,optionMode:UIView,selectTitle:String,tag:Int){
        let contentForModeRow2 = UIView(frame: CGRect(x: 0, y: top, width: Int(KUIScreenWidth), height: 40))
        contentForModeRow2.backgroundColor = UIColor.white
        let contentForModeTwoMean = UIButton()
        contentForModeTwoMean.frame = CGRect(x: 100, y: 5, width: 60, height: 30)
        contentForModeTwoMean.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        contentForModeTwoMean.setNewStyle(image: UIImage(named: "test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
        contentForModeTwoMean.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        contentForModeTwoMean.layer.borderWidth = 1
        contentForModeTwoMean.tag = tag
        contentForModeTwoMean.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        
        let contentForModeTwoMean1 = UIButton()
        contentForModeTwoMean1.frame = CGRect(x: 170, y: 5, width: 100, height: 30)
        contentForModeTwoMean1.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        contentForModeTwoMean1.setNewStyle(image: UIImage(named: "test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        contentForModeTwoMean1.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        contentForModeTwoMean1.layer.borderWidth = 1
        contentForModeTwoMean1.tag = tag+1
        contentForModeTwoMean1.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        
        contentForModeRow2.addSubview(contentForModeTwoMean)
        contentForModeRow2.addSubview(contentForModeTwoMean1)
        optionMode.addSubview(contentForModeRow2)
    }
    
    //设置contentMode中有下拉所在的行
    func setContentOfSelectedListRow(top:Int,optionMode:UIView,text:String,selectTitle:String,tag:Int){
        let contentForModeRow2 = UIView(frame: CGRect(x: 0, y: top, width: Int(optionMode.frame.width), height: 40))
        contentForModeRow2.backgroundColor = UIColor.white
        let contentForModeLeftStar2 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        contentForModeLeftStar2.image = UIImage(named: "必填项")
        contentForModeRow2.addSubview(contentForModeLeftStar2)
        
        let contentForModeName2 = UILabel(frame: CGRect(x: 20, y: 5, width: 90, height: 30))
        contentForModeName2.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        contentForModeName2.text = "\(text)："
        contentForModeName2.textAlignment = .justified
        contentForModeName2.font = UIFont.boldSystemFont(ofSize: 14)
        contentForModeRow2.addSubview(contentForModeName2)
        
        let contentForModeTwoMean = UIButton()
        contentForModeTwoMean.frame = CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30)
        contentForModeTwoMean.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        contentForModeTwoMean.setNewStyle(image: UIImage(named: "test"), title: selectTitle, titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
        contentForModeTwoMean.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        contentForModeTwoMean.layer.borderWidth = 1
        contentForModeTwoMean.tag = tag
        contentForModeTwoMean.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        contentForModeRow2.addSubview(contentForModeTwoMean)
        
        optionMode.addSubview(contentForModeRow2)
    }
    
    //设置有输入框的所在的行
    func setContentModeOptionOfInputView(top:Int,contentForInputMode:UIView,text:String,tag:Int){
        let contentForModeRow3 = UIView(frame: CGRect(x: 0, y: top, width: Int(contentForInputMode.frame.width), height: 40))
        contentForModeRow3.backgroundColor = UIColor.white
        let contentForModeLeftStar3 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        if tag == 404{
            contentForModeLeftStar3.image = UIImage(named: "test")
        }else{
            contentForModeLeftStar3.image = UIImage(named: "必填项")
        }
        contentForModeRow3.addSubview(contentForModeLeftStar3)
        
        let contentForModeName3 = UILabel(frame: CGRect(x: 20, y: 5, width: 90, height: 30))
        contentForModeName3.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        contentForModeName3.text = "\(text)："
        contentForModeName3.font = UIFont.boldSystemFont(ofSize: 14)
        contentForModeRow3.addSubview(contentForModeName3)
        let inputView = UIView(frame: CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30))
        let input = UITextField()
        input.delegate = self
        input.frame = CGRect(x: 10, y: 0, width: KUIScreenWidth - 140, height: 30)
        input.adjustsFontSizeToFitWidth=true  //当文字超出文本框宽度时，自动调整文字大小
        input.minimumFontSize=11  //最小可缩小的字号
        /** 水平对齐 **/
        input.textAlignment = .left
        /** 垂直对齐 **/
        input.contentVerticalAlignment = .center
        input.text = ""
        input.keyboardType = UIKeyboardType.default
        if tag == 400{//设备标识不可编辑
            input.isEnabled = false
            inputView.backgroundColor = UIColor.pg_color(withHexString: "#EEEEEE")
            input.text = eqCode
        }else if tag == 403{
            input.keyboardType = UIKeyboardType.decimalPad
            input.frame = CGRect(x: 10, y: 0, width: KUIScreenWidth - 140 - 30, height: 30)
            let unit = UILabel.init(frame: CGRect(x: KUIScreenWidth - 130 - 30, y: 5, width: 30, height: 20))
            unit.text = "(kW)"
            unit.sizeToFit()
            unit.textAlignment = .right
            inputView.addSubview(unit)
        }else if tag == 404{
            
        }else{
            
        }
        input.clearButtonMode = .whileEditing  //编辑时出现清除按钮
        //textField.clearButtonMode = .unlessEditing  //编辑时不出现，编辑后才出现清除按钮
        //textNameField.clearButtonMode = .always  //一直显示清除按钮
        //textNameField.becomeFirstResponder()
        input.font = UIFont.boldSystemFont(ofSize: 15)
        input.tag = tag
        input.returnKeyType = UIReturnKeyType.done
        inputView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        inputView.layer.borderWidth = 1
        inputView.addSubview(input)
        contentForModeRow3.addSubview(inputView)
        contentForInputMode.addSubview(contentForModeRow3)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true;
    }
    //带日期控件的view
    func setDateView(top:Int,contentForDateMode:UIView,text:String,tag:Int){
        let inProducedDateLabel:UILabel = UILabel()
        let contentForModeRow3 = UIView(frame: CGRect(x: 0, y: top, width: Int(contentForDateMode.frame.width), height: 40))
        contentForModeRow3.backgroundColor = UIColor.white
        let contentForModeLeftStar3 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        contentForModeRow3.addSubview(contentForModeLeftStar3)
        
        let contentForModeName3 = UILabel(frame: CGRect(x: 20, y: 5, width: 90, height: 30))
        contentForModeName3.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        contentForModeName3.text = "\(text)："
        contentForModeName3.font = UIFont.boldSystemFont(ofSize: 14)
        contentForModeRow3.addSubview(contentForModeName3)
        
        let dateChangeView = UIView(frame: CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30))
        //日期插件
        inProducedDateLabel.frame = CGRect(x: 10, y: 0, width: 90, height: 30)
        inProducedDateLabel.textAlignment = .left
        inProducedDateLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        inProducedDateLabel.tag = tag
        let currentMonth = NSDate()
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM-dd"
        if tag == 500{
            contentForModeLeftStar3.image = UIImage(named: "test")
            inProducedDateLabel.text = ""
        }else{
            contentForModeLeftStar3.image = UIImage(named: "必填项")
            inProducedDateLabel.text = dateFormater.string(from: currentMonth as Date) as String
        }
        
        dateChangeView.addSubview(inProducedDateLabel)
        dateChangeView.layer.borderWidth = 1
        dateChangeView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        let dateBtn = UIButton.init(frame: CGRect(x: dateChangeView.frame.width-40, y: 5, width: 20, height: 20))
        dateBtn.setImage(UIImage(named: "日期"), for: UIControlState.normal)
        dateBtn.tag = tag+1
        dateBtn.addTarget(self, action: #selector(opendatePicker), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(dateBtn)
        contentForModeRow3.addSubview(dateChangeView)
        contentForDateMode.addSubview(contentForModeRow3)
    }
    
    func setSelectView(top:Int,contentForSelectMode:UIView,text:String,tag:Int){
        let contentForModeRow3 = UIView()
        let rightView = UIView(frame: CGRect(x: 130, y: 5, width: KUIScreenWidth - 160, height: 30))
        let rightViewOfButtom = UIView(frame: CGRect(x: 0, y: 30, width: rightView.frame.width, height: 30))
        let rightViewOfLabel = UILabel()
        
        //判断是“数据绑定”还是“是否有效”
        if tag == 620{
            contentForModeRow3.frame = CGRect(x: 0, y: top, width: Int(contentForSelectMode.frame.width), height: 40)
            rightViewOfLabel.frame = CGRect(x: 0, y: 0, width: rightViewOfButtom.frame.width, height: 30)
            rightViewOfLabel.text = ""
        }else{
            contentForModeRow3.frame = CGRect(x: 0, y: top, width: Int(contentForSelectMode.frame.width), height: 60)
            rightViewOfLabel.frame = CGRect(x: 0, y: 0, width: rightViewOfButtom.frame.width, height: 30)
            rightViewOfLabel.text = "（注：数据绑定情况下选否，会删除绑定数据）"
            rightViewOfLabel.font = UIFont.boldSystemFont(ofSize: 10)
            rightViewOfLabel.textColor = UIColor(red: 208/255, green: 19/255, blue: 19/255, alpha: 0.58)
            rightViewOfButtom.addSubview(rightViewOfLabel)
        }
        
        contentForModeRow3.backgroundColor = UIColor.white
        let contentForModeLeftStar3 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        contentForModeLeftStar3.image = UIImage(named: "必填项")
        contentForModeRow3.addSubview(contentForModeLeftStar3)
        
        let contentForModeName3 = UILabel(frame: CGRect(x: 20, y: 5, width: 120, height: 30))
        contentForModeName3.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
        contentForModeName3.text = "\(text)："
        contentForModeName3.font = UIFont.boldSystemFont(ofSize: 14)
        contentForModeRow3.addSubview(contentForModeName3)
        
        let rightViewOfTop = UIView(frame: CGRect(x: 0, y: 5, width: rightView.frame.width, height: 30))
        let trueBtn = UIButton(frame: CGRect(x: 30, y: 0, width: 20, height: 20))
        trueBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        trueBtn.tag = tag
        trueBtn.set(image: UIImage(named: "未选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
        trueBtn.addTarget(self, action: #selector(selectAction), for: UIControlEvents.touchUpInside)
        
        let falseBtn = UIButton(frame: CGRect(x: rightView.frame.width-60, y: 0, width: 20, height: 20))
        falseBtn.tag = tag+1
        falseBtn.set(image: UIImage(named: "选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
        let statusData = UILabel()
        statusData.text = "0" // 0否 1是
        statusData.tag = tag+5
        rightViewOfTop.addSubview(statusData)
        falseBtn.addTarget(self, action: #selector(selectAction), for: UIControlEvents.touchUpInside)
        falseBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        rightViewOfTop.addSubview(trueBtn)
        rightViewOfTop.addSubview(falseBtn)
        
        
        
        
        //        let trueLabel = UILabel(frame: CGRect(x: 35, y: 5, width: 20, height: 20))
        rightView.addSubview(rightViewOfButtom)
        rightView.addSubview(rightViewOfTop)
        contentForModeRow3.addSubview(rightView)
        contentForSelectMode.addSubview(contentForModeRow3)
    }
    
    @objc func selectAction(btn:UIButton){
        
        if btn.tag >= 620{//是判断是否有效的按钮
            if btn.tag == 620{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag+1) as! UIButton
                let statusData = self.view.viewWithTag(btn.tag+5) as! UILabel
                statusData.text = "1"
                actionSelectTrueBtn.set(image: UIImage(named: "选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "未选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }else{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag-1) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let statusData = self.view.viewWithTag(btn.tag+4) as! UILabel
                statusData.text = "0"
                actionSelectTrueBtn.set(image: UIImage(named: "未选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }
        }else{//是判断是否绑定的按钮
            if btn.tag == 600{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag+1) as! UIButton
                let statusData = self.view.viewWithTag(btn.tag+5) as! UILabel
                statusData.text = "1"
                actionSelectTrueBtn.set(image: UIImage(named: "选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "未选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }else{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag-1) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let statusData = self.view.viewWithTag(btn.tag+4) as! UILabel
                statusData.text = "0"
                actionSelectTrueBtn.set(image: UIImage(named: "未选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }
        }
    }
    //MARK:提交所有数据
    @objc func uploadImgs(){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        if photoListr.count > 0{
            cameraViewService.upLoadPic(images: photoListr, finished: { (fileId,status) in
                if status == "success"{
                    self.getCommitData(userId: userId!, token: token!, fileId: fileId)
                }else if status == "sign_app_err"{
                    self.present(windowAlert(msges: "token失效"), animated: true, completion: nil)
                }
            }) {
                print("错误")
            }
        }else{
            self.present(windowAlert(msges: "请上传图片"), animated: false, completion: nil)
        }
        
    }
    //MARK:获取将要提交的数据
    func getCommitData(userId : String,token : String,fileId : String){
        
        let biaoShi = self.view.viewWithTag(400) as! UITextField
        let mingCheng = self.view.viewWithTag(401) as! UITextField
        let xingHao = self.view.viewWithTag(402) as! UITextField
        let eDingGongLu = self.view.viewWithTag(403) as! UITextField
        let gongYingShang = self.view.viewWithTag(404) as! UITextField
        let shengChanRiQi = self.view.viewWithTag(500) as! UILabel
        let anZhuangRiQi = self.view.viewWithTag(520) as! UILabel
        let bangDingStatus = self.view.viewWithTag(605) as! UILabel
        let youXiaoStatus = self.view.viewWithTag(625) as! UILabel
        if buildingId == ""{
            self.present(windowAlert(msges: "请选择楼位置"), animated: false, completion: nil)
        }else if floorId == ""{
            self.present(windowAlert(msges: "请选择楼层"), animated: false, completion: nil)
        }else if roomId == ""{
            self.present(windowAlert(msges: "请选择房间号"), animated: false, completion: nil)
        }else if oneMeanId == ""{
            self.present(windowAlert(msges: "请选择一级单位"), animated: false, completion: nil)
        }else if twoMeanId == ""{
            self.present(windowAlert(msges: "请选择二级单位"), animated: false, completion: nil)
        }else if bigType == ""{
            self.present(windowAlert(msges: "请选择设备大类"), animated: false, completion: nil)
        }else if smallType == ""{
            self.present(windowAlert(msges: "请选择设备小类"), animated: false, completion: nil)
        }else if biaoShi.text == ""{
            self.present(windowAlert(msges: "请添加设备标识"), animated: false, completion: nil)
        }else if mingCheng.text == ""{
            self.present(windowAlert(msges: "请添加设备名称"), animated: false, completion: nil)
        }else if xingHao.text == ""{
            self.present(windowAlert(msges: "请添加设备型号"), animated: false, completion: nil)
        }else if eDingGongLu.text == ""{
            self.present(windowAlert(msges: "请添加设备额定功率"), animated: false, completion: nil)
        }else if anZhuangRiQi.text == ""{
            self.present(windowAlert(msges: "请选择安装日期"), animated: false, completion: nil)
        }else{
            let bangDingStatusVal = bangDingStatus.text
            let youXiaoStatusVal = youXiaoStatus.text
            let commitData : [String:Any] = ["method":"saveEquipment","user_id": userId as Any,"token": token as Any,"info":["basEquInfo":["equName":mingCheng.text as Any,"equNo":biaoShi.text as Any,"specification":xingHao.text as Any,"equCategoryBig":bigType,"equCategorySmall":smallType,"manufactureDate":shengChanRiQi.text as Any,"spName":gongYingShang.text as Any,"filesId":fileId,"installDate":anZhuangRiQi.text as Any,"power":eDingGongLu.text as Any,"departmentIdOne":oneMeanId,"status":youXiaoStatusVal as Any,"departmentIdTwo":twoMeanId,"dataStatus":bangDingStatusVal as Any,"buildingId":buildingId,"floorId":floorId,"roomId":roomId]]]
            addDeviceManagementService.commitAllData(contentData: commitData, finishedCall: { (resultType) in
                if resultType == "success"{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initDeviceManagementViewController"), object: nil)
                    let deviceDetailViewController = DeviceDetailViewController()
                    deviceDetailViewController.eqCode = biaoShi.text!
                    deviceDetailViewController.flagePageFrom = 3
                    let vcs = self.navigationController!.viewControllers
                    let newVCS:NSMutableArray = []
                    if vcs.count > 0 {
                        for i in vcs.enumerated(){
                            newVCS.add(vcs[i.offset])
                        }
                    }
                    newVCS.add(deviceDetailViewController)
                    self.navigationController?.setViewControllers(newVCS as! [UIViewController], animated: true)
                }else if resultType == "sign_app_err" {
                    self.present(windowAlert(msges: "token失效"), animated: true, completion: nil)
                }else{
                    
                }
                
            }) { (errorData) in
                print(errorData)
                self.present(windowAlert(msges: "网络错误"), animated: true, completion: nil)
            }
        }
    }
    func setPicView(top:Int,contentForPicMode:UIView,tag:Int) {
        mView.frame = CGRect(x: 0, y: top, width: Int(KUIScreenWidth), height: 180)
        mView.backgroundColor = UIColor.white
//        mView.backgroundColor = UIColor.white
        imageView.frame = CGRect(x: 10, y: 10, width: imageScrollViewWidth, height: 160)
        imageView.backgroundColor = UIColor.white
        imageView.tag = tag
        mView.addSubview(imageView)
        contentForPicMode.addSubview(mView)
        imageMethods()
    }
    func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[String:Any]){
        var img:UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
        if picker.allowsEditing {
            img = info[UIImagePickerControllerEditedImage] as? UIImage
        }
        let data = UIImageJPEGRepresentation(img!,0.5)
        img = UIImage.init(data: data!)
        //let imagePickerc = info[UIImagePickerControllerOriginalImage] as!UIImage
        //添加图片
        addPic(pic : img!)
        self.dismiss(animated:true,completion:nil)
    }
    
    func imageMethods(){
        for i in 0..<photoListr.count{
            let viewOption = UIButton()
            if(i >= imageNumMax){
                viewOption.frame = CGRect(x: 75*(i-imageNumMax), y: 80, width: 70, height: 70)
            }else{
                viewOption.frame = CGRect(x: 75*i, y: 0, width: 70, height: 70)
            }
            viewOption.tag = i+4000 // 图片所在图层
            viewOption.backgroundColor = UIColor.white
            viewOption.addTarget(self, action: #selector(toSeePic(sender:)), for: UIControlEvents.touchUpInside)
            let image = UIImageView()
            image.tag = i+1000 // 图片
            image.frame = CGRect(x: 0, y: 10, width: 60, height: 60)
            image.image = photoListr[i]
            viewOption.addSubview(image)
            let deleteBut = deleteBtn(tag: i + 6000)
            viewOption.addSubview(deleteBut)
            imageView.addSubview(viewOption)
        }
        if photoListr.count >= 6{
            //            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
        
    }
    
    func addPic(pic : UIImage){
        
        imageNumMax = imageScrollViewWidth/75
        let addBtn = imageView.viewWithTag(3001) as! UIButton
        addBtn.removeTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        addBtn.removeFromSuperview()
        let viewOption = UIButton()
        if(imageIndex >= imageNumMax){//超过最大数量换行
            viewOption.frame = CGRect(x: 75*(photoListr.count-imageNumMax), y: 80, width: 70, height: 70)
        }else{
            viewOption.frame = CGRect(x: 75*photoListr.count, y: 0, width: 70, height: 70)
        }
        viewOption.tag = 4000+photoListr.count // 图片所在图层
        viewOption.backgroundColor = UIColor.white
        viewOption.addTarget(self, action: #selector(toSeePic(sender:)), for: UIControlEvents.touchUpInside)
        let image = UIImageView()
        image.image = UIImage(named: "image")
        image.tag = photoListr.count + 1000 //图片
        image.frame = CGRect(x: 0, y: 10, width: 60, height: 60)
        image.image = pic
        viewOption.addSubview(image)
        let deleteBut = deleteBtn(tag: photoListr.count + 6000)
        viewOption.addSubview(deleteBut)
        photoListr.append(pic)
        imageView.addSubview(viewOption)
        imageIndex += 1//放置图片数量加一
        if photoListr.count >= 6{
            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
    }
    
    @objc func toSeePic(sender:UIButton){
        let index = sender.tag - 4000
        let vc = PictureVisitControl(index: index, images: photoListr)
        present(vc, animated: true, completion:  nil)
    }
    //MARK:设置添加按钮
    func setAddBut(){
        if(imageIndex >= imageNumMax){
            addBut = UIButton(frame: CGRect(x: 75*(photoListr.count-imageNumMax)+10, y: 100, width: 40, height: 40))
        }else{
            addBut = UIButton(frame: CGRect(x: 75*photoListr.count+10, y: 20, width: 40, height: 40))
        }
        
        addBut.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addBut.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addBut.layer.borderWidth = 1
        addBut.tag = 3001 // 添加按钮
        addBut.setTitleColor(UIColor.white, for: UIControlState.normal)
        addBut.addTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        imageView.addSubview(addBut)
    }
    
    func deleteBtn(tag : Int)->UIButton{
        let deleteBut = UIButton(frame: CGRect(x: 50, y: 0, width: 20, height: 20))
        deleteBut.setImage(UIImage(named: "删除"), for: UIControlState.normal)
        deleteBut.tag = tag // 删除按钮
        deleteBut.addTarget(self, action: #selector(deleteImg), for: UIControlEvents.touchUpInside)
        return deleteBut
    }
    
    @objc func deleteImg(button:UIButton){
        print(button.tag)
        var index = button.tag - 5000 //根据下标的大小判断这个要删除的图片在那个数组里面 5000是deviceDetailPageImageList数组，6000是photoListr
//        button.superview?.superview?.removeFromSuperview()
        if index >= 1000{
            index = index - 1000
            photoListr.remove(at: index)
        }
        clearImages(btn: button)
        //重新加载图片图层
        imageMethods()
    }
    
    func clearImages(btn button:UIButton){
        let imgs = button.superview?.superview?.subviews
        for children in imgs!{
            children.removeFromSuperview()
        }
    }
    
    @objc func opendatePicker(btn:UIButton){
        for i in 0...4{//关闭键盘
            let input = self.view.viewWithTag(400+i) as! UITextField
            input.resignFirstResponder()
        }
        if selectorView.isHidden == false{
            selectorView.isHidden = true
        }
        let datePickerManager = PGDatePickManager.init()
        datePickerManager.isShadeBackgroud = true
        datePickerManager.style = .alertBottomButton
        let datePicker = datePickerManager.datePicker!
        datePicker.delegate = self
        datePicker.datePickerType = .type2
        datePicker.datePickerMode = PGDatePickerMode.date
        datePicker.tag = btn.tag-1
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let tempLabelText = self.view.viewWithTag(btn.tag-1) as! UILabel
        let date = dateFormater.date(from: tempLabelText.text!)
        datePicker.setDate(date, animated: false)
        self.present(datePickerManager, animated: false, completion: nil)
    }
    

    
   
    //MARK:设置actionSheet
    @objc func actionSheet(){
        let alertSheet = UIAlertController(title: "提示", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let camera = UIAlertAction(title: "照相机", style: UIAlertActionStyle.default) { (action) in
            self.cameraEvent()
        }
        let photo = UIAlertAction(title: "相册", style: UIAlertActionStyle.destructive) { (action) in
            self.photoEvent()
        }
        alertSheet.addAction(camera)
        alertSheet.addAction(photo)
        alertSheet.addAction(cancel)
        self.present(alertSheet,animated: true,completion: nil)
    }
    
    func cameraEvent(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //允许编辑
            picker.allowsEditing = true
            self.present(picker,animated:true,completion: nil)
        }else{
            print("找不到相机")
        }
        
    }
    func photoEvent(){
        let pickerPhotos = UIImagePickerController()
        pickerPhotos.delegate = self
        self.present(pickerPhotos, animated: true, completion: nil)
    }
    
    @objc func cancelButtonAction(){
        selectorView.isHidden = true
    }
    //MARK:下拉菜单列表
    @objc func doneButtonAction(){
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectIndex = selector.selectedRow(inComponent: 0)
        let selectText = selectorData[selectIndex]["typeName"]?.description
        selectBtn.setNewStyle(image: UIImage(named: "test"), title: selectText!, titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
        selectorView.isHidden = true
        
        switch clickedBtnTag {
        case 200:
            buildingId = (selectorData[selectIndex]["typeId"]?.description)!
            let floorView = self.view.viewWithTag(201) as! UIButton
            floorView.setNewStyle(image: UIImage(named:"test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
            let roomView = self.view.viewWithTag(202) as! UIButton
            roomView.setNewStyle(image: UIImage(named:"test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
        case 201:
            floorId = (selectorData[selectIndex]["typeId"]?.description)!
            let roomView = self.view.viewWithTag(202) as! UIButton
            roomView.setNewStyle(image: UIImage(named:"test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: 0, state: UIControlState.normal)
        case 202:
            roomId = (selectorData[selectIndex]["typeId"]?.description)!
        case 301:
            oneMeanId = (selectorData[selectIndex]["typeId"]?.description)!
            let organizationTwoBtn = self.view.viewWithTag(302) as! UIButton
            organizationTwoBtn.setNewStyle(image: UIImage(named: "test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: (KUIScreenWidth-100)*0.5, state: UIControlState.normal)
        case 302:
            twoMeanId = (selectorData[selectIndex]["typeId"]?.description)!
        case 303:
            bigType = (selectorData[selectIndex]["typeId"]?.description)!
            let equCategorySmall = self.view.viewWithTag(304) as! UIButton
            equCategorySmall.setNewStyle(image: UIImage(named: "test"), title: "", titlePosition: UIViewContentMode.left, additionalSpacing: (KUIScreenWidth-100)*0.5, state: UIControlState.normal)
        case 304:
            smallType = (selectorData[selectIndex]["typeId"]?.description)!
        case 305:
            print(305)
        case 306:
            print(306)
        case 307:
            print(307)
        default:
            print("未知按钮")
//            selectedTypeId = selectorData[selectIndex]["typeId"]?.description
        }
//        getAlarmListData(alarmOrganizationId: selectedEquipmentId, alarmType: selectedTypeId)
    }
    
    @objc func customSelector(sender:UIButton){
        
        for i in 0...4{
            let input = self.view.viewWithTag(400+i) as! UITextField
            input.resignFirstResponder()
        }
        clickedBtnTag = sender.tag
        selectorData = []
        var selectedIndex = 0
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectText = selectBtn.title(for: UIControlState.normal)
        switch clickedBtnTag {
        case 200:
            for i in 0..<self.addDeviceManagementModule.building.count{
                let elementDic:[String:AnyObject] = ["typeName":self.addDeviceManagementModule.building[i].buildName as AnyObject,"typeId":self.addDeviceManagementModule.building[i].id as AnyObject]
                selectorData.append(elementDic)
                if selectText == self.addDeviceManagementModule.building[i].buildName{
                    selectedIndex = i
                }
            }
        case 201:
            if buildingId != ""{
                let tempFloorList = self.addDeviceManagementService.getFloorList(buildId: Int(buildingId)!, allFloorData: addDeviceManagementModule.floor)
                for i in 0..<tempFloorList.count{
                    let elementDic:[String:AnyObject] = ["typeName":tempFloorList[i].floorName as AnyObject,"typeId":tempFloorList[i].id as AnyObject]
                    selectorData.append(elementDic)
                    if selectText == tempFloorList[i].floorName{
                        selectedIndex = i
                    }
                }
            }
            
        case 202:
            if floorId != ""{
                let tempRoomList = self.addDeviceManagementService.getRoomList(floorId: Int(floorId)!, allRoomData: addDeviceManagementModule.room)
                for i in 0..<tempRoomList.count{
                    let elementDic:[String:AnyObject] = ["typeName":tempRoomList[i].roomName as AnyObject,"typeId":tempRoomList[i].id as AnyObject]
                    selectorData.append(elementDic)
                    if selectText == tempRoomList[i].roomName{
                        selectedIndex = i
                    }
                }
            }
            
        case 301:
            for i in 0..<self.addDeviceManagementModule.organizatinoOneList.count{
                let elementDic:[String:AnyObject] = ["typeName":self.addDeviceManagementModule.organizatinoOneList[i].organizationName as AnyObject,"typeId":self.addDeviceManagementModule.organizatinoOneList[i].organizationId as AnyObject]
                selectorData.append(elementDic)
                if selectText == self.addDeviceManagementModule.organizatinoOneList[i].organizationName{
                    selectedIndex = i
                }
            }
        case 302:
            if oneMeanId != ""{
                let tempOrganizationTwoList = addDeviceManagementService.getOrganizationTwoList(organizationOneId: Int(oneMeanId)!, organizationTwoList: addDeviceManagementModule.organizationTwoList)
                for i in 0..<tempOrganizationTwoList.count{
                    let elementDic:[String:AnyObject] = ["typeName":tempOrganizationTwoList[i].organizationName as AnyObject,"typeId":tempOrganizationTwoList[i].organizationId as AnyObject]
                    selectorData.append(elementDic)
                    if selectText == tempOrganizationTwoList[i].organizationName{
                        selectedIndex = i
                    }
                }
            }
            
        case 303:
            for i in 0..<self.addDeviceManagementModule.equCategoryBig.count{
                let elementDic:[String:AnyObject] = ["typeName":self.addDeviceManagementModule.equCategoryBig[i].categoryName as AnyObject,"typeId":self.addDeviceManagementModule.equCategoryBig[i].categoryId as AnyObject]
                selectorData.append(elementDic)
                if selectText == self.addDeviceManagementModule.equCategoryBig[i].categoryName{
                    selectedIndex = i
                }
            }
        case 304:
            if bigType != ""{
                let tempEquCategorySmallList = addDeviceManagementService.getEquCategorySmallList(categoryId: Int(bigType)!, equCategorySmallList: addDeviceManagementModule.equCategorySmall)
                for i in 0..<tempEquCategorySmallList.count{
                    let elementDic:[String:AnyObject] = ["typeName":tempEquCategorySmallList[i].cimName as AnyObject,"typeId":tempEquCategorySmallList[i].cimCode as AnyObject]
                    selectorData.append(elementDic)
                    if selectText == tempEquCategorySmallList[i].cimName{
                        selectedIndex = i
                    }
                }
            }
            
        case 305:
            print(305)
        case 306:
            print(306)
        case 307:
            print(307)
        default:
            print("未知按钮1")
//            for i in self.alarmTypeListData.enumerated(){
//                let elementDic:[String:AnyObject] = ["typeName":self.alarmTypeListData[i.offset]["name"].stringValue as AnyObject,"typeId":self.alarmTypeListData[i.offset]["value"].stringValue as AnyObject]
//                selectorData.append(elementDic)
//                if selectText == self.alarmTypeListData[i.offset]["name"].stringValue{
//                    selectedIndex = i.offset
//                }
//            }
        }
        
        selector.reloadAllComponents()
        selector.selectRow(selectedIndex, inComponent: 0, animated: false)
        selectorView.isHidden = false
        
    }

    @objc func goBackFromDeviceManagementViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func datePicker(_ datePicker: PGDatePicker!, didSelectDate dateComponents: DateComponents!) {
        let tempSelectLabel = self.view.viewWithTag(datePicker.tag) as! UILabel
        tempSelectLabel.text = "\(dateComponents.year!)-\(formateNum(num: dateComponents.month!))-\(formateNum(num: dateComponents.day!))"
//        if datePicker.tag == 500{
//
//            print(dateComponents)
//        }else{
//            let shengChanLabel = self.view.viewWithTag(5000) as! UILabel
//            let anZhuangLabel = self.view.viewWithTag(datePicker.tag) as! UILabel
//            if shengChanLabel.text!.count>0{
//                let shengChanDateList = shengChanLabel.text?.split(separator: "-")
//                let anZhuangDateList = anZhuangLabel.text?.split(separator: "-")
//            }
//        }
        
        
    }
    func formateNum(num:Int) ->String{
        var formateString:String = ""
        if num < 10 {
            formateString = "0\(num)"
        }else{
            formateString = "\(num)"
        }
        return formateString
    }
}

extension AddDeviceManagementViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    //MARK - dataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.selectorData.count == 0 {
            return 0
        }else {
            return selectorData.count
        }
    }
    //MARk - delegate
    //    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    //        <#code#>
    //    }
    //
    //    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    //        <#code#>
    //    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.selectorData.count == 0 {
            return nil
        }else {
            return selectorData[row]["typeName"]?.description
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    //        let typeId = selectorData[row]["typeId"]?.description
    //        print(typeId)
    //    }
    
}

extension AddDeviceManagementViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        /// 如果是小数文本框则执行下面操作，如果是文字文本框 不需要做任何限制
        if textField.tag == 403 {
            
            /// 小数点前可以输入 5位
            let Digits = 5
            if textField.text?.contains(".") == false && string != "" && string != "."{
                if (textField.text?.count)! >= Digits{
                    return false
                }
            }
            
            let scanner = Scanner(string: string)
            let numbers : NSCharacterSet
            let pointRange = (textField.text! as NSString).range(of: ".")
            
            if (pointRange.length > 0) && pointRange.length < range.location || pointRange.location > range.location + range.length {
                numbers = NSCharacterSet(charactersIn: "0123456789.")
            }else{
                numbers = NSCharacterSet(charactersIn: "0123456789.")
            }
            
            if textField.text == "" && string == "." {
                return false
            }
            /// 小数点后3位
            let remain = 3
            
            let tempStr = textField.text!.appending(string)
            
            let strlen = tempStr.count
            
            if pointRange.length > 0 && pointRange.location > 0{//判断输入框内是否含有“.”。
                if string == "." {
                    return false
                }
                
                if strlen > 0 && (strlen - pointRange.location) > remain + 1 {//当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。
                    return false
                }
            }
            
            let zeroRange = (textField.text! as NSString).range(of: "0")
            if zeroRange.length == 1 && zeroRange.location == 0 { //判断输入框第一个字符是否为“0”
                if !(string == "0") && !(string == ".") && textField.text?.count == 1 {//当输入框只有一个字符并且字符为“0”时，再输入不为“0”或者“.”的字符时，则将此输入替换输入框的这唯一字符。
                    textField.text = string
                    return false
                }else {
                    if pointRange.length == 0 && pointRange.location > 0 {//当输入框第一个字符为“0”时，并且没有“.”字符时，如果当此输入的字符为“0”，则视当此输入无效。
                        if string == "0" {
                            return false
                        }
                    }
                }
            }
            //        let buffer : NSString!
            if !scanner.scanCharacters(from: numbers as CharacterSet, into: nil) && string.count != 0 {
                return false
            }
            
        }
        
        return true
    }
}
