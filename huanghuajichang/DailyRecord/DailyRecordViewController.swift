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

import Alamofire
import SwiftyJSON

class DailyRecordViewController: BaseViewController,PGDatePickerDelegate {
    
    let dateLabel:UILabel = UILabel()
    
    var HeaderView:UIView!
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
    var listData:NSMutableArray = []
    var json:JSON!
    var pageStart = 0
    let pageSize = 10
    
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
        self.getHeaderData()
        self.getListData(searchStr: "", state: "")
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
        dateChangeView.addSubview(dateBtn)
        
        //右侧按钮
        let nextMonthBtn = UIButton.init(frame: CGRect(x: kScreenWidth-40, y: 10, width: 20, height: 20))
        nextMonthBtn.setImage(UIImage(named: "下一天"), for: UIControlState.normal)
        nextMonthBtn.tag = 2
        nextMonthBtn.addTarget(self, action: #selector(changeDateByButton(sender:)), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(nextMonthBtn)
    }
    
    @objc func opendatePicker(){
        let datePickerManager = PGDatePickManager.init()
        datePickerManager.isShadeBackgroud = true
        datePickerManager.style = .style3
        let datePicker = datePickerManager.datePicker!
        datePicker.delegate = self
        datePicker.datePickerType = .type2
        datePicker.datePickerMode = .yearAndMonth
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = "yyyy-MM"
        let date = dateFormater.date(from: dateLabel.text!)
        datePicker.setDate(date, animated: false)
        self.present(datePickerManager, animated: false, completion: nil)
    }
    
    @objc func changeDateByButton(sender:UIButton?){
        
//        print("year:\(year)"+";"+"month:"+formateNum(num:month))
        dateLabel.text = changeDate(chageType: (sender?.tag)!)
        getHeaderData()
        getListData(searchStr: "", state: "")
    }
    
    func changeDate(chageType:Int)->String{
        var year = ((dateLabel.text?.split(separator: "-")[0])! as NSString).integerValue
        var month = ((dateLabel.text?.split(separator: "-")[1])! as NSString).integerValue
        switch chageType {
        case 1://减
            if month == 01 {
                year = year - 1
                month = 12
            }else{
                month = month - 1
            }
            
        default://增
            if month == 12 {
                year = year + 1
                month = 01
            }else{
                month = month + 1
            }
        }
        let newDate = "\(year)" + "-" + formateNum(num: month)
        return newDate
    }
    
    ///3.获取表头需要的数据（日常记录条数）
    @objc func getHeaderData() {
        let infoData = ["startday":"\(dateLabel.text!)-01","endDay":"\(changeDate(chageType: 2))-01"]
        let contentData : [String : Any] = ["method":"getOptionNum","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                self.buttons = [ThickButtonModel(value: JSON(value)["data"]["all"].intValue, describe: "全部"), ThickButtonModel(value: JSON(value)["data"]["noope"].intValue, describe: "未处理"), ThickButtonModel(value:JSON(value)["data"]["ope"].intValue, describe:"已处理")]
                if self.buttonsView != nil{
                    self.buttonsView.removeFromSuperview()
                    self.self.buttonsView = self.thickbuttons.creatThickButton(buttonsFrame: CGRect(x: 10, y: 41, width: kScreenWidth-20, height: 62), dataArr: self.buttons)
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
        
        buttonsView = thickbuttons.creatThickButton(buttonsFrame: CGRect(x: 10, y: 41, width: kScreenWidth-20, height: 62), dataArr: buttons)
        thickbuttons.delegate = self
        HeaderView.addSubview(buttonsView)
        getHeaderData()
    }
    
    ///2-2.绘制tablist
    func createTabList(){
        recordTableView = UITableView.init(frame: CGRect(x: 0, y: 143, width: kScreenWidth, height: kScreenHeight-144-64-49))
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
    func getListData(searchStr:String, state:Any) {
        MyProgressHUD.showStatusInfo("加载中...")
        let infoData = ["title":searchStr, "state":state, "start":pageStart, "length":pageSize, "startday":"\(dateLabel.text!)-01", "endDay":"\(changeDate(chageType: 2))-01"] as [String : Any]
        let contentData : [String : Any] = ["method":"getOptionlist","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.json = JSON(value)["data"]["resultData"]
                    self.recordTableView.reloadData()
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
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //重新请求页面数据
                    self.getHeaderData()
                    self.getListData(searchStr:"", state:"")
                    
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
        refreshFooter.setTitle("上拉上拉上拉", for: .idle)//普通闲置的状态
//        refreshFooter.setTitle("释放更新", for: .pulling)
        refreshFooter.setTitle("加载加载加载", for: .refreshing)//正在刷新的状态
        refreshFooter.setTitle("没有没有更多数据了", for: .noMoreData)//数据加载完毕的状态
        //将上拉加载的控件与 tableView控件绑定起来
        self.recordTableView.mj_footer = refreshFooter
        getListData(searchStr:"", state:"")
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        print("下拉刷新")
        pageStart = 0
        //服务器请求数据的函数
        if pageStatus == "" {
            getListData(searchStr:"", state:"")
        }else{
            getListData(searchStr:"", state:Int(pageStatus)!-1)
        }
        
        //结束下拉刷新
        self.recordTableView.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
        print("上拉刷新")
        pageStart += 10
        //服务器请求数据的函数
        if pageStatus == "" {
            getListData(searchStr:"", state:"")
        }else{
            getListData(searchStr:"", state:Int(pageStatus)!-1)
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
        dateLabel.text = "\(dateComponents.year!)" + "-" + formateNum(num: dateComponents.month!)
        print("dateComponents = ", dateComponents)
        getHeaderData()
        getListData(searchStr: "", state: "")
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        pageStart = 0
        switch buttonIndex {
        case 0:
            pageStatus = ""
            getListData(searchStr: "", state: "")
        case 1:
            pageStatus = "\(buttonIndex)"
            getListData(searchStr: "", state: 0)
        default:
            pageStatus = "\(buttonIndex)"
            getListData(searchStr: "", state: 1)
        }
        
    }
}
extension DailyRecordViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.json == nil {
            return 0
        }else{
            return self.json.count
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
        
        if self.json != nil {
//            print(self.listData[indexPath.row])
//            print(type(of: self.json[indexPath.row]))
            //当无图片时显示默认图片
            let views = cell?.itemImage?.subviews
            for itemImageSub in views! {
                itemImageSub.removeFromSuperview()
            }
            if self.json[indexPath.row]["filesId"].stringValue == "" {
                print(self.json[indexPath.row]["filesId"])
                cell?.itemImage?.image = UIImage(named: "默认图片")
            }else{
                let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (self.json[indexPath.row]["filesId"].stringValue.components(separatedBy: ",")[0])
                cell?.itemImage?.dowloadFromServer(link: imgurl as String, contentMode: .scaleAspectFit)
                let photoNum = UILabel.init(frame: CGRect(x: 0, y: (cell?.itemImage?.frame.height ?? 60)-20.0, width: (cell?.itemImage?.frame.width ?? 80), height: 20))
                photoNum.text = "共\(self.json[indexPath.row]["filesId"].stringValue.components(separatedBy: ",").count)张"
                photoNum.textColor = UIColor.white
                photoNum.textAlignment = .center
                photoNum.font = UIFont(name: "PingFangSC-Regular", size: 13.0)
                photoNum.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.5)
                cell?.itemImage?.addSubview(photoNum)
            }
            cell?.itemTitle?.text =  self.json[indexPath.row]["title"].stringValue
            if self.json[indexPath.row]["state"].stringValue == "1" {
                cell?.itemStatus?.text = "已处理"
            }else{
                cell?.itemStatus?.text = "未处理"
            }
            cell?.itemId = self.json[indexPath.row]["id"].stringValue
            //默认颜色是已处理的，所以在未处理时更改颜色
            if self.json[indexPath.row]["state"] == 0 {
                cell?.itemStatus?.layer.borderColor = topValueColor.cgColor
                cell?.itemStatus?.textColor = topValueColor
            }else{
                cell?.itemStatus?.layer.borderColor = UIColor(red: 143/255, green: 144/255, blue: 145/255, alpha: 1).cgColor
                cell?.itemStatus?.textColor = UIColor(red: 158/255, green: 159/255, blue: 160/255, alpha: 1)
            }
            cell?.itemDate?.text = AddDailyRecordViewController.timeStampToString(timeStamp: self.json[indexPath.row]["opeTime"].stringValue,timeAccurate: "minute")
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let deleteRecordCell = tableView.cellForRow(at: indexPath) as! RecordListTableViewCell
        if editingStyle == .delete {
            deleteListItem(itemId: deleteRecordCell.itemId, itemIndexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
}
