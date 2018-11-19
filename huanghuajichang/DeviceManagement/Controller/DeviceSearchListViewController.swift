//
//  DeviceSearchListViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceSearchListViewController: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    //原始数据集
    var schoolArray : NSMutableArray = []
    var historyList :[String] = []
    var historyView : UIView?
    
    var mTableView : UITableView!
    var shouldShowSearchResults = false
    //搜索控制器
    var countrySearchController :UISearchController!
    //搜索过滤后的结果集
    var searchArray:[String] = [String](){
        didSet  {self.mTableView.reloadData()}
    }
    var top : CGFloat = 0
    var tableViewFrame :CGRect!
    let searchInput = UITextField()
    var searchArrayIdList : [Int] = [Int]()
    let deviceSearchListViewService = DeviceSearchListViewService()
    let userDefult = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewStyle()
        historyList += userDefult.array(forKey: "appHistoryListForDevice") as? [String] ?? []
        if historyList.count > 0{
            setHistoryView()
        }
    }
    
    func getData(searchName:String,call:@escaping ()->()){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentList","user_id": userId as Any,"token": token as Any,"info":["oneId":"","twoId":"","equName":searchName]]
        deviceSearchListViewService.getData(contentData: contentData, finished: { (result, resultDataList) in
            self.searchArray.removeAll()
            self.searchArrayIdList.removeAll()
            for i in 0..<resultDataList.count{
                let itemName = resultDataList[i]["equName"]
                self.searchArray.append(itemName as! String)
                let itemId = resultDataList[i]["equId"]
                self.searchArrayIdList.append(itemId as! Int)
            }
            call()
        }) { (errorData) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool){
        self.title = "搜索设备"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
    }
    
    //MARK:设置界面样式
    func setViewStyle(){
        top = UIApplication.shared.statusBarFrame.height
        view.backgroundColor = UIColor.white
        
        //search
//        let historySearchListView = HistorySearchListView()
        countrySearchController = UISearchController(searchResultsController: nil)
        countrySearchController.searchBar.delegate = self
//        countrySearchController.searchBar.frame = CGRect(x: 60, y: 0, width: KUIScreenWidth-60, height: 40)
        //默认情况下，UISearchController暗化前一个view，这在我们使用另一个view controller来显示结果时非常有用，但当前情况我们并不想暗化当前view，即设置开始搜索时背景是否显示
        countrySearchController.dimsBackgroundDuringPresentation = false
        countrySearchController.searchBar.placeholder = "搜索框"
        //设置代理，searchResultUpdater是UISearchController的一个属性，它的值必须实现UISearchResultsUpdating协议，这个协议让我们的类在UISearchBar文字改变时被通知到，我们之后会实现这个协议。
        countrySearchController.searchResultsUpdater = self
        countrySearchController.searchBar.searchBarStyle = .minimal
        
//        countrySearchController.view.backgroundColor = UIColor.red
//        print("打印：\(countrySearchController.view.subviews[0].subviews)")
        
//         设置开始搜索时导航条是否隐藏
        countrySearchController.hidesNavigationBarDuringPresentation = true
        //设置definesPresentationContext为true，我们保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上。
        countrySearchController.definesPresentationContext = true
        
        //创建表视图 list
        tableViewFrame = CGRect(x: 0, y:0, width: view.frame.width,
                                height: view.frame.height)
        self.mTableView = UITableView(frame: tableViewFrame, style:.plain)
        self.mTableView!.delegate = self
        self.mTableView!.dataSource = self
        self.mTableView.separatorStyle = .none
        //创建一个重用的单元格
        self.mTableView!.register(UITableViewCell.self,
                                  forCellReuseIdentifier: "MyCell")
        mTableView.tableHeaderView = countrySearchController.searchBar
        self.view.addSubview(self.mTableView!)
        
    }
    
    
    @objc func goBack(){
        print("关闭当前页")
        if self.countrySearchController.isActive{
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    //MARK：自定义状态栏的背景颜色
    func setStatusBarBackgroundColor(color : UIColor) {
        let statusBarWindow : UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let statusBar : UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
    
    func setHistoryView(){
        historyView = UIView(frame:CGRect(x: 0, y: 40+UIApplication.shared.statusBarFrame.size.height+(self.navigationController?.navigationBar.frame.height)!, width: KUIScreenWidth, height: 80))
        let mLabelTitle = UILabel(frame: CGRect(x: 40, y: 10, width: KUIScreenWidth, height: 40))
        mLabelTitle.font = UIFont.boldSystemFont(ofSize: 12)
        mLabelTitle.textColor = UIColor.black
        mLabelTitle.text = "历史搜索记录"
        for i in 0..<historyList.count{
            let mBut = UIButton(frame: CGRect(x: 40+i*60, y: 60, width: 50, height: 20))
            mBut.setTitle(historyList[i], for: UIControlState.normal)
            mBut.setTitleColor(UIColor.gray, for: UIControlState.normal)
            mBut.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            mBut.layer.cornerRadius = 5
            mBut.layer.borderWidth = 1
            mBut.layer.backgroundColor = UIColor.white.cgColor
            mBut.layer.borderColor = UIColor.gray.cgColor
            mBut.addTarget(self, action: #selector(toSearchData), for: UIControlEvents.touchUpInside)
            historyView?.addSubview(mBut)
        }
        historyView?.addSubview(mLabelTitle)
        self.view.addSubview(historyView!)
        
    }
    
    //MARK:删除历史搜索图层
    func remHistoryView(){
        historyView?.removeFromSuperview()
    }
    @objc func toSearchData(button:UIButton){
        print(button.titleLabel?.text as Any)
        countrySearchController.searchBar.becomeFirstResponder()
        countrySearchController.searchBar.text = button.title(for: UIControlState.normal)
        getData(searchName: button.title(for: UIControlState.normal)!) {
            //            let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
            //            self.searchArray = (self.schoolArray.filtered(using: predicate) as NSArray) as! [String]
            self.shouldShowSearchResults = true
            self.historyView?.isHidden = true
            self.mTableView.separatorStyle = .singleLine
            self.historyList.insert(String(button.title(for: UIControlState.normal)!), at: 0)
            if self.historyList.count > 5{
                self.historyList.remove(at: 4)
            }
            self.userDefult.set(self.historyList, forKey: "appHistoryListForDevice")
            self.mTableView.reloadData()
        }
    }
    
}

extension DeviceSearchListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.countrySearchController.isActive {
           return self.searchArray.count
        } else {
            if shouldShowSearchResults{
                return self.searchArray.count
            }else{
                return 0
            }
            

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //为了提供表格显示性能，已创建完成的单元需重复使用
        let identify:String = "MyCell"
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,
                                                 for: indexPath)
        
        let rowNum = indexPath.row
        if self.countrySearchController.isActive {
            cell.textLabel?.text = self.searchArray[rowNum]
            cell.tag = Int(self.searchArrayIdList[rowNum])
            return cell
        } else {
            if shouldShowSearchResults{
                cell.textLabel?.text = self.searchArray[rowNum]
                return cell
            }else{
                cell.textLabel?.text = ""//self.searchArray[rowNum]
                return cell
            }
            
        }
    }
    
}

extension DeviceSearchListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.countrySearchController.isActive{
            self.dismiss(animated: false, completion: nil)
        }
        let deviceDetaillController = DeviceDetailViewController()
        deviceDetaillController.flagePageFrom = 2
        deviceDetaillController.equId = self.searchArrayIdList[indexPath.row]
        navigationController?.pushViewController(deviceDetaillController, animated: true)
    }
    
}

//扩展SearchViewController实现UISearchBarDelegate
extension DeviceSearchListViewController:UISearchBarDelegate,UISearchResultsUpdating{
    //开始进行文本编辑，设置显示搜索结果，刷新列表
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        historyView?.isHidden = true
        self.mTableView.separatorStyle = .singleLine
        mTableView.reloadData()
    }

    //点击Cancel按钮，设置不显示搜索结果并刷新列表
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        if historyList.count > 0{
            setHistoryView()
        }
        historyView?.isHidden = false
        self.mTableView.separatorStyle = .none
        mTableView.reloadData()
        //
    }

    //点击搜索按钮，触发该代理方法，如果已经显示搜索结果，那么直接去除键盘，否则刷新列表
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getData(searchName: searchBar.text!) {
//            let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
//            self.searchArray = (self.schoolArray.filtered(using: predicate) as NSArray) as! [String]
            self.shouldShowSearchResults = true
            self.historyView?.isHidden = true
            self.mTableView.separatorStyle = .singleLine
            self.historyList.insert(String(searchBar.text!), at: 0)
            if self.historyList.count > 5{
                self.historyList.remove(at: 4)
            }
            self.userDefult.set(self.historyList, forKey: "appHistoryListForDevice")
            self.mTableView.reloadData()
        }
       
    }

    //点击书签按钮，触发该代理方法
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar){
       
    }

    //这个updateSearchResultsForSearchController(_:)方法是UISearchResultsUpdating中唯一一个我们必须实现的方法。当search bar 成为第一响应者，或者search bar中的内容被改变将触发该方法.不管用户输入还是删除search bar的text，UISearchController都会被通知到并执行上述方法。
    func updateSearchResults(for searchController: UISearchController) {

        //刷新表格
        mTableView.reloadData()
    }
}
