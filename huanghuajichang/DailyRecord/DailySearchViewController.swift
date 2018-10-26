//
//  DailySearchViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/25.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DailySearchViewController: UIViewController {
    
    var searchBar: UISearchBar!
    var nearlyCollectionview:UICollectionView!
    var nearLyData:NSMutableArray!
    
    var historyView:UIView!
    
    var searchResultView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
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
        searchResultView.register(RecordListTableViewCell.self, forCellReuseIdentifier: "MyCell")
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
        createTabList()
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
        createTabList()
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
