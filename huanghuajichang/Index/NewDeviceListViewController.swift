//
//  NewDeviceListViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewDeviceListViewController: AddNavViewController {
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var allListData:JSON = []
    
    var ss:Bool = false
    let newDeviceList:UITableView = UITableView()
    var statusArrOfContent : NSMutableArray = [true]
    var oneMeanArr : [NewEquipmentListModel] = []
    
    //存储最后选中的行（包括菜单和清单主页）
    var meanAndContentLog : [String:[String:Int]] = ["meanLog":["one":-1,"two":-1],"contentLog":["one":-1,"two":-1]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新增设备"
        self.view.backgroundColor = UIColor.white
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        // Do any additional setup after loading the view.
        createUI()
    }
    func createUI(){
        newDeviceList.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-navigationHeight)
        newDeviceList.delegate = self
        newDeviceList.dataSource = self
        newDeviceList.separatorStyle = UITableViewCellSeparatorStyle.none
        newDeviceList.backgroundColor = allListBackColor
        self.view.addSubview(newDeviceList)
        newDeviceList.register(UITableViewControllerCellFore.self, forCellReuseIdentifier: "tableCell2")
        getNewEquiptmentList()
    }
    
    ///获取新增设备列表
    func getNewEquiptmentList(){
        MyProgressHUD.showStatusInfo("数据加载中...")
        let contentData : [String : Any] = ["method":"getCurrentMonthEquipmentList","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            //                        print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.allListData = JSON(value)["data"]["resultData"]
                    print(self.allListData)
                    var childs:[[String:AnyObject]] = []
                    for equitItem in self.allListData.enumerated(){
                        
                        childs.append(self.allListData[equitItem.offset].dictionary! as Dictionary<String, AnyObject>)
                        
                        let equitParentCategoryModel = NewEquipmentListModel(equCategory: self.allListData[equitItem.offset]["equCategorySmall"].stringValue, categoryName: self.allListData[equitItem.offset]["categoryNameSmall"].stringValue, childsNum: 1, childs: childs)
                        
                        var hasParent = false
                        if self.oneMeanArr != []{
                            for haveEquitCategory in self.oneMeanArr.enumerated(){
                                if self.oneMeanArr[haveEquitCategory.offset].equCategory == self.allListData[equitItem.offset]["equCategorySmall"].stringValue {
                                    hasParent = true
                                    self.oneMeanArr[haveEquitCategory.offset].childs.append(self.allListData[equitItem.offset].dictionary! as Dictionary<String, AnyObject>)
                                    self.oneMeanArr[haveEquitCategory.offset].childsNum = self.oneMeanArr[haveEquitCategory.offset].childsNum+1
                                }else{
                                    childs = []
                                }
                            }
                        }else{
                            hasParent = false
                            childs = []
                        }
                        
                        if !hasParent {
                            self.oneMeanArr.append(equitParentCategoryModel)
                        }
                    }
                    print(self.oneMeanArr)
                    for i in self.oneMeanArr.enumerated(){
                        if i.offset != 0 {
                            self.statusArrOfContent.add(false)
                        }
                    }
                    self.newDeviceList.reloadData()
                    //刷新页面数据
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
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
    
}
extension NewDeviceListViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView:UITableView) ->Int {
        if self.oneMeanArr == [] {
            return 1
        }else{
            return self.oneMeanArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.statusArrOfContent[section] as! Bool {
            if self.oneMeanArr == [] {
                return 0
            }else{
                return oneMeanArr[section].childsNum
            }
        }else{
            return 0
        }
        
    }
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UITableViewControllerCellThire = UITableViewControllerCellThire()
        view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width*0.3, height: view.frame.size.height)
        view.tag = section + 2000
        
        view.isSelected = self.statusArrOfContent[section] as! Bool
        
        view.callBack = {(index : Int,isSelected : Bool) in
            let i = index - 2000
            //设置选中状态
            if view.isSelected{
                view.rightPic.image = UIImage(named: "展开")
                self.statusArrOfContent[i] = false
            }else{
                view.rightPic.image = UIImage(named: "收起")
                
                for j in 0..<self.statusArrOfContent.count{//设置主页为只有一个是选中的状态，其他的为非选中状态
                    if(j != i){
                        self.statusArrOfContent[j] = false
                    }else{
                        //选中时i==j
                        self.statusArrOfContent[j] = true
                        self.meanAndContentLog["contentLog"]!["one"] = j
                        self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
                    }
                }
            }
            
            self.newDeviceList.reloadData()
        }
        if oneMeanArr != []{
            view.mLabel.text = oneMeanArr[section].categoryName
            view.mNum.text = oneMeanArr[section].childsNum.description
        }
        return view
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let identifier = "reusedCell2"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UITableViewControllerCellFore
        if cell == nil{
            cell = UITableViewControllerCellFore(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        let rowNum = indexPath.row
        let sectionNum = indexPath.section
        let cellData = oneMeanArr[sectionNum].childs[rowNum]
        cell?.topLeft.text = cellData["equName"]?.description //listForArr[rowNum]["deviceName"]
        cell?.topRight.text = cellData["specification"]?.description
        let topLeftWidth = (cell?.topLeft.getLabelWidth(str: cellData["equName"]?.description ?? "", font: UIFont.boldSystemFont(ofSize: 12), height: 20) ?? 50.0 > kScreenWidth/3) ? kScreenWidth/3 : (cell?.topLeft.getLabelWidth(str: cellData["equName"]?.description ?? "", font: UIFont.boldSystemFont(ofSize: 12), height: 20))
        cell?.topLeft.frame = CGRect(x: 20, y: 10, width: topLeftWidth!, height: 20)
        
        let topRightWdith = (cell?.topRight.getLabelWidth(str: cellData["specification"]?.description ?? "", font: UIFont.boldSystemFont(ofSize: 12), height: 20) ?? 50.0 > kScreenWidth/3) ? kScreenWidth/3 : (cell?.topRight.getLabelWidth(str: cellData["specification"]?.description ?? "", font: UIFont.boldSystemFont(ofSize: 12), height: 20) ?? 50) + 10.0
        cell?.topRight.frame = CGRect(x: 30 + topLeftWidth!, y: 10, width: topRightWdith, height: 20)
        cell?.midelLeft.text = "额定功率"
        cell?.midelCenter.text = cellData["power"]?.description
        cell?.bottomRight.text = (cellData["coOne"]?.description)! + "-" + (cellData["coTwo"]?.description)!
        
        return cell!
        
    }
    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        
        let detailVc = DeviceDetailViewController()
        detailVc.eqCode = JSON(oneMeanArr[indexPath.section].childs[indexPath.row])["equNo"].description
        detailVc.eqId = JSON(oneMeanArr[indexPath.section].childs[indexPath.row])["equId"].description
        self.navigationController?.pushViewController(detailVc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
