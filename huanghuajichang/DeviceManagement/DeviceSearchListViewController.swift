//
//  DeviceSearchListViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DeviceSearchListViewController: UIViewController,UITextFieldDelegate {
    
    //原始数据集
    let schoolArray : NSMutableArray = ["清华大学","北京大学","中国人民大学","北京交通大学","北京工业大学",
                                        "北京航空航天大学","北京理工大学","北京科技大学","中国政法大学","中央财经大学","华北电力大学",
                                        "北京体育大学","上海外国语大学","复旦大学","华东师范大学","上海大学","河北工业大学"]
    let historyList :[String] = ["历史1","历史2","历史3","历史4","历史5"]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewStyle()
//        self.reloadViewStyle()
    }
    
    //MARK:设置界面样式
    func setViewStyle(){
        top = UIApplication.shared.statusBarFrame.height
        view.backgroundColor = UIColor.white
        //header
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: top+80))
        viewHeader.backgroundColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        let leftButton = UIButton(frame: CGRect(x: 0, y: top, width: 40, height: 40))
        leftButton.setImage(UIImage(named: "返回"), for: UIControlState.normal)
        leftButton.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        let headerText = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        headerText.textAlignment = .center
        headerText.textColor = UIColor.white
        headerText.text = "设备搜索"
        headerText.center.x = UIScreen.main.bounds.size.width/2
        headerText.center.y = 20+top
        viewHeader.addSubview(leftButton)
        viewHeader.addSubview(headerText)
        view.addSubview(viewHeader)
        
        //自定义搜索样式
//        let searchView = UIView(frame: CGRect(x: 20, y: top+80, width: UIScreen.main.bounds.size.width-40, height: 40))
//        searchView.backgroundColor = UIColor.white
//        searchView.layer.borderWidth = 1
//        searchView.layer.borderColor = UIColor.gray.cgColor
//        searchView.layer.cornerRadius = 20
//        searchView.center.x = UIScreen.main.bounds.size.width/2
//        searchView.center.y = 20
//
//        let searchImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        searchImg.image = UIImage(named: "搜索-1")
//        searchView.addSubview(searchImg)
//
//        searchInput.frame = CGRect(x: 60, y: 0, width: UIScreen.main.bounds.size.width-120, height: 40)
//        searchInput.textAlignment = .left
//        searchInput.adjustsFontForContentSizeCategory = true//字体超出输入框长度，字体可以自动缩放
//        searchInput.minimumFontSize = 10//最小字体大小
//        searchInput.contentVerticalAlignment = .center//垂直居中
//        searchInput.clearButtonMode = .whileEditing //编辑时出现清除按钮
//        searchInput.keyboardType = .default
//        searchInput.returnKeyType = .search
//        searchView.addSubview(searchInput)
//
//        let cancelBut = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width-60, y: 0, width: 60, height: 40))
//        cancelBut.setTitle("取消", for: UIControlState.normal)
//        cancelBut.setTitle("取消", for: UIControlState.highlighted)
//        searchView.addSubview(cancelBut)
//        view.addSubview(searchView)
        //search
        countrySearchController = UISearchController(searchResultsController: nil)
        countrySearchController.searchBar.delegate = self
        countrySearchController.dimsBackgroundDuringPresentation = true
        countrySearchController.searchBar.placeholder = "搜索框"
        countrySearchController.searchResultsUpdater = self
        countrySearchController.searchBar.searchBarStyle = .minimal
        // 设置开始搜索时导航条是否隐藏
        countrySearchController.hidesNavigationBarDuringPresentation = false
        // 设置开始搜索时背景是否显示
        countrySearchController.dimsBackgroundDuringPresentation = false
        
        //创建表视图 list
        tableViewFrame = CGRect(x: 0, y: top+40, width: view.frame.width,
                                height: view.frame.height)
        self.mTableView = UITableView(frame: tableViewFrame, style:.plain)
        self.mTableView!.delegate = self
        self.mTableView!.dataSource = self
        //        mTableView.separatorStyle = .none
        //创建一个重用的单元格
        self.mTableView!.register(UITableViewCell.self,
                                  forCellReuseIdentifier: "MyCell")
        mTableView.tableHeaderView = countrySearchController.searchBar
        self.view.addSubview(self.mTableView!)
        
    }
    
    @objc func goBack(){
        print("关闭当前页")
        if self.countrySearchController.isActive{
            self.dismiss(animated: false, completion: ({
                self.dismiss(animated: false, completion: nil)
            }))
        }else{
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    
}

extension DeviceSearchListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.countrySearchController.isActive {
            return self.searchArray.count
        } else {

            return self.schoolArray.count

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //为了提供表格显示性能，已创建完成的单元需重复使用
        let identify:String = "MyCell"
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,
                                                 for: indexPath)
        
        if self.countrySearchController.isActive {
            cell.textLabel?.text = self.searchArray[indexPath.row]
            return cell
        } else {
            cell.textLabel?.text = self.schoolArray[indexPath.row] as? String
            return cell
        }
    }
    
}

extension DeviceSearchListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
    
}

//扩展SearchViewController实现UISearchBarDelegate
extension DeviceSearchListViewController:UISearchBarDelegate,UISearchResultsUpdating{
    //开始进行文本编辑，设置显示搜索结果，刷新列表
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        mTableView.reloadData()
    }

    //点击Cancel按钮，设置不显示搜索结果并刷新列表
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        mTableView.reloadData()
        //
    }

    //点击搜索按钮，触发该代理方法，如果已经显示搜索结果，那么直接去除键盘，否则刷新列表
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
        searchArray = (self.schoolArray.filtered(using: predicate) as NSArray) as! [String]
        print(searchArray)
        mTableView.reloadData()
    }

    //点击书签按钮，触发该代理方法
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar){
        //        print(historyList)
        //        print(searchBar.isSearchResultsButtonSelected)
        //        if countrySearchController.searchBar.isSearchResultsButtonSelected{
        //            let historyView = HistorySearchListView()
        //            self.view.addSubview(historyView)
        //        }
    }

    //这个updateSearchResultsForSearchController(_:)方法是UISearchResultsUpdating中唯一一个我们必须实现的方法。当search bar 成为第一响应者，或者search bar中的内容被改变将触发该方法.不管用户输入还是删除search bar的text，UISearchController都会被通知到并执行上述方法。
    func updateSearchResults(for searchController: UISearchController) {

        //刷新表格
        mTableView.reloadData()
    }
}

extension DeviceSearchListViewController {
    func reloadViewStyle(){
        let historyView = HistorySearchListView()
        historyView.setHistory(historyList: historyList)
//        tableViewFrame = CGRect(x: 0, y: top+340, width: view.frame.width,
//                                height: view.frame.height)
//        self.view.addSubview(historyView)
//        self.mTableView = UITableView(frame: tableViewFrame, style:.plain)
    }
    
}
