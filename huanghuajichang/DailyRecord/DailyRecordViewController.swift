//
//  DailyRecordViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import PGDatePicker
import MJRefresh
import Kingfisher
import Alamofire
import SwiftyJSON

class DailyRecordViewController: BaseViewController,PGDatePickerDelegate {
    
    let dateLabel:UILabel = UILabel()
    
    var HeaderView:UIView!
    var nextMonthBtn:UIButton!
    
    //按钮数组
    var buttons:[ThickButtonModel] = []
    
    let thickbuttons = ThickButton()
    
    // view
    var  buttonsView:UIView!
    
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    // 底部刷新
    let refreshFooter = MJRefreshAutoNormalFooter()
    
    var recordTableView:UITableView!
    
    let CellIdentifier = "Cell"
    
    var pageStatus = ""
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var listData:[DailyRecordViewModel] = []
    var json:JSON!
    var pageStart = 0
    let pageSize = 10
    var dataToEnd = false
    var selectedBtnIndex = 0
    var dateTool = HandleDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日常记录"
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        // Do any additional setup after loading the view.
        createRightBtns()
        createFixedUI()
        createHeader()
        createTabList()
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "updateList"), object: nil)
//        getData()
    }
    
    @objc func updateList(){
        selectedBtnIndex = 0
        pageStart = 0
        self.getHeaderData()
        self.getListData(searchStr: "")
    }
    
    ///1.绘制navigationBar的右侧按钮组
    func createRightBtns(){
        if #available(iOS 11.0, *){
            let customView = UIView.init(frame: CGRect(x: 0, y: 10, width: 54, height: 22))
            let searchBarBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            searchBarBtn.setImage(UIImage(named: "搜索"), for: UIControlState.normal)
            searchBarBtn.addTarget(self, action: #selector(openSearch), for: UIControlEvents.touchUpInside)
            searchBarBtn.tintColor = UIColor.white
            customView.addSubview(searchBarBtn)
            
            let addBarBtn = UIButton.init(frame: CGRect(x: 32, y: 0, width: 22, height: 22))
            addBarBtn.setImage(UIImage(named: "新增"), for: UIControlState.normal)
            addBarBtn.addTarget(self, action: #selector(openAdd), for: UIControlEvents.touchUpInside)
            addBarBtn.tintColor = UIColor.white
            customView.addSubview(addBarBtn)
            
            let customRightItem = UIBarButtonItem.init(customView: customView)
            self.navigationItem.rightBarButtonItem = customRightItem
        }else{
            let searchBarBtn = UIBarButtonItem(
                image: UIImage(named: "搜索"), style: UIBarButtonItemStyle.done, target: self, action: #selector(openSearch))
            searchBarBtn.tintColor = UIColor.white
            let addBarBtn = UIBarButtonItem(image: UIImage(named: "新增"), style: UIBarButtonItemStyle.done, target: self, action: #selector(openAdd))
            addBarBtn.tintColor = UIColor.white
            let fixBarBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            fixBarBtn.width = -12
            self.navigationItem.rightBarButtonItems = [addBarBtn, fixBarBtn, searchBarBtn]
        }
    }
    
    @objc func openSearch(){
        userDefault.set(dateLabel.text, forKey: "searchMonth")
        let searchVc = DailySearchViewController()
        self.present(searchVc, animated: true, completion: nil)
    }
    
    @objc func openAdd(){
        let addVc = AddDailyRecordViewController()
        let addNav = UINavigationController(rootViewController: addVc)
        self.present(addNav, animated: true, completion: nil)
    }
    
    ///2-1.绘制日历工具栏
    func createFixedUI(){
        let dateChangeView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        dateChangeView.backgroundColor = UIColor(red: 232/255, green: 243/255, blue: 255/255, alpha: 1)
        self.view.addSubview(dateChangeView)
        
        //左侧按钮
        let lastMonthBtn = UIButton.init(frame: CGRect(x: 20, y: 10, width: 20, height: 20))
        lastMonthBtn.setImage(UIImage(named: "上一天"), for: UIControlState.normal)
        lastMonthBtn.tag = 1
        lastMonthBtn.addTarget(self, action: #selector(changeDateByButton(sender:)), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(lastMonthBtn)
        
        //日期插件
        dateLabel.frame.size = CGSize(width: 60, height: 20)
        dateLabel.center.x = self.view.center.x
        dateLabel.frame.origin.y = 10
        dateLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        let currentMonth = NSDate()
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM"
        dateLabel.text = dateFormater.string(from: currentMonth as Date) as String
        dateChangeView.addSubview(dateLabel)
        
        let dateBtn = UIButton.init(frame: CGRect(x: dateLabel.frame.origin.x+dateLabel.frame.width+5, y: 10, width: 20, height: 20))
        dateBtn.setImage(UIImage(named: "日期"), for: UIControlState.normal)
        dateBtn.addTarget(self, action: #selector(opendatePicker), for: UIControlEvents.touchUpInside)
        dateBtn.setEnlargeEdge(20)
        dateChangeView.addSubview(dateBtn)
        
        //右侧按钮
        nextMonthBtn = UIButton.init(frame: CGRect(x: kScreenWidth-40, y: 10, width: 20, height: 20))
        nextMonthBtn.setImage(UIImage(named: "下一天"), for: UIControlState.normal)
        nextMonthBtn.tag = 2
        nextMonthBtn.isEnabled = false
        nextMonthBtn.addTarget(self, action: #selector(changeDateByButton(sender:)), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(nextMonthBtn)
    }
    
    @objc func opendatePicker(){
        let datePickerManager = PGDatePickManager.init()
        datePickerManager.isShadeBackgroud = true
        datePickerManager.style = .alertBottomButton
        let datePicker = datePickerManager.datePicker!
        datePicker.delegate = self
        datePicker.datePickerType = .type2
        datePicker.datePickerMode = .yearAndMonth
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM"
        let date = dateFormater.date(from: dateLabel.text!)
        datePicker.setDate(date, animated: false)
        //设置最大日期
        let currentMonth = NSDate()
        datePicker.maximumDate = currentMonth as Date
        self.present(datePickerManager, animated: false, completion: nil)
    }
    
    @objc func changeDateByButton(sender:UIButton?){
        
//        print("year:\(year)"+";"+"month:"+formateNum(num:month))
        pageStart = 0
        let newDate = dateTool.changeDate(changeDate: dateLabel.text!, chageType: (sender?.tag)!)
        dateLabel.text = newDate
        nextMonthBtn.isEnabled = dateTool.compareWithCurrent(newDate: newDate)
        getHeaderData()
        getListData(searchStr: "")
    }
    
    ///3.获取表头需要的数据（日常记录条数）
    @objc func getHeaderData() {
        let infoData = ["startDay":dateTool.getNeedDate(changeDate: dateLabel.text!, startOrEnd: 0),"endDay":dateTool.getNeedDate(changeDate: dateLabel.text!, startOrEnd: 1)]
        let contentData : [String : Any] = ["method":"getOptionNum","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                self.buttons = [ThickButtonModel(value: JSON(value)["data"]["all"].intValue, describe: "全部"), ThickButtonModel(value: JSON(value)["data"]["noope"].intValue, describe: "未处理"), ThickButtonModel(value:JSON(value)["data"]["ope"].intValue, describe:"已处理")]
                if self.buttonsView != nil{
                    self.buttonsView.removeFromSuperview()
                    self.buttonsView = self.thickbuttons.creatThickButton(buttonsFrame: CGRect(x: 10, y: 41, width: kScreenWidth-20, height: 62), dataArr: self.buttons, selectedIndex: self.selectedBtnIndex)
                    self.thickbuttons.delegate = self
                    self.HeaderView.addSubview(self.buttonsView)
                }
                
            case .failure(let error):
//                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///4.绘制列表头
    func createHeader(){
        HeaderView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 103))
        HeaderView.backgroundColor = UIColor.white
        self.view.addSubview(HeaderView)
        
        let topLabel:UILabel = UILabel.init(frame: CGRect(x: 15, y: 10, width: kScreenWidth-30, height: 20))
        topLabel.text = "记录任务"
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textColor = allFontColor
        topLabel.numberOfLines = 0
        HeaderView.addSubview(topLabel)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 10, y: 40, width: kScreenWidth-20, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        HeaderView.addSubview(spearLine)
        
        buttonsView = thickbuttons.creatThickButton(buttonsFrame: CGRect(x: 10, y: 41, width: kScreenWidth-20, height: 62), dataArr: buttons, selectedIndex: selectedBtnIndex)
        thickbuttons.delegate = self
        HeaderView.addSubview(buttonsView)
        getHeaderData()
    }
    
    ///2-2.绘制tablist
    func createTabList(){
        recordTableView = UITableView.init(frame: CGRect(x: 0, y: 143, width: kScreenWidth, height: kScreenHeight-144-navigationHeight-tabBarHeight))
        recordTableView.delegate = self
        recordTableView.dataSource = self
        recordTableView.separatorStyle = .none
        recordTableView.backgroundColor = allListBackColor
        self.view.addSubview(recordTableView)
        recordTableView.register(RecordListTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        initMJRefresh()
    }
    
    ///5.获取tabList需要的数据（日常记录条数）
    /// - Parameter searchStr: 搜索的字符串
    /// - Parameter state：是否被处理的状态码
    /// - Parameter pageNum：起始页吗数
    /// - Parameter pageSize：每页条数
    func getListData(searchStr:String) {
        self.dataToEnd = false
        var requestState:Any
        switch selectedBtnIndex {
        case 1:
            requestState = 0
        case 2:
            requestState = 1
        default:
            requestState = ""
        }
        MyProgressHUD.showStatusInfo("加载中...")
        let infoData = ["title":searchStr, "state":requestState, "start":pageStart, "length":pageSize, "startDay":dateTool.getNeedDate(changeDate: dateLabel.text!, startOrEnd: 0), "endDay":dateTool.getNeedDate(changeDate: dateLabel.text!, startOrEnd: 1)] as [String : Any]
        if pageStart == 0 {
            self.listData = []
        }
        let contentData : [String : Any] = ["method":"getOptionlist","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.json = JSON(value)["data"]["resultData"]
                    
                    for recordItem in self.json.enumerated(){
                        let recordModel = DailyRecordViewModel(describe: self.json[recordItem.offset]["describe"].stringValue, filesId: self.json[recordItem.offset]["filesId"].stringValue, id: self.json[recordItem.offset]["id"].intValue, opeTime: self.json[recordItem.offset]["opeTime"].intValue, staId: self.json[recordItem.offset]["staId"].intValue, staName: self.json[recordItem.offset]["staName"].stringValue, staTime: self.json[recordItem.offset]["staTime"].intValue, state: self.json[recordItem.offset]["state"].intValue, title: self.json[recordItem.offset]["title"].stringValue, userId: self.json[recordItem.offset]["userId"].intValue, userName: self.json[recordItem.offset]["userName"].stringValue)
                        self.listData.append(recordModel)
                    }
                    if self.listData.count >= JSON(value)["data"]["iTotalRecords"].intValue {
                        self.dataToEnd = true
                        self.refreshFooter.state = .noMoreData
                    }else{
                        self.refreshFooter.state = .idle
                    }
                    self.recordTableView.reloadData()
                    if self.pageStart == 0 && self.json.arrayValue.count > 0{
                        self.recordTableView.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                    }
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
    
    ///删除日常记录项
    func deleteListItem(itemId:String, itemIndexPath:IndexPath){
        MyProgressHUD.showStatusInfo("删除中...")
        let infoData = ["id":itemId]
        let contentData : [String : Any] = ["method":"delOptionById","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            //print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //重新请求页面数据
                    self.getHeaderData()
                    self.getListData(searchStr:"")
//                    self.listData.remove(at: itemIndexPath.row)
//
//                    self.recordTableView!.deleteRows(at: [itemIndexPath], with: UITableViewRowAnimation.fade)
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "删除失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "删除请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    //初始化下拉刷新/上拉加载
    func initMJRefresh(){
        //下拉刷新相关设置
        refresHeader.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.headerRefresh))
        // 现在的版本要用mj_header
        
         refresHeader.setTitle("下拉刷新", for: .idle)
         refresHeader.setTitle("释放更新", for: .pulling)
         refresHeader.setTitle("正在刷新...", for: .refreshing)
         self.recordTableView.mj_header = refresHeader
        //初始化上拉加载
        init_bottomFooter()
    }
    
    //上拉加载初始化设置
    func init_bottomFooter(){
        //上刷新相关设置
        refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.footerRefresh))
        //self.bottom_footer.stateLabel.isHidden = true // 隐藏文字
        //是否自动加载（默认为true，即表格滑到底部就自动加载,这个我建议关掉,要不然效果会不好）
        refreshFooter.isAutomaticallyRefresh = false
        refreshFooter.isAutomaticallyChangeAlpha = true //自动更改透明度
        //修改文字
        refreshFooter.setTitle("上拉加载更多数据", for: .idle)//普通闲置的状态
//        refreshFooter.setTitle("释放更新", for: .pulling)
        refreshFooter.setTitle("加载中...", for: .refreshing)//正在刷新的状态
        refreshFooter.setTitle("没有更多数据了", for: .noMoreData)//数据加载完毕的状态
        //将上拉加载的控件与 tableView控件绑定起来
        self.recordTableView.mj_footer = refreshFooter
        getListData(searchStr:"")
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
//        print("下拉刷新")
        pageStart = 0
        //服务器请求数据的函数
        getListData(searchStr:"")
        
        //结束下拉刷新
        self.recordTableView.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
//        print("上拉加载")
        if dataToEnd == false {
            pageStart += 10
            //服务器请求数据的函数
            getListData(searchStr:"")
        }
        //结束下拉刷新
        self.recordTableView.mj_footer.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //PGDatePickerDelegate
    func datePicker(_ datePicker: PGDatePicker!, didSelectDate dateComponents: DateComponents!) {
        nextMonthBtn.isEnabled = dateTool.compareWithCurrent(newDate: "\(dateComponents.year!)" + "-" + dateTool.formateNum(num: dateComponents.month!))
        dateLabel.text = "\(dateComponents.year!)" + "-" + dateTool.formateNum(num: dateComponents.month!)
//        print("dateComponents = ", dateComponents)
        pageStart = 0
        getHeaderData()
        getListData(searchStr: "")
    }
    
    //最后要记得移除通知
    /// 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
extension DailyRecordViewController:ThickButtonDelagate{
    //#MARK - ThickButtonDelagate
    //实现按钮控制页面的切换
    func clickChangePage(_ thickButton: ThickButton, buttonIndex: NSInteger) {
//        print(buttonIndex)
        selectedBtnIndex = buttonIndex
        pageStart = 0
        getListData(searchStr: "")
    }
}
extension DailyRecordViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.listData == [] {
            return 0
        }else{
            return self.listData.count
        }
    }
    
    //设置每行的单元格的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? RecordListTableViewCell
        if cell == nil{
            cell = RecordListTableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }
        
        if self.listData != [] {
//            print(self.listData[indexPath.row])
//            print(type(of: self.json[indexPath.row]))
            //当无图片时显示默认图片
            let views = cell?.itemImage?.subviews
            for itemImageSub in views! {
                itemImageSub.removeFromSuperview()
            }
            if self.listData[indexPath.row].filesId == "" {
//                print(self.listData[indexPath.row].filesId)
                cell?.itemImage?.image = UIImage(named: "默认图片")
            }else{
                let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (self.listData[indexPath.row].filesId.components(separatedBy: ",")[0])
//                cell?.itemImage?.dowloadFromServer(link: imgurl as String, contentMode: .scaleAspectFit)
                cell?.itemImage?.kf.setImage(with: ImageResource(downloadURL:(NSURL.init(string: imgurl))! as URL), placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil, completionHandler: nil)
                let photoNum = UILabel.init(frame: CGRect(x: 0, y: (cell?.itemImage?.frame.height ?? 60)-20.0, width: (cell?.itemImage?.frame.width ?? 80), height: 20))
                photoNum.text = "共\(self.listData[indexPath.row].filesId.components(separatedBy: ",").count)张"
                photoNum.textColor = UIColor.white
                photoNum.textAlignment = .center
                photoNum.font = UIFont(name: "PingFangSC-Regular", size: 13.0)
                photoNum.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.5)
                cell?.itemImage?.addSubview(photoNum)
            }
            cell?.itemTitle?.text =  self.listData[indexPath.row].title
            cell?.itemId = self.listData[indexPath.row].id.description
            cell?.itemCreator?.text = "发布人:" + self.listData[indexPath.row].userName.description
            //默认颜色是已处理的，所以在未处理时更改颜色
            if self.listData[indexPath.row].state.description == "0" {
                cell?.itemStatus?.text = "未处理"
                cell?.itemStatus?.layer.borderColor = topValueColor.cgColor
                cell?.itemStatus?.textColor = topValueColor
                cell?.itemHandler?.isHidden = true
            }else{
                cell?.itemStatus?.text = "已处理"
                cell?.itemStatus?.layer.borderColor = UIColor(red: 143/255, green: 144/255, blue: 145/255, alpha: 1).cgColor
                cell?.itemStatus?.textColor = UIColor(red: 158/255, green: 159/255, blue: 160/255, alpha: 1)
                cell?.itemHandler?.isHidden = false
                cell?.itemHandler?.text = "处理人:" + self.listData[indexPath.row].staName.description
            }
            cell?.itemDate?.text = AddDailyRecordViewController.timeStampToString(timeStamp: self.listData[indexPath.row].opeTime.description,timeAccurate: "minute")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectdRecordCell = tableView.cellForRow(at: indexPath) as! RecordListTableViewCell
        print((selectdRecordCell.itemTitle?.text)!)
        userDefault.set(selectdRecordCell.itemId, forKey: "recordId")
        
        let scanVc = ScanAndEditViewController()
        let scanNav = UINavigationController(rootViewController: scanVc)
        self.present(scanNav, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let deleteRecordCell = tableView.cellForRow(at: indexPath) as! RecordListTableViewCell
//        if editingStyle == .delete {
//            deleteListItem(itemId: deleteRecordCell.itemId, itemIndexPath: indexPath)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
//        return "删除"
//    }
    //尾部滑动事件按钮（左滑按钮）
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        let itemCell = tableView.cellForRow(at: indexPath) as! RecordListTableViewCell
        //删除
        let deleteAction:UIContextualAction = UIContextualAction(style: .normal, title: "删除") { (action, sourceView, completionHandler) in
            
            if itemCell.itemStatus?.text == "已处理" {
                completionHandler(false)
            }else{
                self.deleteListItem(itemId: itemCell.itemId, itemIndexPath: indexPath)
                completionHandler(true)
            }
        }
        //delete操作按钮可使用UIContextualActionStyleDestructive类型，当使用该类型时，如果是右滑操作，一直向右滑动某个cell，会直接执行删除操作，不用再点击删除按钮。
        
        if itemCell.itemStatus?.text == "已处理" {
            deleteAction.backgroundColor = UIColor.pg_color(withHexString: "#EEEEEE")
        }else{
            deleteAction.backgroundColor = UIColor.red
        }
        //        deleteAction.image = UIImage(named: "delete")
        
        let actions:[UIContextualAction] = [deleteAction]
        
        let action:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        // 当一直向右滑是bu会执行第一个action
        action.performsFirstActionWithFullSwipe = false
        
        return action
        
    }
}
