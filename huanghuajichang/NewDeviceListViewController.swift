//
//  NewDeviceListViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class NewDeviceListViewController: AddNavViewController {
    var ss:Bool = false
    let newDeviceList:UITableView = UITableView()
    var statusArrOfContent : NSMutableArray = [false, true, false]
    let oneMeanArr : Array<String> = ["全部","基础类","进阶类","高级类","拔高类","终极类","究极类"]
    let listArr : Array<String> = ["人类起源","人类初级进化","人类中极进化","人类高级进化","人类终极进化","人类升华"]
    let listForArr : Array<Dictionary<String,String>> = [["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"]]
    //存储最后选中的行（包括菜单和清单主页）
    var meanAndContentLog : [String:[String:Int]] = ["meanLog":["one":-1,"two":-1],"contentLog":["one":-1,"two":-1]]
    //本地存储
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新增设备"
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        createUI()
    }
    func createUI(){
        newDeviceList.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64)
        newDeviceList.delegate = self
        newDeviceList.dataSource = self
        newDeviceList.separatorStyle = UITableViewCellSeparatorStyle.none
        newDeviceList.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        self.view.addSubview(newDeviceList)
        newDeviceList.register(UITableViewControllerCellFore.self, forCellReuseIdentifier: "tableCell2")
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.statusArrOfContent[section] as! Bool {
            return 3
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
            view.mNum.text = "3个"
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
            view.mLabel.text = oneMeanArr[section]
            return view
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            let identifier = "reusedCell2"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UITableViewControllerCellFore
            if cell == nil{
                cell = UITableViewControllerCellFore(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
            let rowNum = indexPath.row
            cell?.topLeft.text = listForArr[rowNum]["deviceName"]
            cell?.topRight.text = listForArr[rowNum]["deviceType"]
            cell?.midelLeft.text = listForArr[rowNum]["deviceW"]
            cell?.midelCenter.text = listForArr[rowNum]["wp"]
            cell?.bottomRight.text = listForArr[rowNum]["position"]
            return cell!
        
    }
    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        
//            self.meanAndContentLog["contentLog"]!["two"] = indexPath.row
//            self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
//            self.navigationController?.pushViewController(DeviceDetailViewController(), animated: true)
//
//        print(self.userDefault.dictionary(forKey: "DeviceManagementKey") as Any)
                print(indexPath.row)
        //        reLoadCollectionView(option:"区域行被电击")
        
    }
    
    
}
