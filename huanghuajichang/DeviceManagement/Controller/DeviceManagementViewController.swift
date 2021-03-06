//
//  DeviceManagementViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

class DeviceManagementViewController: BaseViewController,UIGestureRecognizerDelegate {

    var topView:UIView!
    var leftView: UIView!
    var minX: CGFloat!
    var maxX:CGFloat!
    var start:CGPoint!
    var move:Bool = false
    var showOrNo : Bool = false
    var oneMeanArr : [String] = [String]()
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    var resultDataForArr : [DeviceManagementModule] = []
    var contentList : Array<DeviceManagementContentListDiyModule> = []
    var tableView1 = UITableView()
    var tableView2 = UITableView()
    var statusArr : NSMutableArray = NSMutableArray()
    var statusArrOfContent : NSMutableArray = NSMutableArray()
    var contentView : UIView!
    let IdentifierC = "MyUICollectionViewCell"
    let headerIdentifier = "CollectionHeaderView"
    let footIdentifier = "CollectionFootView"
    let commonClass = common()
    var currentOne:String = ""
    var currentTwo:String = ""
    //存储最后选中的行（包括菜单和清单主页）
    var meanAndContentLog : [String:[String:Int]] = ["meanLog":["one":0,"two":0],"contentLog":["one":0,"two":0]]
    //本地存储
    let userDefault = UserDefaults.standard
    
    let deviceManagementService = DeviceManagementService()
    let qrCodeService = QrCodeService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.white
        requestForData()
        NotificationCenter.default.addObserver(self, selector: #selector(requestForData), name: NSNotification.Name(rawValue: "initDeviceManagementViewController"), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "initDeviceManagementViewController"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool){
//        self.navigationItem.title = "设备管理"
        
    }

    @objc func requestForData(){
//        userDefault.removeObject(forKey: "DeviceManagementKey")
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String : String] = ["method":"getEquTreeList","info":"","user_id":userId!,"token":token!]
        deviceManagementService.getData(contentData: contentData, finished: { (successData,oneMean) in
            self.resultDataForArr = []
            self.oneMeanArr = []
            self.resultDataForArr += successData
            self.oneMeanArr += oneMean
            let deviceListData : [String : Any] = ["method":"getEquipmentList","info":["oneId":"","twoId":"","equName":""],"user_id":userId as Any,"token":token as Any]
            self.deviceManagementService.getDeviceListData(contentData : deviceListData, finished: { (contentListData) in
                self.contentList = []
                self.contentList += contentListData
                self.addData()
                self.drawerView()
                self.setContentView()
                self.setSearchView()
                self.readyGo()
            }, finishedError: {(contentError) in
                print(contentError)
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
            })
        }) { (error) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
            print(error)
        }
    }
    
    //初始化下拉刷新/上拉加载
    func initMJRefresh(){
        //下拉刷新相关设置
        refresHeader.setRefreshingTarget(self, refreshingAction: #selector(DeviceManagementViewController.headerRefresh))
        // 现在的版本要用mj_header
        
        refresHeader.setTitle("下拉刷新", for: .idle)
        refresHeader.setTitle("释放更新", for: .pulling)
        refresHeader.setTitle("正在刷新...", for: .refreshing)
        self.tableView2.mj_header = refresHeader
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        print("下拉刷新")
        //服务器请求数据的函数
        requestForData()
        //结束下拉刷新
        self.tableView2.mj_header.endRefreshing()
    }
    //MARK:设置初始状态
    func readyGo(){
        meanAndContentLog = userDefault.dictionary(forKey: "DeviceManagementKey") as? [String : [String : Int]] ?? ["meanLog":["one":0,"two":0],"contentLog":["one":0,"two":0]]
        //判断记录的菜单在请求回来的菜单数据中存不存在
        if self.resultDataForArr[meanAndContentLog["meanLog"]!["one"]!].children.count-1 >= meanAndContentLog["meanLog"]!["two"]!{
            selectInitStatus()//存在
        }
        
    }
    
    func selectInitStatus(){
        statusArr[meanAndContentLog["meanLog"]!["one"]!] = true
        self.tableView1.reloadSections(IndexSet.init(integer: meanAndContentLog["meanLog"]!["one"]!), with: UITableViewRowAnimation.automatic)
        self.navigationItem.title  = resultDataForArr[meanAndContentLog["meanLog"]!["one"]!].children[meanAndContentLog["meanLog"]!["two"]!].text
        self.userDefault.set(resultDataForArr[meanAndContentLog["meanLog"]!["one"]!].text, forKey: "FristOriginal")
        self.userDefault.set(resultDataForArr[meanAndContentLog["meanLog"]!["one"]!].children[meanAndContentLog["meanLog"]!["two"]!].text, forKey: "SecondOriginal")
        //默认选中的section，row
        let defaultSelectCell = IndexPath(row: meanAndContentLog["meanLog"]!["two"]!, section: meanAndContentLog["meanLog"]!["one"]!)
        self.tableView1.selectRow(at: defaultSelectCell, animated: true, scrollPosition: UITableViewScrollPosition.none)
        let onlyItem = self.tableView1.dequeueReusableCell(withIdentifier: "reusedCell1", for: defaultSelectCell) as! UITableViewControllerCellTwo
        onlyItem.mLabel.backgroundColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1)
        onlyItem.mLabel.layer.borderWidth = 1
        onlyItem.mLabel.layer.cornerRadius = 10
        onlyItem.mLabel.clipsToBounds = true
        //获取默认设备列表信息
        reloadContent(oId: resultDataForArr[defaultSelectCell.section].id, tId: resultDataForArr[defaultSelectCell.section].children[defaultSelectCell.row].id)
        //设置设备列表默认的第一被选中
        statusArrOfContent[meanAndContentLog["contentLog"]!["one"]!] = true
//        self.tableView2.reloadSections(IndexSet.init(integer: meanAndContentLog["contentLog"]!["one"]!), with: UITableViewRowAnimation.automatic)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addData(){
        statusArr = []
        statusArrOfContent = []
        for _ in 0..<oneMeanArr.count{
            statusArr.add(false)
        }
        for _ in 0..<contentList.count{
            statusArrOfContent.add(false)
        }
    }
    
    func setSearchView(){
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: KUIScreenWidth, height: 40)
        let searchView = UIView()
        let searchViewFrame = CGRect(x: 0, y: 10, width: KUIScreenWidth-100, height: 30)
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        gesture.addTarget(self, action: #selector(toSearchData))
        searchView.addGestureRecognizer(gesture)
        searchView.frame = searchViewFrame
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1).cgColor
        searchView.layer.backgroundColor = UIColor.white.cgColor
        searchView.layer.cornerRadius = 15
        let mLabel = UILabel()
        mLabel.text = "设备名称/设备小类"
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
        qCButton.frame = CGRect(x: KUIScreenWidth - 40, y: 5, width: 30, height: 30)
        qCButton.addTarget(self, action: #selector(toQC), for: UIControlEvents.touchUpInside)
        qCButton.setEnlargeEdge(20)
        headerView.addSubview(qCButton)
        searchView.center.x = UIScreen.main.bounds.size.width/2
        searchView.center.y = 20
        headerView.addSubview(searchView)
        view.addSubview(headerView)
    }
    
    //MARK:搜索按钮
    @objc func toSearchData(){
        let navigationView = UINavigationController.init(rootViewController: DeviceSearchListViewController())
        UINavigationBar.appearance().barTintColor = UIColor(red: 41/255, green: 105/255, blue: 222/255, alpha: 1) //修改导航栏背景色
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] //为导航栏设置字体颜色等
        self.present(navigationView, animated: true, completion: nil)
    }
    
    @objc func goBack(){

        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toQC(){
//        let addDeviceManagementViewController = AddDeviceManagementViewController()
//        addDeviceManagementViewController.eqCode = "ENN12312312"
//        let navigationView = UINavigationController.init(rootViewController: addDeviceManagementViewController)
//        UINavigationBar.appearance().barTintColor = UIColor(red: 41/255, green: 105/255, blue: 222/255, alpha: 1) //修改导航栏背景色
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] //为导航栏设置字体颜色等
//        self.present(navigationView, animated: true, completion: nil)
//        self.present(QrCodeViewController(), animated: false, completion: nil)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scanViewController") as! ScanViewController
        //闭包传值
        controller.callBackBlock { (QrResult) in
            if QrResult == "未识别到二维码" {
                self.present(windowAlert(msges: QrResult), animated: false, completion: nil)
            }else{
                self.HadleQrResult(resultStr: QrResult)
            }
        }
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    //根据扫描结果，进行相应处理
    func HadleQrResult(resultStr:String) {
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String : Any] = ["method":"checkEquipmentByCode","info":["code":resultStr],"user_id":userId as Any,"token":token as Any]
        
        qrCodeService.getQrCode(contentData: contentData, finishedData: { (resultData) in
            if resultData["status"].stringValue == "success"{
                if resultData["data"].stringValue == "101"{
                    self.present(windowAlert(msges: "无效二维码"), animated: true, completion: nil)
                }else if resultData["data"].stringValue == "102"{//未绑定的新设备
                    let alertController = UIAlertController(title:"提示",message:"此设备信息不存在，是否新增？",preferredStyle: .alert)
                    let canceAction = UIAlertAction(title:"取消",style:.cancel,handler:nil)
                    let okAciton = UIAlertAction(title:"确定",style:.default,handler: {action in
                        let addDeviceManagementViewController = AddDeviceManagementViewController()
                        addDeviceManagementViewController.eqCode = resultStr
                        let navigationView = UINavigationController.init(rootViewController: addDeviceManagementViewController)
                        UINavigationBar.appearance().barTintColor = UIColor(red: 41/255, green: 105/255, blue: 222/255, alpha: 1) //修改导航栏背景色
                        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] //为导航栏设置字体颜色等
                        self.present(navigationView, animated: true, completion: nil)
                    })
                    alertController.addAction(canceAction);
                    alertController.addAction(okAciton);
                    self.present(alertController, animated: true, completion: nil)
                }else{//已经绑定过的设备
                    let deviceDetailViewController = DeviceDetailViewController()
                    deviceDetailViewController.eqCode = resultStr
                    self.navigationController?.pushViewController(deviceDetailViewController, animated: true)
                }
            }else{
                self.present(windowAlert(msges: "暂未获取到有用信息！"), animated: false, completion: nil)
            }
        }) { (errorData) in
            self.present(windowAlert(msges: "网络请求失败"), animated: false, completion: nil)
        }
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
        tableView2.separatorStyle = UITableViewCellSeparatorStyle.none
        self.contentView.addSubview(tableView2)
        self.view.addSubview(contentView)
        initMJRefresh()
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
            return contentList.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView1.isEqual(tableView){
            if statusArr[section] as! Bool{
                return resultDataForArr[section].children.count
            }else{
                return 0
            }
        }else{
            if statusArrOfContent[section] as! Bool{
                return contentList[section].deviceManagementContentList.count
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
            view.mNum.text = "\(resultDataForArr[section].equipmentCount)个"
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
                            //点击一级菜单的时候不刷新列表页
//                            self.reloadContent()//重新z加载主页
                        }
                    }
                }
                self.tableView1.reloadData()
            }
            
            if self.meanAndContentLog["meanLog"]!["one"] == statusArr.count-1{
                view.setBottomLine()
            }
            
            //画左侧菜单竖着的直线
            if section == 0 {
                view.setBottomLine()
            }else if section == self.oneMeanArr.count-1{
                view.setTopLine()
            }else{
                view.setTopLine()
                view.setBottomLine()
            }
            
            view.mLabel.setTitle(resultDataForArr[section].text, for: UIControlState.normal)
            return view
        }else{
            let view : UITableViewControllerCellThire = UITableViewControllerCellThire()
            view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width*0.3, height: view.frame.size.height)
            view.tag = section + 2000
            view.mNum.text = "\(contentList[section].deviceManagementContentList.count)"
            if section == self.contentList.count - 1{
                view.theLastHeader = true
            }else{
                view.theLastHeader = false
            }
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
            }
            view.mLabel.text = contentList[section].categoryNameSmall
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
            cell?.mLabel.text = resultDataForArr[indexPath.section].children[rowNum].text
            cell?.mLabel.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.mNum.text = "\(resultDataForArr[indexPath.section].children[rowNum].equipmentCount)个"
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
            cell?.topLeft.text = contentList[indexPath.section].deviceManagementContentList[rowNum].equName
            let topLeftWidth = commonClass.getLabelWidth(str: contentList[indexPath.section].deviceManagementContentList[rowNum].equName, font: UIFont.boldSystemFont(ofSize: 12), height: 20) > KUIScreenWidth/3 ? KUIScreenWidth/3 : commonClass.getLabelWidth(str: contentList[indexPath.section].deviceManagementContentList[rowNum].equName, font: UIFont.boldSystemFont(ofSize: 12), height: 20)
            cell?.topLeft.frame = CGRect(x: 20, y: 10, width: topLeftWidth, height: 20)
            
            let topRightWdith = (commonClass.getLabelWidth(str: contentList[indexPath.section].deviceManagementContentList[rowNum].specification, font: UIFont.boldSystemFont(ofSize: 12), height: 20) > KUIScreenWidth/3 ? KUIScreenWidth/3 : commonClass.getLabelWidth(str: contentList[indexPath.section].deviceManagementContentList[rowNum].specification, font: UIFont.boldSystemFont(ofSize: 12), height: 20)) + 10
            cell?.topRight.frame = CGRect(x: 30 + topLeftWidth, y: 10, width: topRightWdith, height: 20)
            cell?.topRight.text = contentList[indexPath.section].deviceManagementContentList[rowNum].specification
            cell?.midelLeft.text = "额定功率："
            cell?.midelCenter.text = "\(contentList[indexPath.section].deviceManagementContentList[rowNum].power)KW"//contentList[rowNum]["w"]
            cell?.bottomRight.text = contentList[indexPath.section].deviceManagementContentList[rowNum].coOneAndcoTwo
            return cell!
        }
        
    }
    
    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        if tableView1.isEqual(tableView){
            self.meanAndContentLog["meanLog"]!["two"] = indexPath.row
            currentOne = resultDataForArr[indexPath.section].id
            currentTwo = resultDataForArr[indexPath.section].children[indexPath.row].id
            let onlyItem = tableView.cellForRow(at: indexPath) as! UITableViewControllerCellTwo
            onlyItem.mLabel.backgroundColor = UIColor(red: 99/255, green: 168/255, blue: 222/255, alpha: 1)
            onlyItem.mLabel.layer.borderWidth = 1
            onlyItem.mLabel.layer.cornerRadius = 10
            onlyItem.mLabel.clipsToBounds = true
            self.navigationItem.title = resultDataForArr[indexPath.section].children[indexPath.row].text
            reloadContent(oId: resultDataForArr[indexPath.section].id, tId: resultDataForArr[indexPath.section].children[indexPath.row].id)
            regainMean()
            self.userDefault.set(resultDataForArr[indexPath.section].text, forKey: "FristOriginal")
            self.userDefault.set(resultDataForArr[indexPath.section].children[indexPath.row].text, forKey: "SecondOriginal")
        }else{
            let deviceDetailViewController = DeviceDetailViewController()
            deviceDetailViewController.eqCode = self.contentList[indexPath.section].deviceManagementContentList[indexPath.row].equNo
            self.meanAndContentLog["contentLog"]!["two"] = indexPath.row
            self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
            self.navigationController?.pushViewController(deviceDetailViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let deleteDeviceNo = self.contentList[indexPath.section].deviceManagementContentList[indexPath.row].equNo
        if editingStyle == .delete {
            deleteDevice(deviceNo: deleteDeviceNo, deviceIndexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        if tableView1.isEqual(tableView){
            return .none
        }else{
            return .delete
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
    @objc func deleteDevice(deviceNo:String,deviceIndexPath:IndexPath){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        MyProgressHUD.showStatusInfo("删除中...")
        let infoData = ["equNo":deviceNo]
        let contentData : [String : Any] = ["method":"deleteEquipment","info":infoData,"token":token ?? "","user_id":userId ?? ""]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //重新请求页面数据
                    self.requestForData()
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
    
    func reloadContent(oId oneId:String,tId twoId:String){
        //点击菜单之后要重新记录主页被选中的状态
        self.meanAndContentLog["contentLog"]!["one"] = 0
        self.meanAndContentLog["contentLog"]!["two"] = 0
        for j in 0..<self.statusArrOfContent.count{//设置主页所有行为未选中状态
            self.statusArrOfContent[j] = false
        }
        self.userDefault.set(self.meanAndContentLog, forKey: "DeviceManagementKey")
        getContentDataList(oId: oneId, tId: twoId)
    }
    
    //MARK:获取列表数据
    func getContentDataList(oId oneId:String,tId twoId:String){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let deviceListData : [String : Any] = ["method":"getEquipmentList","info":["oneId":oneId,"twoId":twoId,"equName":""],"user_id":userId as Any,"token":token as Any]
        self.deviceManagementService.getDeviceListData(contentData : deviceListData, finished: { (contentListData) in
            self.contentList = []
            self.contentList += contentListData
            self.tableView2.reloadData()
        }, finishedError: {(contentError) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
        })
        
    }
    //MARK:收回左侧菜单
    func regainMean(){
        //收回左侧菜单
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
