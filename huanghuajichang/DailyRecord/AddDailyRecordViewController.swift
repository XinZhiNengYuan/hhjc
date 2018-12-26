//
//  AddDailyRecordViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/23.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Photos
import Kingfisher

class AddDailyRecordViewController: AddNavViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    var pageType:String!
    var rightSaveBtn:UIBarButtonItem!
    
    var titleView:UIView!
    var titleTextField:UITextField!
    var pickerView:UIView!
    var describeTextView:UITextView!
    var imgsView:UIView!
    ///按钮数组
    var imagsData:NSMutableArray! = []
    ///有图片的数组
    var haveImagsData:NSMutableArray! = []
    ///上传的图片数组
    var postImagesData:NSMutableArray! = []
    ///id数组
    var fieldsData:NSMutableArray! = []
    var fieldsStr:String!
    ///浏览图片数组
    var pictureData:[Any] = []
    ///原来的对象，新增UIimage数组集合
    var allImageData:[Any] = []
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var editItemId:String!
    var editJson:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:(UIFont(name: "PingFangSC-Regular", size: 18))!]
        self.view.backgroundColor = allListBackColor
        
        rightSaveBtn = UIBarButtonItem.init(title: "保存", style: UIBarButtonItemStyle.done, target: self, action: #selector(uploadImgs))
        rightSaveBtn.isEnabled = true
        rightSaveBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightSaveBtn
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        createUI()
        
        if pageType == "edit" {
            self.title = "编辑记录"
            editItemId = self.userDefault.object(forKey: "recordId") as? String
            
            editGetDetailData()
        }else{
            self.title = "新增记录"
        }
        // Do any additional setup after loading the view.
        
    }
    
    ///编辑页面时，获取详情
    func editGetDetailData(){
        let titleView = self.view.viewWithTag(100)
        let titleTF = titleView?.viewWithTag(200) as! UITextField
        let timeView = self.view.viewWithTag(101)
        let timeTF = timeView?.viewWithTag(201) as! UITextField
        MyProgressHUD.showStatusInfo("加载中...")
        let infoData = ["id":editItemId]
        let contentData : [String : Any] = ["method":"getOptionById","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
//            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.editJson = JSON(value)["data"]
//                    self.createDetailContent()
                    titleTF.text = self.editJson["title"].stringValue
                    timeTF.text = AddDailyRecordViewController.timeStampToString(timeStamp: self.editJson["opeTime"].stringValue, timeAccurate: "minute")
                    self.describeTextView.text = self.editJson["describe"].stringValue
//                    print(self.editJson["filePhotos"].arrayValue)
                    self.imagsData = []
                    self.haveImagsData = []
                    self.pictureData = []
                    self.fieldsData = []
                    self.allImageData = []
                    if self.editJson["filePhotos"].arrayValue != [] {
                        for editImage in self.editJson["filePhotos"].enumerated(){
                            let editImgBtn = EditBtn.init(frame: CGRect(x: CGFloat(editImage.offset*(75+15)+10), y: 15, width: 75, height: 75))
                            let imgurlStr = "http://" + self.userDefault.string(forKey: "AppUrlAndPort")! + (self.editJson["filePhotos"][editImage.offset]["filePath"].stringValue)
                            let imgUrl = NSURL.init(string: imgurlStr)
                            
                            editImgBtn.kf.setImage(with: ImageResource(downloadURL: imgUrl! as URL), for: .normal, placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil){ (kfimage, kfError, kfcacheType, kfUrl) in
                                
                            }
                            editImgBtn.layer.borderWidth = 1
                            editImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
                            editImgBtn.addTarget(self, action: #selector(self.openimg), for: UIControlEvents.touchUpInside)
                            editImgBtn.tag = 1001 + editImage.offset
                            self.imgsView.addSubview(editImgBtn)
                            self.imagsData.add(editImgBtn)
                            self.pictureData.append(imgUrl as Any)
                            //加入旧图片对象
                            self.allImageData.append(self.editJson["filePhotos"][editImage.offset])
                            
                            let deleteBtn = UIButton.init(frame: CGRect(x: 66, y: -9, width: 18, height: 18))
                            deleteBtn.setImage(UIImage(named: "删除"), for: UIControlState.normal)
                            deleteBtn.tag = 2001 + editImage.offset
                            deleteBtn.addTarget(self, action: #selector(self.deleteImgBtn(sender:)), for: UIControlEvents.touchUpInside)
                            editImgBtn.addSubview(deleteBtn)
                            editImgBtn.bringSubview(toFront: deleteBtn)
                            self.haveImagsData.add(editImgBtn)
                        }
                        if self.editJson["filePhotos"].arrayValue.count < 3 {
                            self.drawImgBtn(imgBtnIndex: self.editJson["filePhotos"].arrayValue.count + 1)
                        }
                    }else{
                        self.drawImgBtn(imgBtnIndex: 1)
                    }
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
//                    print(type(of: JSON(value)["msg"]))
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    @objc func openimg(sender:UIButton){
        ///index为当前点击了图片数组中的第几张图片,Urls为图片Url地址数组
        //**Urls必须传入为https或者http的图片地址数组,**
        var index = 0
        for img in imagsData.enumerated(){
            if (imagsData[img.offset] as! UIButton).tag == sender.tag{
                index = img.offset
            }
        }
        let vc = PictureVisitControl(index: index, images: pictureData)
        present(vc, animated: true, completion:  nil)
    }
    
    ///上传图片
    @objc func uploadImgs() {
        var editOrAdd = "新增"
        if pageType == "edit"{
            editOrAdd = "修改"
        }
        let titleView = self.view.viewWithTag(100)
        let titleTF = titleView?.viewWithTag(200) as! UITextField
        if titleTF.text == ""{
            self.present(windowAlert(msges: "标题不得为空"), animated: true, completion: nil)
        }else{
            self.fieldsData = []
            self.postImagesData = []
            //生成上传数组
            for pictureItem in allImageData.enumerated(){
                if allImageData[pictureItem.offset] as? UIImage != nil {//新图片
                    postImagesData.append(allImageData[pictureItem.offset])
                }else{
                    self.fieldsData.add((allImageData[pictureItem.offset] as! JSON)["fileId"])
                }
            }
            MyProgressHUD.showStatusInfo("\(editOrAdd)中...")
            NetworkTools.upload(urlString: "http", params: nil , images: postImagesData as! [UIImage], success: { (successBack) in
                print(successBack ?? "default value")
                
                if JSON(successBack!)["status"].stringValue == "success"{
                    //关闭页面，通知列表刷新
                    let successData = JSON(successBack!)["data"]
                    for i in successData.enumerated(){
                        self.fieldsData.add(successData[i.offset]["fileId"])
                    }
                    self.fieldsStr = self.fieldsData?.componentsJoined(by: ",")
                    if self.pageType == "edit"{
                        self.editPost()
                    }else{
                        self.addPost()
                    }
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(successBack!)["msg"].string == nil {
                        self.present(windowAlert(msges: "\(editOrAdd)失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(successBack!)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            }) { (ErrorBack) in
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "\(editOrAdd)请求失败"), animated: true, completion: nil)
                print("error:\(ErrorBack)")
                return
            }
        }
    }
    
    ///新增日常记录
    func addPost(){
        print("执行新增操作")
        let titleView = self.view.viewWithTag(100)
        let titleTF = titleView?.viewWithTag(200) as! UITextField
        let timeView = self.view.viewWithTag(101)
        let timeTF = timeView?.viewWithTag(201) as! UITextField
        let infoData = ["title":titleTF.text ?? "", "desc":describeTextView.text, "user_id":userId, "opeTime":timeTF.text ?? "", "fileIds":fieldsStr] as [String : Any]
        let contentData : [String : Any] = ["method":"addOption","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //关闭页面，通知列表刷新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateList"), object: nil)
                    MyProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "新增失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "新增请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///编辑日常记录
    func editPost(){
        print("执行编辑操作")
        let titleView = self.view.viewWithTag(100)
        let titleTF = titleView?.viewWithTag(200) as! UITextField
        let timeView = self.view.viewWithTag(101)
        let timeTF = timeView?.viewWithTag(201) as! UITextField
        let infoData = ["title":titleTF.text ?? "", "desc":describeTextView.text, "user_id":userId, "id":editItemId, "opeTime":timeTF.text ?? "", "fileIds":fieldsStr] as [String : Any]
        let contentData : [String : Any] = ["method":"updateOption","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //关闭页面，通知列表刷新
                    MyProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: false)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDetail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateList"), object: nil)
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "修改失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "修改请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    func createUI(){
        for i in 0...1{
            titleView = UIView.init(frame: CGRect(x: 0, y: CGFloat(i*50), width: kScreenWidth, height: 40))
            titleView.backgroundColor = UIColor.white
            titleView.tag = 100+i
            self.view.addSubview(titleView)
            
            let titleLabel = UILabel.init(frame: CGRect(x: 20, y: 5, width: 35, height: 30))
            titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
            titleLabel.textColor = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1)
            titleView.addSubview(titleLabel)
            
            titleTextField = UITextField.init(frame: CGRect(x: 60, y: 5, width: kScreenWidth-60-10, height: 30))
            titleTextField.textColor = allFontColor
            titleTextField.delegate = self
            titleTextField.tag = 200+i
            titleView.addSubview(titleTextField)
            
            if i == 0 {
                titleLabel.text = "标题:"
                titleTextField.autocapitalizationType = UITextAutocapitalizationType.none//关闭首字母大写
                NotificationCenter.default.addObserver(self, selector: #selector(self.textFiledEditChanged(obj:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
                let mustImg = UIImageView(frame: CGRect(x: 10, y: 17, width: 6, height: 6))
                mustImg.image = UIImage(named: "必填项")
                titleView.addSubview(mustImg)
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
                datePicker.datePickerMode = .dateAndTime
                //        datePicker.setDate(NSDate., animated: da)
                datePicker.locale = Locale.init(identifier: "zh_CN")
                datePicker.calendar = Calendar.current
                datePicker.timeZone = TimeZone.current
                datePicker.maximumDate = NSDate() as Date
                datePicker.tag = 1001
                pickerView.addSubview(datePicker)
                cancelBtn.addTarget(self, action: #selector(closePick), for: UIControlEvents.touchUpInside)
                okBtn.addTarget(self, action: #selector(getDate), for: UIControlEvents.touchUpInside)
                titleTextField.inputView = pickerView
                if self.pageType != "edit"{
                    let date = NSDate()
                    let dfmatter = DateFormatter()
                    dfmatter.dateFormat="yyyy/MM/dd HH:mm"
                    titleTextField.text = dfmatter.string(from: date as Date)
                }
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
        describeTextView.font = UIFont.init(name: "PingFangSC-Regular", size: 15)
        describeTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textViewEditChanged(sender:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
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
        //新增页面
        if pageType != "edit" {
            drawImgBtn(imgBtnIndex: 1)
        } 
    }
    
    func drawImgBtn(imgBtnIndex:Int){
        let addImgBtn = EditBtn.init(frame: CGRect(x: CGFloat((imgBtnIndex-1)*(75+15)+10), y: 15, width: 75, height: 75))
        addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
        addImgBtn.layer.borderWidth = 1
        addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
        addImgBtn.tag = imgBtnIndex + 1000
        addImgBtn.addTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
        imgsView.addSubview(addImgBtn)
        imagsData.add(addImgBtn)
    }
    
    @objc func textFiledEditChanged(obj:Notification){
        let textField = obj.object as! UITextField
        let toBeString = textField.text
        let lang = UIApplication.shared.textInputMode?.primaryLanguage! //键盘输入模式
        if (lang!.elementsEqual("zh_Hans")){
            let selectedRange:UITextRange = (textField.markedTextRange)!
            let position = textField.position(from: selectedRange.start, offset: 0)
            if (position == nil) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if (toBeString! as NSString).length > 30 {
                    textField.text = (toBeString! as NSString).substring(to: 30)
                    self.present(windowAlert(msges: "最大输入字数为30"), animated: true, completion: nil)
                }
            }else{
                
            }
            
        }else{// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString! as NSString).length > 30 {
                self.present(windowAlert(msges: "最大输入字数为30"), animated: true, completion: nil)
                textField.text = (toBeString! as NSString).substring(to: 30)
            }
        }
        
    }
    
    @objc func textViewEditChanged(sender:NSNotification) {
        let textVStr = describeTextView.text as NSString
        if (textVStr.length > 500) {
            let str = textVStr.substring(to: 500)
            describeTextView.text = str
            self.present(windowAlert(msges: "最大输入字数为500"), animated: true, completion: nil)
        }
    }
    
    ///时间戳转字符串
    static func timeStampToString(timeStamp:String,timeAccurate:String)->String {
        if (timeStamp as NSString).intValue < 0{
            return ""
        }
        let timeNormal = Int(timeStamp)!/1000
        let string = NSString(string: timeNormal.description)
        
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        switch timeAccurate {
        case "hour":
            dfmatter.dateFormat="yyyy/MM/dd HH"
        case "minute":
            dfmatter.dateFormat="yyyy/MM/dd HH:mm"
        case "second":
            dfmatter.dateFormat="yyyy/MM/dd HH:mm:ss"
        default:
            dfmatter.dateFormat="yyyy/MM/dd"
        }
        
        let date = NSDate(timeIntervalSince1970: timeSta)
        
//        print(dfmatter.string(from: date as Date))
        return dfmatter.string(from: date as Date)
    }
    
    @objc func doneButtonAction() {
        describeTextView.resignFirstResponder()
    }
    
    ///关闭自定义日期选择器
    @objc func closePick(){
        let dateTextField = titleView.viewWithTag(201) as! UITextField
        dateTextField.resignFirstResponder()
    }
    
    /// MARK: - 日期选择器选择处理方法
    @objc func getDate() {
        let datePicker = pickerView.viewWithTag(1001) as! UIDatePicker
        datePicker.datePickerMode = .dateAndTime
        let formatter = DateFormatter()
        let date = datePicker.date
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateStr = formatter.string(from: date)
        let dateTextField = titleView.viewWithTag(201) as! UITextField
        dateTextField.text = dateStr
        dateTextField.resignFirstResponder()
    }
    
    @objc func addImgBtn (sender:UIButton) {
        openSelector()
    }
    
    @objc func deleteImgBtn(sender:UIButton){
        let index = sender.tag - 2000
        let changeStartIndex = index + 1001
        let endIndex = imagsData.count + 1000
        //1.首先移除自身所在图片按钮
        let superBtn = imgsView.viewWithTag(index + 1000) as! UIButton
        pictureData.remove(at: index-1)
        allImageData.remove(at: index-1)
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
            let addImgBtn = EditBtn.init(frame: CGRect(x: CGFloat(85+90+15), y: 15, width: 75, height: 75))
            addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
            addImgBtn.layer.borderWidth = 1
            addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
            addImgBtn.tag = imagsData.count + 1001
            addImgBtn.addTarget(self, action: #selector(addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
            imgsView.addSubview(addImgBtn)
            imagsData.add(addImgBtn)
        }
    }
    
    @objc func openSelector(){
        let actionSheet = UIAlertController.init(title: "请选择", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        // 命令（样式：退出Cancel，警告Destructive-按钮标题为红色，默认Default）
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler:{
            action in
            print("关闭")
        })
        let deleteAction = UIAlertAction(title: "拍摄照片", style: UIAlertActionStyle.default, handler: {
            action in
            print("拍摄照片")
            if self.cameraPermission() == true {
                self.cameraEvent()
            }else{
                self.gotoSetting()
            }
            
        })
        let archiveAction = UIAlertAction(title: "本地相册", style: UIAlertActionStyle.default, handler: {
            action in
            print("本地相册")
            if self.PhotoLibraryPermission() == true{
                self.photoEvent()
            }else{
                self.gotoSetting()
            }
        })
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(archiveAction)
        self.present(actionSheet, animated: false, completion: nil)
    }
    /*
     判断相机是否有权限
     return:有权限返回true，无权限返回false
     */
    func cameraPermission() -> Bool{
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted){
            return false
        }else{
            return true
        }
    }
    
    func cameraEvent(){
        let pickerCamera = UIImagePickerController()
        pickerCamera.sourceType = .camera
        pickerCamera.allowsEditing = true
        pickerCamera.delegate = self
        self.present(pickerCamera, animated: true, completion: nil)
    }
    
    /*
     判断相册是否有权限
     return:有权限返回true，无权限返回false
     */
    func PhotoLibraryPermission() -> Bool{
        let libraryStatus:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if (libraryStatus == PHAuthorizationStatus.denied || libraryStatus == PHAuthorizationStatus.restricted){
            return false
        }else{
            return true
        }
    }
    
    func photoEvent(){
        
        let pickerPhoto = UIImagePickerController()
        pickerPhoto.sourceType = .photoLibrary
        pickerPhoto.allowsEditing = true
        pickerPhoto.delegate = self
        self.present(pickerPhoto, animated: true, completion: nil)
        
    }
    
    //去设置权限
    
    func gotoSetting(){
        
        let alertController:UIAlertController=UIAlertController.init(title: "去设置", message: "设置-》通用-》", preferredStyle: UIAlertControllerStyle.alert)
        let sure:UIAlertAction=UIAlertAction.init(title: "去开启权限", style: UIAlertActionStyle.default) { (ac) in
            
            let url=URL.init(string: UIApplicationOpenSettingsURLString)
            
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: { (ist) in
                    
                })
            }
            
        }
        
        alertController.addAction(sure)
        
        self.present(alertController, animated: true) {
            
        }
        
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) {
            var img:UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
            if picker.allowsEditing {
                img = info[UIImagePickerControllerEditedImage] as? UIImage
            }
            
            //对按钮自身进行操作
            let currentBtn = self.imagsData.lastObject as! UIButton
            currentBtn.setImage(img, for: UIControlState.normal)
            //从相册选的图片，或拍照的图片直接压缩
            let data = UIImageJPEGRepresentation(img!,0.5)
            img = UIImage.init(data: data!)
           /* //修正图片的位置
//            let image = self.fixOrientation((info[UIImagePickerControllerOriginalImage] as! UIImage))
            //先把图片转成NSData
            let data = UIImageJPEGRepresentation(img!, 0.5)
            //图片保存的路径
            //这里将图片放在沙盒的documents文件夹中
            
            //Home目录
            let homeDirectory = NSHomeDirectory()
            let documentPath = homeDirectory + "/Documents"
            //文件管理器
            let fileManager: FileManager = FileManager.default
            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            do {
                try fileManager.createDirectory(atPath: documentPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error {
                print(error)
            }
            fileManager.createFile(atPath: documentPath.appendingFormat("/image.png"), contents: data, attributes: nil)
            //得到选择后沙盒中图片的完整路径
            let filePath: String = String(format: "%@%@", documentPath, "/image.png")
            print("filePath:" + filePath)
             */
            
            self.pictureData.append(img! as Any)
            self.allImageData.append(img! as Any)
            
            let index = currentBtn.tag - 1000
            let deleteBtn = UIButton.init(frame: CGRect(x: 66, y: -9, width: 18, height: 18))
            deleteBtn.setImage(UIImage(named: "删除"), for: UIControlState.normal)
            deleteBtn.tag = 2000+index
            deleteBtn.addTarget(self, action: #selector(self.deleteImgBtn(sender:)), for: UIControlEvents.touchUpInside)
            currentBtn.addSubview(deleteBtn)
            currentBtn.removeTarget(self, action: #selector(self.addImgBtn(sender:)), for: UIControlEvents.allEvents)
            currentBtn.addTarget(self, action: #selector(self.openimg), for: UIControlEvents.touchUpInside)
            self.haveImagsData.add(currentBtn)
            if index == 3{
                return
            }
            //新增的按钮
            let addImgBtn = EditBtn.init(frame: CGRect(x: CGFloat(index*(75+15)+10), y: 15, width: 75, height: 75))
            addImgBtn.setImage(UIImage(named: "添加照片"), for: UIControlState.normal)
            addImgBtn.layer.borderWidth = 1
            addImgBtn.layer.borderColor = UIColor(red: 154/255, green: 186/255, blue: 216/255, alpha: 1).cgColor
            addImgBtn.tag = index + 1001
            addImgBtn.addTarget(self, action: #selector(self.addImgBtn(sender:)), for: UIControlEvents.touchUpInside)
            self.imgsView.addSubview(addImgBtn)
            self.imagsData.add(addImgBtn)
//            self.largeHeaderView.image = img
            //将img转为data
            //            let imageData = UIImagePNGRepresentation(img)
        }
        
    }
    
    //点击系统自定义取消按钮的回调
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
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
        let titleTextField = self.view.viewWithTag(100)?.viewWithTag(200) as! UITextField
        titleTextField.resignFirstResponder()
        let dateTextField = self.view.viewWithTag(101)?.viewWithTag(201) as! UITextField
        dateTextField.resignFirstResponder()
        describeTextView.resignFirstResponder()
        //present出的页面用dismiss不然会找不到上一页
        if pageType == "edit"{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
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
