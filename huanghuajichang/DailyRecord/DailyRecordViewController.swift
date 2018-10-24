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

class DailyRecordViewController: BaseViewController,PGDatePickerDelegate {
    
    let dateLabel:UILabel = UILabel()
    
    let buttons:[ThickButtonModel] = [ThickButtonModel(value: 10, describe: "全部"), ThickButtonModel(value: 5, describe: "未处理"), ThickButtonModel(value:5, describe:"已处理")]
    
    let thickbuttons = ThickButton()
    
    // view
    var  buttonsView:UIView!
    
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    // 底部刷新
    let refreshFooter = MJRefreshAutoNormalFooter()
    
    var recordTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日常记录"
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        // Do any additional setup after loading the view.
        createRightBtns()
        createFixedUI()
        createHeader()
        createTabList()
    }
    
    ///绘制navigationBar的右侧按钮组
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
        print("打开搜索页面")
    }
    
    @objc func openAdd(){
        let addVc = AddDailyRecordViewController()
        let addNav = UINavigationController(rootViewController: addVc)
        self.present(addNav, animated: true, completion: nil)
    }
    
    ///绘制日历工具栏
    func createFixedUI(){
        let dateChangeView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        dateChangeView.backgroundColor = UIColor(red: 232/255, green: 243/255, blue: 255/255, alpha: 1)
        self.view.addSubview(dateChangeView)
        
        //左侧按钮
        let lastMonthBtn = UIButton.init(frame: CGRect(x: 20, y: 10, width: 20, height: 20))
        lastMonthBtn.setImage(UIImage(named: "上一天"), for: UIControlState.normal)
        lastMonthBtn.tag = 1
        lastMonthBtn.addTarget(self, action: #selector(changeDate(sender:)), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(lastMonthBtn)
        
        //日期插件
        dateLabel.frame.size = CGSize(width: 60, height: 20)
        dateLabel.center.x = self.view.center.x
        dateLabel.frame.origin.y = 10
        dateLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        dateLabel.text = "2018-02"
        dateChangeView.addSubview(dateLabel)
        
        let dateBtn = UIButton.init(frame: CGRect(x: dateLabel.frame.origin.x+dateLabel.frame.width+5, y: 10, width: 20, height: 20))
        dateBtn.setImage(UIImage(named: "日期"), for: UIControlState.normal)
        dateBtn.addTarget(self, action: #selector(opendatePicker), for: UIControlEvents.touchUpInside)
        dateChangeView.addSubview(dateBtn)
        
        //右侧按钮
        let nextMonthBtn = UIButton.init(frame: CGRect(x: kScreenWidth-40, y: 10, width: 20, height: 20))
        nextMonthBtn.setImage(UIImage(named: "下一天"), for: UIControlState.normal)
        nextMonthBtn.tag = 2
        nextMonthBtn.addTarget(self, action: #selector(changeDate(sender:)), for: UIControlEvents.touchUpInside)
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
    
    @objc func changeDate(sender:UIButton?){
        var year = ((dateLabel.text?.split(separator: "-")[0])! as NSString).integerValue
        var month = ((dateLabel.text?.split(separator: "-")[1])! as NSString).integerValue
        switch sender?.tag {
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
//        print("year:\(year)"+";"+"month:"+formateNum(num:month))
        dateLabel.text = "\(year)" + "-" + formateNum(num: month)
    }
    
    ///绘制列表头
    func createHeader(){
        let HeaderView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 103))
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
    }
    
    func createTabList(){
        recordTableView = UITableView.init(frame: CGRect(x: 0, y: 143, width: kScreenWidth, height: kScreenHeight-144-64-49))
        recordTableView.delegate = self
        recordTableView.dataSource = self
        recordTableView.separatorStyle = .none
        recordTableView.backgroundColor = allListBackColor
        self.view.addSubview(recordTableView)
        recordTableView.register(RecordListTableViewCell.self, forCellReuseIdentifier: "MyCell")
        initMJRefresh()
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
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        print("下拉刷新")
        //服务器请求数据的函数
//        self.getTableViewData()
        //重新加载tableView数据
        //self.my_tableview.reloadData()
        //结束下拉刷新
        self.recordTableView.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
        print("上拉刷新")
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

}
extension DailyRecordViewController:ThickButtonDelagate{
    //#MARK - ThickButtonDelagate
    //实现按钮控制页面的切换
    func clickChangePage(_ thickButton: ThickButton, buttonIndex: NSInteger) {
        print(buttonIndex)
    }
}
extension DailyRecordViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    //设置每行的单元格的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? RecordListTableViewCell
        if cell == nil{
            cell = RecordListTableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
//        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.itemImage?.image = UIImage(named: "默认图片")
        cell?.itemTitle?.text = "标题能源管配电站航空港110KV变电变站\(indexPath.row)"
        cell?.itemStatus?.text = "已处理"
        cell?.itemDate?.text = "2018-10-19"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectdRecordCell = tableView.cellForRow(at: indexPath) as! RecordListTableViewCell
        print((selectdRecordCell.itemTitle?.text)!)
        
        let scanVc = ScanAndEditViewController()
        let scanNav = UINavigationController(rootViewController: scanVc)
        self.present(scanNav, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
