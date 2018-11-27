//
//  ViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/11/27.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class AddDeviceManagementViewController: UIViewController {

    let contentView : UIView = UIView()
    var selectorView:UIView = UIView()
    var selector:UIPickerView = UIPickerView()
    var clickedBtnTag:Int!
    var selectorData:[[String:AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        // Do any additional setup after loading the view.
    }
    
    
   
    func setLayout(){
        self.title = "新增设备"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromDeviceManagementViewController))
        
        contentView.frame = CGRect(x: 0, y: 0, width: KUIScreenWidth, height: KUIScreenHeight)
        contentView.backgroundColor = UIColor.white
        
//       单位选择部分
        let contentViewHeader = UIView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height+(navigationController?.navigationBar.frame.size.height)!, width: contentView.frame.width, height: 121))
        contentViewHeader.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        let labelLeftStyle = UILabel(frame: CGRect(x: 10, y: 10, width: 5, height: 20))
        labelLeftStyle.backgroundColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
        contentViewHeader.addSubview(labelLeftStyle)
        
        let labelRightcontent = UILabel(frame: CGRect(x: 20, y: 10, width: contentViewHeader.frame.width-40, height: 20))
        labelRightcontent.text = "单位选择"
        labelRightcontent.font = UIFont.boldSystemFont(ofSize: 15)
        labelRightcontent.textAlignment = .left
        contentViewHeader.addSubview(labelRightcontent)
        
        let contentViewHeaderRow = UIView(frame: CGRect(x: 0, y: 40, width: contentViewHeader.frame.width, height: 40))
        let leftStarView = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        leftStarView.image = UIImage(named: "test")//五角星图片
        contentViewHeaderRow.addSubview(leftStarView)
        
        contentViewHeaderRow.backgroundColor = UIColor.white
        let leftLabel = UILabel(frame: CGRect(x: 20, y: 5, width: 90, height: 30))
        leftLabel.text = "一级单位："
        leftLabel.font = UIFont.boldSystemFont(ofSize: 14)
        leftLabel.textAlignment = .left
        contentViewHeaderRow.addSubview(leftLabel)
        contentViewHeader.addSubview(contentViewHeaderRow)
        
        let oneMean = UIButton()
        oneMean.frame = CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30)
        oneMean.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        oneMean.setNewStyle(image: UIImage(named: "下拉"), title: "消防", titlePosition: UIViewContentMode.left, additionalSpacing: (KUIScreenWidth-100)*0.5, state: UIControlState.normal)
        oneMean.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        oneMean.layer.borderWidth = 1
        oneMean.tag = 3001
        oneMean.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        contentViewHeaderRow.addSubview(oneMean)
        
        let contentViewHeaderRow2 = UIView(frame: CGRect(x: 0, y: 81, width: contentViewHeader.frame.width, height: 40))
        let leftStarView2 = UIImageView(frame: CGRect(x: 10, y: 20, width: 5, height: 5))
        leftStarView2.image = UIImage(named: "test")//五角星图片
        contentViewHeaderRow2.addSubview(leftStarView2)
        
        contentViewHeaderRow2.backgroundColor = UIColor.white
        let leftLabel2 = UILabel(frame: CGRect(x: 20, y: 5, width: 90, height: 30))
        leftLabel2.text = "二级单位："
        leftLabel2.font = UIFont.boldSystemFont(ofSize: 14)
        leftLabel2.textAlignment = .left
        contentViewHeaderRow2.addSubview(leftLabel2)
        contentViewHeader.addSubview(contentViewHeaderRow2)
        
        let twoMean = UIButton()
        twoMean.frame = CGRect(x: 100, y: 5, width: KUIScreenWidth - 120, height: 30)
        twoMean.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        twoMean.setNewStyle(image: UIImage(named: "下拉"), title: "消防护卫部消防大队1246号消防车", titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        twoMean.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        twoMean.layer.borderWidth = 1
        twoMean.tag = 3002
        twoMean.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        contentViewHeaderRow2.addSubview(twoMean)
        contentView.addSubview(contentViewHeader)
        view.addSubview(contentView)
        
//        设备基本信息
        
        
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
    
    @objc func cancelButtonAction(){
        selectorView.isHidden = true
    }
    
    @objc func doneButtonAction(){
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectIndex = selector.selectedRow(inComponent: 0)
        let selectText = selectorData[selectIndex]["typeName"]?.description
        selectBtn.setNewStyle(image: UIImage(named: "下拉"), title: selectText!, titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        
        selectorView.isHidden = true
        
        switch clickedBtnTag {
        case 3001:
            print(3001)
//            selectedEquipmentId = selectorData[selectIndex]["typeId"]?.description
        case 3002:
            print(3002)
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
        case 3001:
            print(3001)
//            for i in self.alarmEquipmentListData.enumerated(){
//                let elementDic:[String:AnyObject] = ["typeName":self.alarmEquipmentListData[i.offset]["text"].stringValue as AnyObject,"typeId":self.alarmEquipmentListData[i.offset]["id"].stringValue as AnyObject]
//                selectorData.append(elementDic)
//                if selectText == self.alarmEquipmentListData[i.offset]["text"].stringValue{
//                    selectedIndex = i.offset
//                }
//            }
        case 3002:
            print(3002)
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
