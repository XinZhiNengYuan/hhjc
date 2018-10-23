//
//  DeviceManagementViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DeviceManagementViewController: BaseViewController,UIGestureRecognizerDelegate {

    var topView:UIView!
    var leftView: UIView!
    var minX: CGFloat!
    var maxX:CGFloat!
    var start:CGPoint!
    var move:Bool = false
    var showOrNo : Bool = false
    let oneMeanArr : Array<String> = ["全部","基础类","进阶类","高级类","拔高类","终极类","究极类"]
    let listArr : Array<String> = ["人类起源","人类初级进化","人类中极进化","人类高级进化","人类终极进化","人类升华"]
    let listForArr : Array<Dictionary<String,String>> = [["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"],["deviceName":"1#笔记本电脑","deviceType":"华硕X42FZ43JZ","deviceW":"额定功率：","wp":"0.75KW","position":"能源管理部供配电站航空港110KV变电站"]]
    var tableView1 = UITableView()
    var tableView2 = UITableView()
    var statusArr : NSMutableArray = NSMutableArray()
    var statusArrOfContent : NSMutableArray = NSMutableArray()
    var contentView : UIView!
    let ScreenWidth  = UIScreen.main.bounds.width
    let ScreenHeight = UIScreen.main.bounds.height
    let IdentifierC = "MyUICollectionViewCell"
    let headerIdentifier = "CollectionHeaderView"
    let footIdentifier = "CollectionFootView"
    let searchView = UIView()
    //存储最后选中的行（包括菜单和清单主页）
    var meanAndContentLog : [String:[String:Int]] = ["meanLog":["one":-1,"two":-1],"contentLog":["one":-1,"two":-1]]
    //本地存储
    let userDefault = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

        addData()
        drawerView()
        setContentView()
        setSearchView()
        readyGo()
        // Do any additional setup after loading the view.
    }

    func readyGo(){
        meanAndContentLog = userDefault.dictionary(forKey: "DeviceManagementKey") as? [String : [String : Int]] ?? ["meanLog":["one":-1,"two":-1],"contentLog":["one":-1,"two":-1]]
//        let indexPathForMean = IndexPath(row:meanAndContentLog["meanLog"]!["two"]!,section:1)
//        tableView1.scrollToRow(at: indexPathForMean, at: UITableViewScrollPosition.top, animated: true)
//        let indexPathForContent = IndexPath(row:meanAndContentLog["contentLog"]!["two"]!,section:1)
//        tableView2.scrollToRow(at: indexPathForContent, at: UITableViewScrollPosition.top, animated: true)
        if meanAndContentLog["meanLog"]!["one"]! != -1{
            statusArr[meanAndContentLog["meanLog"]!["one"]!] = true
            self.tableView1.reloadSections(IndexSet.init(integer: meanAndContentLog["meanLog"]!["one"]!), with: UITableViewRowAnimation.automatic)
        }
        if meanAndContentLog["contentLog"]!["one"]! != -1{
            statusArrOfContent[meanAndContentLog["contentLog"]!["one"]!] = true
            self.tableView2.reloadSections(IndexSet.init(integer: meanAndContentLog["contentLog"]!["one"]!), with: UITableViewRowAnimation.automatic)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addData(){
        for _ in 0..<oneMeanArr.count{
            statusArr.add(false)
        }
        for _ in 0..<6{
            statusArrOfContent.add(false)
        }
    }
    
    func setSearchView(){
        let searchViewFrame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width-100, height: 30)
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(toSearchData))
        searchView.frame = searchViewFrame
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor
        searchView.layer.backgroundColor = UIColor.white.cgColor
        searchView.layer.cornerRadius = 15
        let mLabel = UILabel()
        mLabel.text = "请输入您要查询的设备"
        mLabel.frame = CGRect(x: 30, y: 0, width: 150, height: 30)
        mLabel.font = UIFont.boldSystemFont(ofSize: 12)
        mLabel.textColor = UIColor.gray
        mLabel.textAlignment = .left
        searchView.addSubview(mLabel)
        
        let mImageView = UIImageView(image :UIImage(named: "搜索-1"))
        mImageView.frame = CGRect(x: 10, y: 7.5, width: 15, height: 15)
        searchView.addSubview(mImageView)
        let qCButton = UIButton()
        qCButton.setImage(UIImage(named: "扫描"), for: UIControlState.normal)
        qCButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 5, width: 20, height: 20)
        qCButton.addTarget(self, action: #selector(toQC), for: UIControlEvents.touchUpInside)
        searchView.addSubview(qCButton)
        searchView.addGestureRecognizer(gesture)
        searchView.center.x = UIScreen.main.bounds.size.width/2
        searchView.center.y = 20
        view.addSubview(searchView)
    }
    
    //MARK:搜索按钮
    @objc func toSearchData(){
//        navigationController?.pushViewController(DeviceSearchListViewController(), animated: true)
//        self.present(DeviceSearchListViewController(), animated: false, completion: nil)
        self.navigationController?.pushViewController(DeviceSearchListViewController(), animated: true)
    }
    
    @objc func toQC(){
        self.present(QrCodeViewController(), animated: false, completion: nil)
    }
    func drawerView(){
        self.tabBarController?.view.isMultipleTouchEnabled = true
        self.tabBarController?.view.isUserInteractionEnabled = true
        let leftViewHeight = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!
        let topMake = CGRect(x: -UIScreen.main.bounds.width, y: leftViewHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        topView = UIView(frame: topMake)
        topView?.backgroundColor = UIColor.clear
        let make = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*3/5, height: UIScreen.main.bounds.height)
        leftView = UIScrollView(frame: make)
        leftView?.backgroundColor = UIColor(red: 237/255, green: 242/255, blue: 247/255, alpha: 1)
        topView?.addSubview(leftView!)
        setLeftTableView(leftView as! UIScrollView)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.addSubview(topView!)
        minX = topView?.center.x//滑动view中心点 -->隐藏时中心点
        maxX = minX! + topMake.width//彻底展示时的中心点 -->显示时的中心点
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        topView?.addGestureRecognizer(panGesture)
    }
    
    //MARK: 手势滑动方法
    @objc func pan(_ pan: UIPanGestureRecognizer){
        
        switch pan.state{
            
        case UIGestureRecognizerState.began:
            start = pan.translation(in: self.view)//手指移动的实时点
            
        case UIGestureRecognizerState.changed:
            //            print("----Changed----")
            let tran = pan.translation(in: self.view)//手指移动的实时点
            //tran.x向右为正，向左为负
            let newC = (topView?.center.x)! + tran.x
            let moveX = tran.x - (start?.x)!
            let moveY = tran.y - (start?.y)!
            //保证view随着手指移动移动
            if fabs(moveX) > fabs(moveY){
                move = true
                if newC >= minX! && newC <= maxX!{
                    topView?.center = CGPoint(x: newC, y: (topView?.center.y)!)
                }
            }else{
                move = false
            }
            pan.setTranslation(CGPoint.zero, in: self.view)
        case UIGestureRecognizerState.ended:
            if move == true {
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    if self.topView!.center.x > self.minX! && self.topView!.center.x < (self.maxX-50){//隐藏
                        self.topView!.center = CGPoint(x: self.minX!, y: self.topView!.center.y)
                        self.showOrNo = false
                    }
                }, completion: { (finish) -> Void in
                    
                })
            }
        default: break
        }
        
        
    }
    
    func setLeftTableView(_ leftView : UIScrollView){
        let rect1 = CGRect(x: 0, y: 10, width: leftView.frame.size.width, height: leftView.frame.height-80)
        tableView1.frame = rect1
        self.tableView1.showsVerticalScrollIndicator = false
        tableView1.backgroundColor = UIColor.init(red: 237/255, green: 242/255, blue: 247/255, alpha: 1)
        tableView1.register(UITableViewControllerCellTwo.self, forCellReuseIdentifier: "tableCell1")
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.separatorStyle = UITableViewCellSeparatorStyle.none
        leftView.addSubview(tableView1)
    }
    //MARK:页面布局
    func setContentView(){
        view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        contentView = UIView()
        contentView.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.height - 40)
        tableView2.register(UITableViewControllerCellFore.self, forCellReuseIdentifier: "tableCell2")
        tableView2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.height - (tabBarController?.tabBar.frame.height)! - 40)
        tableView2.dataSource = self
        tableView2.delegate = self
//        let indexPath = IndexPath(row:1,section:1)
//        tableView2.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        tableView2.separatorStyle = UITableViewCellSeparatorStyle.none
        self.contentView.addSubview(tableView2)
        self.view.addSubview(contentView)
    }
    
    //MARK:手动点击侧滑按钮
    @IBAction func leftMean(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            if self.showOrNo {//隐藏
                self.topView!.center = CGPoint(x: self.minX!, y: self.topView!.center.y)
                self.showOrNo = false
            }else{//展示
                self.topView!.center = CGPoint(x: self.maxX!, y: self.topView!.center.y)
                self.showOrNo = true
            }
            
        }, completion: { (finish) -> Void in
            
        })
    }

}

extension DeviceManagementViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView:UITableView) ->Int {
        if tableView1.isEqual(tableView) {
            return oneMeanArr.count
        }else{
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView1.isEqual(tableView){
            if statusArr[section] as! Bool{
                return listArr.count
            }else{
                return 0
            }
        }else{
            if statusArrOfContent[section] as! Bool{
                return listArr.count
            }else{
                return 0
            }
        }
        
        
    }
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        if tableView1.isEqual(tableView){
            return 40
        }else{
            return 100
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView1.isEqual(tableView){
            return 40
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView1.isEqual(tableView){
            let view : UITableViewControllerCellOne = UITableViewControllerCellOne()
            view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width*0.3, height: view.frame.size.height)
            view.tag = section + 1000
            view.mNum.text = "3个"
            view.isSelected = statusArr[section] as! Bool
            view.callBack = {(index : Int,isSelected : Bool) in
                let i = index - 1000
                
                //设置选中状态
                if self.statusArr[i] as! Bool{
                    self.statusArr[i] = false
                }else{
                    for j in 0..<self.statusArr.count{//设置菜单为只有一个是选中的状态，其他的为非选中状态
                        if(j != i){
                            self.statusArr[j] = false
                        }else{
                            //选中时i==j
                            if i == self.statusArr.count-1{
                                view.setBottomLine()
                            }
                            self.statusArr[j] = true
                            self.meanAndContentLog["meanLog"]!["one"] = j
                            self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
                            self.reloadContent()//重新z加载主页
                        }
                    }
                }
                self.tableView1.reloadData()
                //self.tableView1.reloadSections(IndexSet.init(integer: i), with: UITableViewRowAnimation.automatic)
            }
            if self.meanAndContentLog["meanLog"]!["one"] == statusArr.count-1{
                view.setBottomLine()
            }
            //画左侧菜单竖着的直线
            
            if section == 0 {
                view.setBottomLine()
                
            }else if section == self.listArr.count{
                view.setTopLine()
            }else{
                view.setTopLine()
                view.setBottomLine()
            }
            view.mLabel.text = oneMeanArr[section]
            return view
        }else{
            let view : UITableViewControllerCellThire = UITableViewControllerCellThire()
            view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width*0.3, height: view.frame.size.height)
            view.tag = section + 2000
            view.mNum.text = "3个"
            view.isSelected = statusArrOfContent[section] as! Bool
            view.callBack = {(index : Int,isSelected : Bool) in
                let i = index - 2000
                //设置选中状态
                if self.statusArrOfContent[i] as! Bool{
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
                
                self.tableView2.reloadData()
//                self.tableView2.reloadSections(IndexSet.init(integer: i), with: UITableViewRowAnimation.automatic)
            }
            view.mLabel.text = oneMeanArr[section]
            return view
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView1.isEqual(tableView){
            
            let identifier = "reusedCell1"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UITableViewControllerCellTwo
            if cell == nil{
                cell = UITableViewControllerCellTwo(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
            }
            let rowNum = indexPath.row
            cell?.mLabel.text = listArr[rowNum]
            cell?.mLabel.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.mNum.text = "3个"
            cell?.setTopLine()
            cell?.setBottomLine()
            return cell!
        }else{
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
        
    }
    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        if tableView1.isEqual(tableView){
            self.meanAndContentLog["meanLog"]!["two"] = indexPath.row
            reloadContent()
        }else{
            self.meanAndContentLog["contentLog"]!["two"] = indexPath.row
            self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
            self.navigationController?.pushViewController(DeviceDetailViewController(), animated: true)
        }
        print(self.userDefault.dictionary(forKey: "DeviceManagementKey") as Any)
//        print(indexPath.row)
//        reLoadCollectionView(option:"区域行被电击")
        
    }
    func reloadContent(){
        //点击菜单之后要重新记录主页被选中的状态
        self.meanAndContentLog["contentLog"]!["one"] = -1
        self.meanAndContentLog["contentLog"]!["two"] = -1
        for j in 0..<self.statusArrOfContent.count{//设置主页所有行为未选中状态
            self.statusArrOfContent[j] = false
        }
        self.tableView2.reloadData()
        self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
    }
}
