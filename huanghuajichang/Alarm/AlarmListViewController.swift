//
//  AlarmListViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/26.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON

class AlarmListViewController: AddNavViewController {
    
    var leftSelect:UIButton!
    var rightSelect:UIButton!
    var alarmTableList:UITableView!
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    // 底部刷新
    let refreshFooter = MJRefreshBackNormalFooter()
    
    var selectorView:UIView!
    var selector:UIPickerView!
    var clickedBtnTag:Int!
    
    var selectorData:[[String:AnyObject]] = []
    var equitSelectorData:[[String:AnyObject]] = []
    var typeSelectorData:[[String:AnyObject]] = []
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var pageStart = 0
    let pageSize = 10
    var alarmListjson:JSON = []
    var alarmEquipmentListData:JSON = []
    var alarmTypeListData:JSON = []
    
    var selectedEquipmentId:String!
    var selectedTypeId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "报警列表"
        self.view.backgroundColor = allListBackColor
        // Do any additional setup after loading the view.
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        getAlarmEquipmentListData()
        
    }
    
    func createUI(){
        leftSelect = UIButton.init(frame: CGRect(x: 0, y: 0, width: (kScreenWidth-1)/2, height: 40))
        leftSelect.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        leftSelect.set(image: UIImage(named: "下拉"), title: self.equitSelectorData[0]["typeName"]?.description ?? "", titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        leftSelect.tag = 3001
        leftSelect.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(leftSelect)
        
        rightSelect = UIButton.init(frame: CGRect(x: (kScreenWidth-1)/2+1, y: 0, width: (kScreenWidth-1)/2, height: 40))
        rightSelect.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        rightSelect.set(image: UIImage(named: "下拉"), title: self.typeSelectorData[0]["typeName"]?.description ?? "", titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        rightSelect.tag = 3002
        rightSelect.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(rightSelect)
        
        ///列表
        alarmTableList = UITableView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: kScreenHeight-navigationHeight-40))
        alarmTableList.backgroundColor = allListBackColor
        alarmTableList.delegate = self
        alarmTableList.dataSource = self
        alarmTableList.separatorStyle = .none
        self.view.addSubview(alarmTableList)
        alarmTableList.register(AlarmListTableViewCell.self, forCellReuseIdentifier: "alarmCell")
        
        initMJRefresh()
        
        ///选择弹出框
        selectorView = UIView.init(frame:CGRect(x: 0, y: kScreenHeight-navigationHeight-240, width: kScreenWidth, height: 240))
        selectorView.isHidden = true
        self.view.addSubview(selectorView)
        
        let selectorToolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        selectorToolBar.backgroundColor = UIColor.white
        let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        selectorToolBar.setItems([cancelBtn,flexSpace, doneBtn], animated: false)
        selectorToolBar.sizeToFit()
        selectorView.addSubview(selectorToolBar)
        
        selector = UIPickerView.init(frame:CGRect(x: 0, y: 40, width: kScreenWidth, height: 200))
        selector.delegate = self
        selector.dataSource = self
        selector.backgroundColor = UIColor.white
        selectorView.addSubview(selector)
    }
    
    //初始化下拉刷新/上拉加载
    func initMJRefresh(){
        //下拉刷新相关设置
        refresHeader.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.headerRefresh))
        // 现在的版本要用mj_header
        
        refresHeader.setTitle("下拉刷新", for: .idle)
        refresHeader.setTitle("释放更新", for: .pulling)
        refresHeader.setTitle("正在刷新...", for: .refreshing)
        self.alarmTableList.mj_header = refresHeader
        //初始化上拉加载
        init_bottomFooter()
    }
    
    //上拉加载初始化设置
    func init_bottomFooter(){
        //上刷新相关设置
        refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.footerRefresh))
        //self.bottom_footer.stateLabel.isHidden = true // 隐藏文字
        //是否自动加载（默认为true，即表格滑到底部就自动加载,这个我建议关掉,要不然效果会不好）
//        refreshFooter.isAutomaticallyRefresh = false
        refreshFooter.isAutomaticallyChangeAlpha = true //自动更改透明度
        //修改文字
        refreshFooter.setTitle("上拉上拉上拉", for: .idle)//普通闲置的状态
        //        refreshFooter.setTitle("释放更新", for: .pulling)
        refreshFooter.setTitle("加载加载加载", for: .refreshing)//正在刷新的状态
        refreshFooter.setTitle("没有没有更多数据了", for: .noMoreData)//数据加载完毕的状态
        //将上拉加载的控件与 tableView控件绑定起来
        self.alarmTableList.mj_footer = refreshFooter
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        print("下拉刷新")
        pageStart = 0
        //服务器请求数据的函数
        self.getAlarmListData(alarmOrganizationId:self.selectedEquipmentId ,alarmType:self.selectedTypeId)
        //结束下拉刷新
        self.alarmTableList.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
        print("上拉刷新")
        pageStart = pageStart+10
        self.getAlarmListData(alarmOrganizationId:self.selectedEquipmentId ,alarmType:self.selectedTypeId)
        //结束下拉刷新
        self.alarmTableList.mj_footer.endRefreshing()
    }
    
    ///获取报警单位列表数据
    @objc func getAlarmEquipmentListData() {
        MyProgressHUD.showStatusInfo("加载中...")
        let contentData : [String : Any] = ["method":"getEquTreeList","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
//            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.alarmEquipmentListData = JSON(value)["data"]
                    //                    self.recordTableView.reloadData()
                    
                    let AllElementDic:[String:AnyObject] = ["typeName":"全部" as AnyObject,"typeId":"allItem" as AnyObject]
                    self.equitSelectorData.append(AllElementDic)
                    
                    for i in self.alarmEquipmentListData.enumerated(){
                        let elementDic:[String:AnyObject] = ["typeName":self.alarmEquipmentListData[i.offset]["text"].stringValue as AnyObject,"typeId":self.alarmEquipmentListData[i.offset]["id"].stringValue as AnyObject]
                        self.equitSelectorData.append(elementDic)
                    }
                    self.selectedEquipmentId = self.equitSelectorData[0]["typeId"] as? String
                    self.getAlarmTypeListData()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///获取报警类型列表数据
    @objc func getAlarmTypeListData() {
        let contentData : [String : Any] = ["method":"getAlarmType","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.alarmTypeListData = JSON(value)["data"]
                    let AllElementDic:[String:AnyObject] = ["typeName":"全部" as AnyObject,"typeId":"allItem" as AnyObject]
                    self.typeSelectorData.append(AllElementDic)
                    for i in self.alarmTypeListData.enumerated(){
                        let elementDic:[String:AnyObject] = ["typeName":self.alarmTypeListData[i.offset]["name"].stringValue as AnyObject,"typeId":self.alarmTypeListData[i.offset]["value"].stringValue as AnyObject]
                        self.typeSelectorData.append(elementDic)
                    }
                    self.selectedTypeId = self.typeSelectorData[0]["typeId"] as? String
                    self.createUI()
                    self.getAlarmListData(alarmOrganizationId:self.selectedEquipmentId ,alarmType:self.selectedTypeId)
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///获取报警列表数据
    @objc func getAlarmListData(alarmOrganizationId:String,alarmType:String) {
        var postOrganizationId:AnyObject = alarmOrganizationId as AnyObject
        var postAlarmType:AnyObject = alarmType as AnyObject
        if alarmOrganizationId == "allItem"{
            postOrganizationId = NSNull()
        }
        if alarmType == "allItem"{
            postAlarmType = NSNull()
        }
        let infoData = ["organizationId":postOrganizationId,"alarmType":postAlarmType,"start":pageStart,"length":pageSize] as [String : Any]
        let contentData : [String : Any] = ["method":"getAlarmList","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
//            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.alarmListjson = JSON(value)["data"]["resultData"]
                    self.alarmTableList.reloadData()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    //                    print(type(of: JSON(value)["msg"]))
                    self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    @objc func customSelector(sender:UIButton){
        clickedBtnTag = sender.tag
        selectorData = []
        var selectedIndex = 0
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectText = selectBtn.title(for: UIControlState.normal)
        switch clickedBtnTag {
        case 3001:
            selectorData = self.equitSelectorData
            for i in self.equitSelectorData.enumerated(){
                if selectText == self.equitSelectorData[i.offset]["typeName"]?.description{
                    selectedIndex = i.offset
                }
            }
        default:
            selectorData = self.typeSelectorData
            for i in self.typeSelectorData.enumerated(){
                if selectText == self.typeSelectorData[i.offset]["typeName"]?.description{
                    selectedIndex = i.offset
                }
            }
        }
        
        selector.reloadAllComponents()
        selector.selectRow(selectedIndex, inComponent: 0, animated: false)
        selectorView.isHidden = false
        
    }
    @objc func cancelButtonAction(){
        selectorView.isHidden = true
    }
    
    @objc func doneButtonAction(){
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectIndex = selector.selectedRow(inComponent: 0)
        var selectText:String?
        
        switch clickedBtnTag {
        case 3001:
            selectedEquipmentId = equitSelectorData[selectIndex]["typeId"]?.description
            selectText = equitSelectorData[selectIndex]["typeName"]?.description
        default:
            selectedTypeId = typeSelectorData[selectIndex]["typeId"]?.description
            selectText = typeSelectorData[selectIndex]["typeName"]?.description
        }
        selectBtn.set(image: UIImage(named: "下拉"), title: selectText!, titlePosition: UIViewContentMode.left, additionalSpacing: 5, state: UIControlState.normal)
        
        selectorView.isHidden = true
        
        pageStart = 0
        getAlarmListData(alarmOrganizationId: selectedEquipmentId, alarmType: selectedTypeId)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func backItemPressed () {
        self.navigationController?.popViewController(animated: false)
    }

}

extension AlarmListViewController:UIPickerViewDelegate,UIPickerViewDataSource{
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

extension AlarmListViewController:UITableViewDelegate, UITableViewDataSource{
    //MARK - dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.alarmListjson == []{
            return 0
        }else{
            return self.alarmListjson.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var alarmListCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as? AlarmListTableViewCell
        if alarmListCell == nil {
            alarmListCell = AlarmListTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "alarmCell")
        }
        let cellData = self.alarmListjson[indexPath.row]
        alarmListCell?.itemTitle.text = cellData["objCode"].stringValue
        alarmListCell?.itemStatus.text = cellData["alarmTypeName"].stringValue
        alarmListCell?.itemName.text = cellData["alarmRaName"].stringValue
        alarmListCell?.itemTime.text = AddDailyRecordViewController.timeStampToString(timeStamp: cellData["alarmTime"].stringValue,timeAccurate: "second")
        alarmListCell?.changUI(realTitle:(alarmListCell?.itemTitle.text)!,realStatus:(alarmListCell?.itemStatus.text)!)
        alarmListCell?.itemId = cellData["id"].stringValue
        if self.userDefault.integer(forKey: "maxId") < Int((alarmListCell?.itemId)!)!{
            alarmListCell?.itemIcon.isHidden = false
        }else{
            alarmListCell?.itemIcon.isHidden = true
        }
        return alarmListCell!
    }
    
    //MARK - delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlarmId = (tableView.cellForRow(at: indexPath) as! AlarmListTableViewCell).itemId
        let alarmAnalysisVc = AlarmAnalysisViewController()
        alarmAnalysisVc.alarmDetailId = selectedAlarmId
        alarmAnalysisVc.alarmDetailInfo = self.alarmListjson[indexPath.row]
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(alarmAnalysisVc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

///带图标，文字的按钮
extension UIButton {
    @objc func set(image anImage: UIImage?, title: String, titlePosition: UIViewContentMode, additionalSpacing: CGFloat, state: UIControlState){
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
            let titleWidth = title.size(withAttributes: [NSAttributedStringKey.font: titleFont!]).width > kScreenWidth/2-imageSize.width-spacing ? kScreenWidth/2-imageSize.width-spacing : title.size(withAttributes: [NSAttributedStringKey.font: titleFont!]).width
            
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width), bottom: 0, right: imageSize.width+spacing)
            imageInsets = UIEdgeInsets(top: 0, left: titleWidth+spacing, bottom: 0, right: -(titleWidth))
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
