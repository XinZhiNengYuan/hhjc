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

class AddDeviceManagementViewController: UIViewController,PGDatePickerDelegate,AVCapturePhotoCaptureDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let cameraViewService = CameraViewService()
    var photoListr : [UIImage] = []
    let contentView : UIView = UIView()
    var selectorView:UIView = UIView()
    var selector:UIPickerView = UIPickerView()
    var clickedBtnTag:Int!
    var equId = -1
    var selectorData:[[String:AnyObject]] = []
    var imageView = UIView()
    var addBut : UIButton!
    var mView = UIView()
    let addDeviceManagementService = AddDeviceManagementService()
    override func viewDidLoad() {
        super.viewDidLoad()
        getOneAndTwo()
        setLayout()
        // Do any additional setup after loading the view.
    }
    
    func getOneAndTwo(){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentAndOrganization","user_id": userId as Any,"token": token as Any,"info":""]
        addDeviceManagementService.getEquipmentAndOrganization(contentData: contentData, finished: {(returnData) in
            print("--------------------------------")
        }, finishedError: {(errorData) in
            print("--------------------------------")
        })
    }
   
    func setLayout(){
        self.title = "新增设备"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromDeviceManagementViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadImgs))
        contentView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height+(navigationController?.navigationBar.frame.size.height)!, width: KUIScreenWidth, height: KUIScreenHeight-UIApplication.shared.statusBarFrame.height-(navigationController?.navigationBar.frame.size.height)!)
        contentView.backgroundColor = UIColor.white
        
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
        //一级单位
        setContentOfSelectedListRow(top: 40, optionMode: contentViewHeader, text: "一级单位", selectTitle: "消防", tag: 301)
        //二级单位
        setContentOfSelectedListRow(top: 81, optionMode: contentViewHeader, text: "二级单位", selectTitle: "消防护卫部消防大队1246号消防车", tag: 302)
        contentView.addSubview(contentViewHeader)
        
//        设备基本信息
        let contentForMode = UIView(frame: CGRect(x: 0, y: 121, width: contentView.frame.width, height: KUIScreenHeight-121))
        let contentForModeHeader = UIView(frame: CGRect(x: 0, y: 0, width: contentForMode.frame.width, height: 40))
        contentForMode.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        let contentForModeHeaderLeftStyle = UILabel(frame: CGRect(x: 10, y: 10, width: 5, height: 20))
        contentForModeHeaderLeftStyle.backgroundColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        contentForModeHeader.addSubview(contentForModeHeaderLeftStyle)
        let contentForModeHeaderContentLabel = UILabel(frame: CGRect(x: 20, y: 10, width: contentForModeHeader.frame.width-20, height: 20))
        contentForModeHeaderContentLabel.text = "设备基本信息"
        contentForModeHeader.addSubview(contentForModeHeaderContentLabel)
        contentForMode.addSubview(contentForModeHeader)
        //设备大类
        setContentOfSelectedListRow(top: 40, optionMode: contentForMode, text: "设备大类",selectTitle: "", tag: 303)
        //设备小类
        setContentOfSelectedListRow(top: 81, optionMode: contentForMode, text: "设备小类",selectTitle: "", tag: 304)
        
        //设备标识
        setContentModeOptionOfInputView(top: 122, contentForMode: contentForMode, text: "设备标识",tag:400)
        //设备名称
        setContentModeOptionOfInputView(top: 163, contentForMode: contentForMode, text: "设备名称",tag:401)
        //设备型号
        setContentModeOptionOfInputView(top: 204, contentForMode: contentForMode, text: "设备型号",tag:402)
        //额定功率
        setContentModeOptionOfInputView(top: 245, contentForMode: contentForMode, text: "额定功率",tag:403)
        //供应商
        setContentModeOptionOfInputView(top: 286, contentForMode: contentForMode, text: "供应商",tag:404)
        //生产日期
        setDateView(top: 327, contentForMode: contentForMode, text: "生产日期", tag: 500)
        //安装日期
        setDateView(top: 368, contentForMode: contentForMode, text: "安装日期", tag: 600)
        //数据绑定
        setSelectView(top: 409, contentForMode: contentForMode, text: "数据是否绑定", tag: 700)
        //是否有效
        setSelectView(top: 470, contentForMode: contentForMode, text: "是否有效", tag: 800)
        //图片上传
        setPicView(top: 520, contentForMode: contentForMode, tag: 900)
        
        contentView.addSubview(contentForMode)
        
        
        ///选择弹出框
        selectorView.frame = CGRect(x: 0, y: KUIScreenHeight-64-240, width: KUIScreenWidth, height: 240)
        selectorView.isHidden = true
        contentView.addSubview(selectorView)
        view.addSubview(contentView)
        
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
        contentForModeName2.font = UIFont.boldSystemFont(ofSize: 14)
        contentForModeRow2.addSubview(contentForModeName2)
        
        let contentForModeTwoMean = UIButton()
        contentForModeTwoMean.frame = CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30)
        contentForModeTwoMean.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        contentForModeTwoMean.setNewStyle(image: UIImage(named: "下拉"), title: selectTitle, titlePosition: UIViewContentMode.left, additionalSpacing: (KUIScreenWidth-100)*0.5, state: UIControlState.normal)
        contentForModeTwoMean.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        contentForModeTwoMean.layer.borderWidth = 1
        contentForModeTwoMean.tag = tag
        contentForModeTwoMean.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        contentForModeRow2.addSubview(contentForModeTwoMean)
        
        optionMode.addSubview(contentForModeRow2)
    }
    
    //设置有输入框的所在的行
    func setContentModeOptionOfInputView(top:Int,contentForMode:UIView,text:String,tag:Int){
        let contentForModeRow3 = UIView(frame: CGRect(x: 0, y: top, width: Int(contentForMode.frame.width), height: 40))
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
        input.frame = CGRect(x: 10, y: 0, width: KUIScreenWidth - 140, height: 30)
        input.adjustsFontSizeToFitWidth=true  //当文字超出文本框宽度时，自动调整文字大小
        input.minimumFontSize=11  //最小可缩小的字号
        /** 水平对齐 **/
        input.textAlignment = .left
        /** 垂直对齐 **/
        input.contentVerticalAlignment = .center
        input.clearButtonMode = .whileEditing  //编辑时出现清除按钮
        //textField.clearButtonMode = .unlessEditing  //编辑时不出现，编辑后才出现清除按钮
        //textNameField.clearButtonMode = .always  //一直显示清除按钮
        input.keyboardType = UIKeyboardType.default
        //textNameField.becomeFirstResponder()
        input.font = UIFont.boldSystemFont(ofSize: 15)
        input.tag = tag
        input.returnKeyType = UIReturnKeyType.next
        inputView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        inputView.layer.borderWidth = 1
        inputView.addSubview(input)
        contentForModeRow3.addSubview(inputView)
        contentForMode.addSubview(contentForModeRow3)
        
    }
    //带日期控件的view
    func setDateView(top:Int,contentForMode:UIView,text:String,tag:Int){
        let inProducedDateLabel:UILabel = UILabel()
        let contentForModeRow3 = UIView(frame: CGRect(x: 0, y: top, width: Int(contentForMode.frame.width), height: 40))
        contentForModeRow3.backgroundColor = UIColor.white
        let contentForModeLeftStar3 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        if tag == 500{
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
        
        let dateChangeView = UIView(frame: CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30))
        //日期插件
        inProducedDateLabel.frame = CGRect(x: 10, y: 0, width: 90, height: 30)
        inProducedDateLabel.textAlignment = .left
        inProducedDateLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        inProducedDateLabel.tag = tag
        let currentMonth = NSDate()
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM-dd"
        inProducedDateLabel.text = dateFormater.string(from: currentMonth as Date) as String
        dateChangeView.addSubview(inProducedDateLabel)
        dateChangeView.layer.borderWidth = 1
        dateChangeView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        
        let dateBtn = UIButton.init(frame: CGRect(x: dateChangeView.frame.width-40, y: 5, width: 20, height: 20))
        dateBtn.setImage(UIImage(named: "日期"), for: UIControlState.normal)
        dateBtn.tag = tag+1
        dateBtn.addTarget(self, action: #selector(opendatePicker), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(dateBtn)
        contentForModeRow3.addSubview(dateChangeView)
        contentForMode.addSubview(contentForModeRow3)
    }
    
    func setSelectView(top:Int,contentForMode:UIView,text:String,tag:Int){
        let contentForModeRow3 = UIView()
        let rightView = UIView(frame: CGRect(x: 130, y: 5, width: KUIScreenWidth - 160, height: 30))
        let rightViewOfButtom = UIView(frame: CGRect(x: 0, y: 30, width: rightView.frame.width, height: 30))
        let rightViewOfLabel = UILabel()
        
        //判断是“数据绑定”还是“是否有效”
        if tag == 800{
            contentForModeRow3.frame = CGRect(x: 0, y: top, width: Int(contentForMode.frame.width), height: 40)
            rightViewOfLabel.frame = CGRect(x: 0, y: 0, width: rightViewOfButtom.frame.width, height: 30)
            rightViewOfLabel.text = ""
        }else{
            contentForModeRow3.frame = CGRect(x: 0, y: top, width: Int(contentForMode.frame.width), height: 60)
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
        
        falseBtn.addTarget(self, action: #selector(selectAction), for: UIControlEvents.touchUpInside)
        falseBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        rightViewOfTop.addSubview(trueBtn)
        rightViewOfTop.addSubview(falseBtn)
        
        
        
        
        //        let trueLabel = UILabel(frame: CGRect(x: 35, y: 5, width: 20, height: 20))
        rightView.addSubview(rightViewOfButtom)
        rightView.addSubview(rightViewOfTop)
        contentForModeRow3.addSubview(rightView)
        contentForMode.addSubview(contentForModeRow3)
    }
    
    @objc func selectAction(btn:UIButton){
        
        if btn.tag >= 800{//是判断是否有效的按钮
            if btn.tag == 800{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag+1) as! UIButton
                actionSelectTrueBtn.set(image: UIImage(named: "选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "未选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }else{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag-1) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag) as! UIButton
                actionSelectTrueBtn.set(image: UIImage(named: "未选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }
        }else{//是判断是否绑定的按钮
            if btn.tag == 700{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag+1) as! UIButton
                actionSelectTrueBtn.set(image: UIImage(named: "选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "未选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }else{
                let actionSelectTrueBtn = self.view.viewWithTag(btn.tag-1) as! UIButton
                let actionSelectFalseBtn = self.view.viewWithTag(btn.tag) as! UIButton
                actionSelectTrueBtn.set(image: UIImage(named: "未选中"), title: "是", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
                actionSelectFalseBtn.set(image: UIImage(named: "选中"), title: "否", titlePosition: UIViewContentMode.right, additionalSpacing: 30, state: UIControlState.normal)
            }
        }
    }
    @objc func uploadImgs(){
        if photoListr.count > 0{
            cameraViewService.upLoadPic(images: photoListr, finished: { (fileId) in
                let userId = userDefault.string(forKey: "userId")
                let token = userDefault.string(forKey: "userToken")
                let contentData : [String:Any] = ["method":"equipmentedit","user_id": userId as Any,"token": token as Any,"info":["equ_id":self.equId,"files_id":fileId]]
                self.cameraViewService.picIdAndEquId(contentData: contentData, successCall: {
                    self.present(windowAlert(msges: "上传成功"), animated: true, completion: nil)
                }, errorCall: {
                    self.present(windowAlert(msges: "上传失败，请重新上传"), animated: true, completion: nil)
                })
            }) {
                print("错误")
            }
        }
        
    }
    
    func setPicView(top:Int,contentForMode:UIView,tag:Int) {
        mView.frame = CGRect(x: 0, y: top, width: Int(KUIScreenWidth), height: 90)
        mView.backgroundColor = UIColor.white
        imageView.frame = CGRect(x: 10, y: 10, width: Int(KUIScreenWidth-20), height: 70)
        imageView.backgroundColor = UIColor.white
        imageView.tag = tag
        mView.addSubview(imageView)
        contentForMode.addSubview(mView)
        imageMethods()
    }
    func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[String:Any]){
        let imagePickerc = info[UIImagePickerControllerOriginalImage] as!UIImage
        //添加图片
        addPic(pic : imagePickerc)
        self.dismiss(animated:true,completion:nil)
    }
    
    func imageMethods(){
        for i in 0..<photoListr.count{
            let viewOption = UIView()
            viewOption.frame = CGRect(x: 75*i+10, y: 0, width: 60, height: Int(imageView.frame.height))
            let image = UIImageView()
            image.tag = i+1000 // 图片
            image.frame = CGRect(x: 0, y: 10, width: 60, height: Int(imageView.frame.height)-10)
            image.image = photoListr[i]
            viewOption.addSubview(image)
            let deleteBut = deleteBtn(tag: i + 6000)
            viewOption.addSubview(deleteBut)
            imageView.addSubview(viewOption)
        }
        if photoListr.count >= 3{
            //            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
        
    }
    
    func addPic(pic : UIImage){
        let addBtn = imageView.viewWithTag(3001) as! UIButton
        addBtn.removeTarget(self, action: #selector(actionSheet), for: .touchUpInside)
        addBtn.removeFromSuperview()
        let viewOption = UIView()
        viewOption.tag = 4000+photoListr.count // 图片所在图层
        viewOption.frame = CGRect(x: 75*photoListr.count, y: 0, width: 60, height: Int(imageView.frame.height))
        let image = UIImageView()
        image.image = UIImage(named: "image")
        image.tag = photoListr.count + 1000 //图片
        image.frame = CGRect(x: 0, y: 10, width: 60, height: Int(imageView.frame.height)-10)
        image.image = pic
        viewOption.addSubview(image)
        let deleteBut = deleteBtn(tag: photoListr.count + 6000)
        viewOption.addSubview(deleteBut)
        imageView.addSubview(viewOption)
        photoListr.append(pic)
        if photoListr.count >= 3{
            addBut.removeFromSuperview()
        }else{
            setAddBut()
        }
    }
    
    //MARK:设置设置添加按钮
    func setAddBut(){
        addBut = UIButton(frame: CGRect(x: 75*photoListr.count+10, y: 10, width: 40, height: 40))
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
        let datePickerManager = PGDatePickManager.init()
        datePickerManager.isShadeBackgroud = true
        datePickerManager.style = .style3
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
    //下拉菜单列表
    @objc func doneButtonAction(){
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectIndex = selector.selectedRow(inComponent: 0)
        let selectText = selectorData[selectIndex]["typeName"]?.description
        selectBtn.setNewStyle(image: UIImage(named: "下拉"), title: selectText!, titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        
        selectorView.isHidden = true
        
        switch clickedBtnTag {
        case 301:
            print(301)
//            selectedEquipmentId = selectorData[selectIndex]["typeId"]?.description
        case 302:
            print(302)
        default:
            print("未知按钮")
//            selectedTypeId = selectorData[selectIndex]["typeId"]?.description
        }
//        getAlarmListData(alarmOrganizationId: selectedEquipmentId, alarmType: selectedTypeId)
    }
    
    @objc func customSelector(sender:UIButton){
        clickedBtnTag = sender.tag
        selectorData = []
        var selectedIndex = 0
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectText = selectBtn.title(for: UIControlState.normal)
        switch clickedBtnTag {
        case 301:
            print(301)
//            for i in self.alarmEquipmentListData.enumerated(){
//                let elementDic:[String:AnyObject] = ["typeName":self.alarmEquipmentListData[i.offset]["text"].stringValue as AnyObject,"typeId":self.alarmEquipmentListData[i.offset]["id"].stringValue as AnyObject]
//                selectorData.append(elementDic)
//                if selectText == self.alarmEquipmentListData[i.offset]["text"].stringValue{
//                    selectedIndex = i.offset
//                }
//            }
        case 302:
            print(302)
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
///带图标，文字的按钮
extension UIButton {
    func setNewStyle(image anImage: UIImage?, title: String, titlePosition: UIViewContentMode, additionalSpacing: CGFloat, state: UIControlState){
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)
        positionLabelRespectToImage(title:title, position: titlePosition, spacing: additionalSpacing);
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
        
    }
    private func positionLabelRespectToImage(title: String, position: UIViewContentMode, spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedStringKey.font: titleFont!])
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width), bottom: imageSize.height+spacing, right: 0)
            imageInsets = UIEdgeInsets(top: titleSize.height+spacing, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + spacing), left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: titleSize.height+spacing, right: -titleSize.width)
        case .left:
            //当文本内容过长时进行处理
            let titleWidth = title.size(withAttributes: [NSAttributedStringKey.font: titleFont!]).width > KUIScreenWidth/2-imageSize.width-spacing ? kScreenWidth/2-imageSize.width-spacing : title.size(withAttributes: [NSAttributedStringKey.font: titleFont!]).width
            
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width), bottom: 0, right: imageSize.width+spacing)
            imageInsets = UIEdgeInsets(top: 0, left: titleWidth+spacing, bottom: 0, right: titleWidth)
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        }
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
        
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
