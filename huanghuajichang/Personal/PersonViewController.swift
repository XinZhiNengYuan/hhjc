//
//  PersonViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/7/20.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class PersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var headerView: UIButton!
    
    var headerImageView:UIImageView!
    var personName:UILabel!
    var personPosition:UILabel!
    
    var personalTable:UITableView!
    var tableCellModels :[NSArray] = NSMutableArray() as! [NSArray]
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var json:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        // Do any additional setup after loading the view.
//        createCollNav()
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        creteHeaderView()
        
    }
    
    func getData(){
        let contentData : [String : Any] = ["method":"getUserInfo","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
//            print(resultData)
            switch resultData.result {
            case .success(let value):
                self.json = JSON(value)["data"]
//                print(self.json)
                if JSON(value)["status"].stringValue == "success"{
//                    print(self.json["url"].stringValue)
                    let urlStr = "http://" + self.userDefault.string(forKey: "AppUrlAndPort")! + self.json["url"].stringValue
//                    let URL:NSURL = NSURL(string:urlStr)!
//                    let imageData:NSData? = NSData(contentsOf:URL as URL)
//                    if imageData != nil {
//                        self.headerImageView.image = UIImage(data: imageData! as Data)
//                    }
                    self.headerImageView.kf.setImage(with: ImageResource(downloadURL:NSURL.init(string: urlStr)! as URL), placeholder: UIImage(named: "默认图片"), options: nil, progressBlock: nil){(Result) in
                        
                    }
                    //此处需要重写下将图片变成圆形的方法
                    self.headerImageView.layer.cornerRadius = (self.headerImageView.frame.width)/2
                    // image还需要加上这一句, 不然无效
                    self.headerImageView.layer.masksToBounds = true
                    self.personName.text = self.json["user_name"].stringValue
                    self.personPosition.text = self.json["postCode"].stringValue
                    self.headerView.layoutIfNeeded()
                }else{
                    print(type(of: JSON(value)["msg"]))
                    self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                }

            case .failure(let error):
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    func creteHeaderView(){
        headerView = UIButton.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: navigationHeight+120))
        //会拉伸图片覆盖
        let image = UIImage(imageLiteralResourceName: "BackGround")
        headerView.layer.contents = image.cgImage
        headerView.addTarget(self, action: #selector(openDetail), for: UIControlEvents.touchUpInside)

        //由于图片较小，覆盖时有问题
//        headerView.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
//        headerView.contentMode = .scaleAspectFill
//        headerView.autoresizingMask = .flexibleWidth
//        headerView.clipsToBounds = true

        headerImageView = UIImageView.init(frame: CGRect(x: 15, y: navigationHeight, width: 80, height: 80))
//        headerImageView.center.x = self.view.center.x
//        headerImageView.center.y = 75
//        headerImageView.frame.size = CGSize(width: 50, height: 50)
        // 圆角指定为长度一半
        headerImageView?.layer.cornerRadius = (headerImageView?.frame.width)! / 2
        // image还需要加上这一句, 不然无效
        headerImageView?.layer.masksToBounds = true
        /*
         通过下面方法1来加载图片时，图片会一直缓存在内存中，一般情况不推荐使用这种方式，
         一个是缓存不可控；第二个图片资源得直接加载到项目中，不方便管理，而且每次添加新图片时工程文件都会变动。

         通过方法2来加载图片时，每次都会从硬盘里读图片，这个操作是比较耗时的，文章开头处的两篇文章都是以这个方法来加载图片的。
         */
        headerImageView.image = UIImage(named: "Bitmap")
//        headerImageView.image = UIImage(contentsOfFile: "Group 17 Copy")
        headerView.addSubview(headerImageView)

        personName = UILabel.init(frame: CGRect(x: 110, y: navigationHeight+15, width: kScreenWidth-110, height: 20))
        personName.textColor = UIColor.white
        personName.textAlignment = .left
        personName.font = UIFont.systemFont(ofSize: 18)
        headerView.addSubview(personName)

        personPosition = UILabel.init(frame: CGRect(x: 110, y: navigationHeight+45, width: kScreenWidth-110, height: 20))
        personPosition.textColor = UIColor.white
        personPosition.textAlignment = .left
        personPosition.font = UIFont.systemFont(ofSize: 15)
        headerView.addSubview(personPosition)

        self.view.addSubview(headerView)
        createTableView()
        getData()
    }
    
    @objc func openDetail(){
        headerView.alpha = 0.8
        UIView.animate(withDuration: 2) {
            self.headerView.alpha = 1
        }
        let personalDetailVc = PersonalDetailViewController()
        let personalDetailNav = UINavigationController(rootViewController: personalDetailVc)
        openChildVC(childNavName:personalDetailNav)
    }
    
    func createTableView () {
        personalTable = UITableView.init(frame: CGRect(x: 0, y: navigationHeight+120, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT), style: UITableViewStyle.grouped)
        
        personalTable.delegate = self
        personalTable.dataSource = self
//        personalTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine
        //注册UITableView，cellID为重复使用cell的Identifier
       // personalTable.register(PersonalTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableCellModels = [[PersonTableViewCellModel(itemId: "1", itemImage: "personalPassWord", itemTitle: "密码", itemRightIcon: "进入" ,itemRightTitle:"修改"),PersonTableViewCellModel(itemId: "1", itemImage: "personalQRCode", itemTitle: "二维码", itemRightIcon: "进入" ,itemRightTitle:"erweima1")],[PersonTableViewCellModel(itemId: "1", itemImage: "personalHelp", itemTitle: "帮助说明", itemRightIcon: "进入" ,itemRightTitle:""),PersonTableViewCellModel(itemId: "1", itemImage: "personalClean", itemTitle: "清除缓存", itemRightIcon: "进入" ,itemRightTitle:"100M"),PersonTableViewCellModel(itemId: "1", itemImage: "personalUpdate", itemTitle: "当前版本", itemRightIcon: "" ,itemRightTitle:"1.0")]]

        //必须将高度重置，不然下面设置header无效
        self.personalTable.estimatedRowHeight = 0;
        self.personalTable.estimatedSectionHeaderHeight = 0;
        self.personalTable.estimatedSectionFooterHeight = 0;
        //去除表格上放多余的空隙
//        self.personalTable.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        self.view.addSubview(personalTable!)
    }
    
    override func viewWillAppear(_ animated: Bool) {//确保每次进入个人中心页面时，刷新缓存处的数据
        if headerView != nil{
            getData()
        }
        if personalTable != nil {
            personalTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //#MARK - delegate
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == tableCellModels.count{
            return 50.0
        }else{
            return 50.0
        }
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            //不能设为 0，否则无效
            return 0.01
        }else if section == 1{
            return 10
        }
        return 20
    }
    
    //设置分组尾的高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    //将分组尾设置为一个空的View（否则在 iOS11 下分组尾高度不会起作用）
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
//        let cell = tableView.cellForRow(at: indexPath)
//
//            print(cell)
        if indexPath.section == 0 && indexPath.row == 0 {
            let changePassword = ChangeNumberPasswordViewController()
            let changeNav = UINavigationController(rootViewController: changePassword)
            openChildVC(childNavName:changeNav)
        }else if indexPath.section == 0, indexPath.row == 1 {
            let maxCardVc = MaxCardViewController()
            let maxCardNav = UINavigationController(rootViewController: maxCardVc)
            openChildVC(childNavName: maxCardNav)
        }else if indexPath.section == 1 && indexPath.row == 0 {
//            let helpVc = HelpDocumentViewController()
//            let helpNav = UINavigationController(rootViewController: helpVc)
//            openChildVC(childNavName:helpNav)
        }else if indexPath.section == 1 && indexPath.row == 1 {
            showConfirm (confrimMessage:"确定清除缓存吗？", hanlderType:1,selectedIndexPath:indexPath)
        }else if indexPath.section == tableCellModels.count {
            showConfirm (confrimMessage:"确定退出登录吗？", hanlderType:2,selectedIndexPath:indexPath)
        }
        //点击后颜色恢复
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //#MARK - datasoure
    public func numberOfSections(in tableView: UITableView) -> Int{
        return tableCellModels.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == tableCellModels.count{
            return 1
        }else{
            return (tableCellModels[section] as AnyObject).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //这里做自定义cell重用
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PersonalTableViewCell
        if cell == nil {
            
            cell = PersonalTableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "cell")
            //这句话去掉默认点击效果
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
//            NSLog("初始化cell")
            
        }else {
            while cell?.contentView.subviews.last != nil {
                (cell?.contentView.subviews.last)?.removeFromSuperview()
            }
        }
        if indexPath.section < tableCellModels.count{
            
            let tableCellModel :PersonTableViewCellModel
            tableCellModel = tableCellModels[indexPath.section][indexPath.row] as! PersonTableViewCellModel
            
            cell?.itemImage?.image = UIImage.init(named: tableCellModel.itemImage)
            
            let rightImg = UIImage.init(named: tableCellModel.itemRightIcon)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            let newImageNormal = rightImg?.imageWithTintColor(color: UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1),blendMode: .overlay)
            cell?.itemRightIcon?.image = newImageNormal
            
            cell?.itemTitle?.text = tableCellModel.itemTitle//String(indexPath.section)+","+String(indexPath.row)
            if indexPath.section == 0 && indexPath.row == 0 {
                //cell?.itemImage?.backgroundColor = UIColor.init(red: 53/255, green: 169/255, blue: 255/255, alpha: 1)
                
                let rightLable:UILabel = UILabel.init(frame:CGRect(x: kScreenWidth-100, y: 15, width: 50, height: 20))
                rightLable.textAlignment = NSTextAlignment.right
                rightLable.font = UIFont.systemFont(ofSize: 14)
                rightLable.textColor = UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                rightLable.text = "修改"
                cell?.contentView.addSubview(rightLable)
                
            }else if indexPath.section == 0 && indexPath.row == 1 {
                
                //cell?.itemImage?.backgroundColor = UIColor.init(red: 82/255, green: 204/255, blue: 166/255, alpha: 1)
                
                //添加二维码小图标
                let rightImg: UIImageView = UIImageView.init(frame: CGRect(x: kScreenWidth-70, y: 15, width: 20, height: 20))
                rightImg.image = UIImage.init(named: tableCellModel.itemRightTitle)
                cell?.contentView.addSubview(rightImg)
                
            }else if indexPath.section == 1{
                
                var rightLable:UILabel
                rightLable = UILabel.init()
                rightLable.textAlignment = NSTextAlignment.right
                rightLable.font = UIFont.systemFont(ofSize: 14)
                rightLable.tag = 121
                rightLable.textColor = UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                
                
                switch (indexPath.row) {
                case 0:
                    //cell?.itemImage?.backgroundColor = UIColor.init(red: 239/255, green: 179/255, blue: 42/255, alpha: 1)
                    break
                case 1:
                    //cell?.itemImage?.backgroundColor = UIColor.init(red: 82/255, green: 204/255, blue: 166/255, alpha: 1)
                    rightLable.frame = CGRect(x: kScreenWidth-100, y: 15, width: 50, height: 20)
                    rightLable.text = String(fileSizeOfCache())+"M"
                    cell?.contentView.addSubview(rightLable)
                case 2:
                    //cell?.itemImage?.backgroundColor = UIColor.init(red: 53/255, green: 169/255, blue: 255/255, alpha: 1)
                    //应用程序信息
                    let infoDictionary = Bundle.main.infoDictionary!
                    let majorVersion = infoDictionary["CFBundleShortVersionString"]//主程序版本号
                    let appVersion:String = "V" + (majorVersion as! String)
                    rightLable.frame = CGRect(x: kScreenWidth-150, y: 15, width: 100, height: 20)
                    rightLable.text = appVersion
                    cell?.contentView.addSubview(rightLable)
                default:
                    cell?.itemImage?.backgroundColor = UIColor.init(red: 53/255, green: 169/255, blue: 255/255, alpha: 1)
                }
            }
        } else {
            //添加按钮
//            let logoutBtn:UIButton = UIButton.init(frame: CGRect(x: 30, y: 10, width: kScreenWidth-60, height: 40))
//            logoutBtn.center.x = self.view.center.x
//            logoutBtn.setTitle("退出登录", for: UIControlState.normal)
//            logoutBtn.backgroundColor = UIColor.red
//            cell?.contentView.addSubview(logoutBtn)
             //添加标题
            let btnLabel:UILabel = UILabel.init()
            btnLabel.text = "退出当前帐号"
            btnLabel.frame = CGRect(x: 20, y: 10, width: kSCREEN_WIDTH-40, height: 30)
            btnLabel.textColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
            //设置label在cell水平居中
            btnLabel.center.x = self.view.center.x
            //设置文本居中
            btnLabel.textAlignment = NSTextAlignment.center
            cell?.contentView.addSubview(btnLabel)
            
        }
        return cell!
    }
    
    //MARK - 业务组
    //获取app缓存文件的大小
    func fileSizeOfCache()-> Int {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        //缓存目录路径
        //print(cachePath ?? "")
        
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            
            // 把文件名拼接到路径中
            let path = cachePath?.appending("/\(file)")
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path!)
            // 用元组取出文件大小属性
            for (abc, bcd) in floder {
                // 累加文件大小
                if abc == FileAttributeKey.size {
                    size += (bcd as AnyObject).integerValue
                }
            }
        }
        
        let mm = size / 1024 / 1024
        
        return mm
    }
    
    //清除缓存
    func clearCache(selectedIndexPath:IndexPath) {
        var clearResult = false
        //使用第三方库MB
        MyProgressHUD.showStatusInfo("清理中...")
        
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        // 取出文件夹下所有文件数组
        
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        // 遍历删除
        
        for file in fileArr! {
            //下面两句是为了避免可能出现的崩溃现象
            if file.contains("Snapshots") { continue}
            
            if file.contains("com.fix.task") { continue}
            
            let path = (cachePath! as NSString).appending("/\(file)")
            
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    
                    try FileManager.default.removeItem(atPath: path)
                    clearResult = true
                } catch {
                    clearResult = false
                }
            }
        }
        if clearResult == true{
            //修改文字
            let selectedCell = personalTable.cellForRow(at: selectedIndexPath)
            let  rightLabel = selectedCell?.viewWithTag(121) as! UILabel
            rightLabel.text = "0M"
            MyProgressHUD.dismiss()
        }
    }
    
    //打开子页面
    func openChildVC(childNavName:UINavigationController) {
        self.hidesBottomBarWhenPushed = true
        self.present(childNavName, animated: true, completion: nil)
        self.hidesBottomBarWhenPushed = false
    }
    
    //显示确认框
    func showConfirm (confrimMessage:String, hanlderType:Int, selectedIndexPath:IndexPath) {
        
        
        let alertController = UIAlertController(title:"提示",message:confrimMessage,preferredStyle: .alert)
        let canceAction = UIAlertAction(title:"取消",style:.cancel,handler:nil)
        let okAciton = UIAlertAction(title:"确定",style:.default,handler: {action in
            switch (hanlderType){
            case 1:
                let selectedCell = self.personalTable.cellForRow(at: selectedIndexPath)
                let  rightLabel = selectedCell?.viewWithTag(121) as! UILabel
                if rightLabel.text == "0M"{
                    let alertVc = UIAlertController(title: "提示", message: "缓存无需清理", preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alertVc.addAction(closeAction)
                    self.present(alertVc, animated: true, completion: nil)
                }else{
                    self.clearCache(selectedIndexPath:selectedIndexPath)
                }
            case 2:
//                let login = LoginViewController()
//                let window = UIApplication.shared.delegate?.window
//                window!!.rootViewController = login
                /*如果登陆界面通过present方式跳转的话，并且是由TabBarController管理的，那么在退出时，
                 就得使用dismiss这种方式退出到登陆界面，
                 否则销毁不了其他控制器。*/
                self.tabBarController?.dismiss(animated: true, completion: nil)
            default:
                break
            }
            
        })
        alertController.addAction(canceAction);
        alertController.addAction(okAciton);
        self.present(alertController, animated: true, completion: nil)
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
