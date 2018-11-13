//
//  DailySearchViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/25.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON

class DailySearchViewController: UIViewController {
    
    var searchBar: UISearchBar!
    var nearlyCollectionview:UICollectionView!
    var nearLyData:NSMutableArray!
    
    var historyView:UIView!
    
    var searchResultView:UITableView!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var searchDate:String!
    var listData:NSMutableArray = []
    var json:JSON!
    var pageStart = 0
    let pageSize = 10
    let CellIdentifier = "MyCell"
    
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
    
    func createSearchView(){
        searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 20, width: kScreenWidth, height: 44))
        searchBar.placeholder = "搜索"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        
    }
    
    func createHistoryUI(){
        historyView = UIView.init(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight-64))
        historyView.backgroundColor = UIColor.white
        self.view.addSubview(historyView)
        
        let historyTitle = UILabel.init(frame: CGRect(x: 20, y: 10, width: kScreenWidth, height: 20))
        historyTitle.text = "最近搜索"
        historyTitle.font = UIFont(name: "PingFangSC-Regula", size: 15)
        historyTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        historyView.addSubview(historyTitle)
        
        nearLyData = [1,2,3,4,5]
        
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
    
    func createTabList() {
        searchResultView = UITableView.init(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight-64))
        searchResultView.delegate = self
        searchResultView.dataSource = self
        searchResultView.separatorStyle = .none
        searchResultView.backgroundColor = allListBackColor
        self.view.addSubview(searchResultView)
        searchResultView.register(RecordListTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
    }
    
    ///5.获取tabList需要的数据（日常记录条数）
    /// - Parameter searchStr: 搜索的字符串
    /// - Parameter state：是否被处理的状态码
    /// - Parameter pageNum：起始页吗数
    /// - Parameter pageSize：每页条数
    func getListData(searchStr:String, state:Any) {
        MyProgressHUD.showStatusInfo("加载中...")
        let infoData = ["title":searchStr, "state":state, "start":pageStart, "length":pageSize, "startday":"\(searchDate!)-01", "endDay":"\(changeDate(chageType: 2))-01"] as [String : Any]
        let contentData : [String : Any] = ["method":"getOptionlist","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.json = JSON(value)["data"]["resultData"]
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
    
    func changeDate(chageType:Int)->String{
        var year = ((searchDate?.split(separator: "-")[0])! as NSString).integerValue
        var month = ((searchDate?.split(separator: "-")[1])! as NSString).integerValue
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

extension DailySearchViewController:UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getListData(searchStr:searchBar.text!, state:"")
    }
    //Including clear
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText == ""{
            self.view.addSubview(historyView)
        }
    }
}

extension DailySearchViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearLyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dailyNearlyCollectionCell", for: indexPath) as! DailyNearlyCollectionViewCell
        
        cell.label.text = "\(nearLyData[indexPath.row])"
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
//            print(self.json[indexPath.row)
            //当无图片时显示默认图片
            if self.json[indexPath.row]["filesId"].array?.count == 0 {
                print(self.json[indexPath.row]["filesId"])
                cell?.itemImage?.image = UIImage(named: "默认图片")
            }else{
                cell?.itemImage?.image = UIImage(named: "默认图片")
                let photoNum = UILabel.init(frame: CGRect(x: 0, y: (cell?.itemImage?.frame.height ?? 60)-20.0, width: (cell?.itemImage?.frame.width ?? 80), height: 20))
                photoNum.text = "共\(self.json[indexPath.row]["filesId"].count)张"
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
            cell?.itemDate?.text = self.json[indexPath.row]["staTime"].stringValue
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
