//
//  DailySearchViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/25.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

class DailySearchViewController: UIViewController {
    
    var searchBar: UISearchBar!
    var nearlyCollectionview:UICollectionView!
    var getNearlyData:[AnyObject]! = []
    var setNearlyData:NSMutableArray! = []
    
    var historyView:UIView!
    var clearBtn:UIButton!
    
    var searchResultView:UITableView!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var searchDate:String!
    var json:JSON!
    var pageStart = 0
    let pageSize = 10
    let CellIdentifier = "MyCell"
    var searchDateTool = HandleDate()
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    // 底部加载
    let refreshFooter = MJRefreshAutoNormalFooter()
    var dataToEnd = false
    var searchData:[DailyRecordViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        searchDate = self.userDefault.object(forKey: "searchMonth") as? String
        
        createSearchView()
        createHistoryUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func createSearchView(){
        searchBar = UISearchBar.init(frame: CGRect(x: 0, y: statusBarHeight, width: kScreenWidth, height: 44))
        searchBar.placeholder = "搜索"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none//关闭首字母大写
        searchBar.becomeFirstResponder()//进入页面使搜索框进入选中状态
    }
    
    func createHistoryUI(){
        historyView = UIView.init(frame: CGRect(x: 0, y: navigationHeight, width: kScreenWidth, height: kScreenHeight-navigationHeight))
        historyView.backgroundColor = UIColor.white
        self.view.addSubview(historyView)
        
        let historyTitle = UILabel.init(frame: CGRect(x: 20, y: 10, width: kScreenWidth-60, height: 20))
        historyTitle.text = "最近搜索"
        historyTitle.font = UIFont(name: "PingFangSC-Regula", size: 15)
        historyTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        historyView.addSubview(historyTitle)
        
        clearBtn = UIButton.init(frame: CGRect(x: kScreenWidth-40, y: 10, width: 20, height: 20))
        clearBtn.setImage(UIImage(named: "historyClear"), for: UIControlState.normal)
        clearBtn.addTarget(self, action: #selector(clearHistory(sender:)), for: UIControlEvents.touchUpInside)
        clearBtn.isHidden = true
        historyView.addSubview(clearBtn)
        
        getNearlyData = self.userDefault.object(forKey: "historyData") as? [AnyObject]
        if getNearlyData == nil || getNearlyData.count == 0 {
            getNearlyData = []
        }else{
            clearBtn.isHidden = false
        }
        setNearlyData = NSMutableArray.init(array: getNearlyData)
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        nearlyCollectionview = UICollectionView(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 120), collectionViewLayout: layout)
        nearlyCollectionview.backgroundColor = UIColor.white
        nearlyCollectionview.tag = 1
        nearlyCollectionview.delegate = self
        nearlyCollectionview.dataSource = self
        historyView.addSubview(nearlyCollectionview)
        
        nearlyCollectionview.alwaysBounceHorizontal = true
        nearlyCollectionview.showsHorizontalScrollIndicator = false
        
        nearlyCollectionview.register(DailyNearlyCollectionViewCell().classForCoder, forCellWithReuseIdentifier: "dailyNearlyCollectionCell")
    }
    
    @objc func clearHistory(sender:UIButton){
        if getNearlyData == nil {
            getNearlyData = []
        }else if getNearlyData.count > 0{
            self.setNearlyData = []
            getNearlyData = []
            nearlyCollectionview.reloadData()
            clearBtn.isHidden = true
            self.userDefault.set(self.setNearlyData, forKey: "historyData")
        }
        
    }
    
    func createTabList() {
        searchResultView = UITableView.init(frame: CGRect(x: 0, y: navigationHeight, width: kScreenWidth, height: kScreenHeight-navigationHeight))
        searchResultView.delegate = self
        searchResultView.dataSource = self
        searchResultView.separatorStyle = .none
        searchResultView.backgroundColor = allListBackColor
        self.view.addSubview(searchResultView)
        searchResultView.register(RecordListTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
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
        self.searchResultView.mj_header = refresHeader
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
        self.searchResultView.mj_footer = refreshFooter
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        //        print("下拉刷新")
        pageStart = 0
        //服务器请求数据的函数
        getListData(searchStr:searchBar.text!, state:"")
        
        //结束下拉刷新
        self.searchResultView.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
        //        print("上拉加载")
        if dataToEnd == false {
            pageStart += 10
            //服务器请求数据的函数
            getListData(searchStr:searchBar.text!, state:"")
        }
        //结束下拉刷新
        self.searchResultView.mj_footer.endRefreshing()
    }
    
    ///5.获取tabList需要的数据（日常记录条数）
    /// - Parameter searchStr: 搜索的字符串
    /// - Parameter state：是否被处理的状态码
    /// - Parameter pageNum：起始页吗数
    /// - Parameter pageSize：每页条数
    func getListData(searchStr:String, state:Any) {
        MyProgressHUD.showStatusInfo("加载中...")
        self.dataToEnd = false
        if pageStart == 0 {
            searchData = []
        }
        
        let infoData = ["title":searchStr, "state":state, "start":pageStart, "length":pageSize, "startDay": searchDateTool.getNeedDate(changeDate: searchDate!, startOrEnd: 0), "endDay":searchDateTool.getNeedDate(changeDate: searchDate!, startOrEnd: 1)] as [String : Any]
        let contentData : [String : Any] = ["method":"getOptionlist","info":infoData,"token":userToken,"user_id":userId]
        
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
//            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.json = JSON(value)["data"]["resultData"]
                    self.setSearchtextToLocal()
                    for recordItem in self.json.enumerated(){
                        let recordModel = DailyRecordViewModel(describe: self.json[recordItem.offset]["describe"].stringValue, filesId: self.json[recordItem.offset]["filesId"].stringValue, id: self.json[recordItem.offset]["id"].intValue, opeTime: self.json[recordItem.offset]["opeTime"].intValue, staId: self.json[recordItem.offset]["staId"].intValue, staName: self.json[recordItem.offset]["staName"].stringValue, staTime: self.json[recordItem.offset]["staTime"].intValue, state: self.json[recordItem.offset]["state"].intValue, title: self.json[recordItem.offset]["title"].stringValue, userId: self.json[recordItem.offset]["userId"].intValue, userName: self.json[recordItem.offset]["userName"].stringValue)
                        self.searchData.append(recordModel)
                    }
                    if self.searchData.count >= JSON(value)["data"]["resultData"]["iTotalRecords"].intValue {
                        self.dataToEnd = true
                        self.refreshFooter.state = .noMoreData
                    }else{
                        self.refreshFooter.state = .idle
                    }
                    self.createTabList()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    print(type(of: JSON(value)["msg"]))
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
    
    func setSearchtextToLocal(){
        if self.setNearlyData == [] {
            self.setNearlyData.add(self.searchBar.text!)
            self.userDefault.set(self.setNearlyData, forKey: "historyData")
        }else{
            var hasValue = false
            for searchItem in setNearlyData.enumerated() {
                if searchBar.text == (setNearlyData[searchItem.offset] as AnyObject).description {
                    hasValue = true
                }
            }
            if hasValue == true {
                return
            }else{
                if self.getNearlyData.count == 5{
                    self.setNearlyData.removeObject(at: 0)
                    self.setNearlyData.add(self.searchBar.text!)
                    self.userDefault.set(self.setNearlyData, forKey: "historyData")
                }else{
                    self.setNearlyData.add(self.searchBar.text!)
                    self.userDefault.set(self.setNearlyData, forKey: "historyData")
                }
            }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
    }

}

extension DailySearchViewController:UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.changeSearchBarCancelBtnTitleColor(view: searchBar)
        getListData(searchStr:searchBar.text!, state:"")
    }
    
    //Including clear
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText == ""{
            createHistoryUI()
        }
    }
    
    func changeSearchBarCancelBtnTitleColor(view:UIView){
        if view.isKind(of: UIButton.self) {
            let getBtn = view as! UIButton
            getBtn.isEnabled = true
            getBtn.isUserInteractionEnabled = true
            getBtn.setTitleColor(UIColor.pg_color(withHexString: "#0374f2"), for: UIControlState.reserved)
            getBtn.setTitleColor(UIColor.pg_color(withHexString: "#0374f2"), for: UIControlState.disabled)
        }else{
            for subview in view.subviews{
                self.changeSearchBarCancelBtnTitleColor(view: subview)
            }
        }
    }
}

extension DailySearchViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if getNearlyData == nil {
            return 0
        }else{
           return getNearlyData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dailyNearlyCollectionCell", for: indexPath) as! DailyNearlyCollectionViewCell
        if getNearlyData.count > 0 {
            cell.label.text = "\(getNearlyData[indexPath.row])"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! DailyNearlyCollectionViewCell
        searchBar.text = cell.label.text
        historyView.removeFromSuperview()
        getListData(searchStr:searchBar.text!, state:"")
//        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize.init(width: (kScreenWidth-70)/4, height: 25)
        
    }
    //cell左右边距
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    //cell上下边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    //设置section的内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //{top, left, bottom, right};
        return UIEdgeInsetsMake(10, 25, 10, 25) // margin between sections
    }
    //设置sectionHeader的大小
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize.zero
    }
    
}
extension DailySearchViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchData == [] {
            return 0
        }else{
            return self.searchData.count
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
        if self.searchData != [] {
            //            print(self.listData[indexPath.row])
            //            print(type(of: self.json[indexPath.row]))
            //当无图片时显示默认图片
            let views = cell?.itemImage?.subviews
            for itemImageSub in views! {
                itemImageSub.removeFromSuperview()
            }
            if self.searchData[indexPath.row].filesId == "" {
                //                print(self.listData[indexPath.row].filesId)
                cell?.itemImage?.image = UIImage(named: "默认图片")
            }else{
                let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (self.searchData[indexPath.row].filesId.components(separatedBy: ",")[0])
                cell?.itemImage?.dowloadFromServer(link: imgurl as String, contentMode: .scaleAspectFit)
                let photoNum = UILabel.init(frame: CGRect(x: 0, y: (cell?.itemImage?.frame.height ?? 60)-20.0, width: (cell?.itemImage?.frame.width ?? 80), height: 20))
                photoNum.text = "共\(self.searchData[indexPath.row].filesId.components(separatedBy: ",").count)张"
                photoNum.textColor = UIColor.white
                photoNum.textAlignment = .center
                photoNum.font = UIFont(name: "PingFangSC-Regular", size: 13.0)
                photoNum.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.5)
                cell?.itemImage?.addSubview(photoNum)
            }
            cell?.itemTitle?.text =  self.searchData[indexPath.row].title
            cell?.itemId = self.searchData[indexPath.row].id.description
            cell?.itemCreator?.text = "发布人:" + self.searchData[indexPath.row].userName.description
            //默认颜色是已处理的，所以在未处理时更改颜色
            if self.searchData[indexPath.row].state.description == "0" {
                cell?.itemStatus?.text = "未处理"
                cell?.itemStatus?.layer.borderColor = topValueColor.cgColor
                cell?.itemStatus?.textColor = topValueColor
                cell?.itemHandler?.isHidden = true
            }else{
                cell?.itemStatus?.text = "已处理"
                cell?.itemStatus?.layer.borderColor = UIColor(red: 143/255, green: 144/255, blue: 145/255, alpha: 1).cgColor
                cell?.itemStatus?.textColor = UIColor(red: 158/255, green: 159/255, blue: 160/255, alpha: 1)
                cell?.itemHandler?.isHidden = false
                cell?.itemHandler?.text = "处理人:" + self.searchData[indexPath.row].staName.description
            }
            cell?.itemDate?.text = AddDailyRecordViewController.timeStampToString(timeStamp: self.searchData[indexPath.row].opeTime.description,timeAccurate: "minute")
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
    
    
}
