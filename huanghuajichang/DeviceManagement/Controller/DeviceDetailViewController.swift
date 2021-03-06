//
//  DeviceDetailViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/9/30.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit


class DeviceDetailViewController: UIViewController,CycleViewDelegate {

    let UiTableList = UITableView()
    var arrayForKey : Array<String> = []
    var arrayForVal : Array<String> = []
    var flagePageFrom : Int = 1 //1:默认表示从列表页面跳转过来，2:表示从搜索页跳转过来
    var eqCode : String = ""
    var eqId:String = ""
    let deviceDetailViewService = DeviceDetailViewService()
    let cameraViewController = CameraViewController()
    var cycleView : CycleView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "updateDeviceDetail"), object: nil)
    }
    
    //MARK:数据请求
    @objc func getData(){
        navigationController?.tabBarController?.tabBar.isHidden = true
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentByCode","user_id": userId as Any,"token": token as Any,"info":["code":eqCode]]
        deviceDetailViewService.getData(contentData: contentData, finishedData: { (resultData) in
            self.eqCode = resultData.equNo
            self.eqId = resultData.equId
            self.setVal(val: resultData, call: { (arrPic) in
                self.setLayout(arrPic: arrPic)
            })
        }) { (errorData) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
        }
    }
    
    //MARK:组装页面所需的数据
    func setVal(val:DeviceDetailViewModule,call:(_ picArr:[equPhotos])->()){
        arrayForVal = []
        arrayForKey = []
        //这两个数组顺序要保持一致
        arrayForVal.append(val.categoryNameSmall) //所属单位
        arrayForVal.append(val.equName) //设备名称
        arrayForVal.append(val.coOneAndcoTwo) //所属单位
        arrayForVal.append(val.specification) //规格型号
        arrayForVal.append("\(String(val.power)) KW") //功率
        arrayForVal.append(val.equNo) //设备标识
        arrayForVal.append(val.spName) //供应商
        
        arrayForVal.append(timeStampToString(timeStamp: val.manufactureDate)) //生产日期
        
        arrayForVal.append(timeStampToString(timeStamp: val.installDate)) //安装日期
        arrayForVal.append(val.buildInfo)
        
        arrayForKey.append("所属类型")
        arrayForKey.append("设备名称")
        arrayForKey.append("所属单位")
        arrayForKey.append("规格型号")
        arrayForKey.append("额定功率")
        arrayForKey.append("设备标识")
        arrayForKey.append("供应商")
        arrayForKey.append("生产日期")
        arrayForKey.append("安装日期")
        arrayForKey.append("楼层信息")
        call(val.photoList)
        
    }
    
    //MARK:样式设计
    func setLayout(arrPic imageListObjc : [equPhotos]){
        self.title = "设备详情"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromDeviceDetailViewController))
        view.backgroundColor = UIColor.white
        
        let rightEditBtn = UIBarButtonItem.init(title: "编辑", style: UIBarButtonItemStyle.done, target: self, action: #selector(openEdit))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: "PingFangSC-Regular", size: 6)!], for: UIControlState.normal)
        rightEditBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightEditBtn
        
        var mView : UIView!
        if flagePageFrom == 1{
            mView = UIView(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: KUIScreenHeight-navigationHeight))
        }else{
            mView = UIView(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: KUIScreenHeight))
        }
        
        mView.backgroundColor = UIColor.white
        UiTableList.register(DeviceDetailCell.self, forCellReuseIdentifier: "DeviceDetail1")
        UiTableList.frame = CGRect(x: 20, y: 0, width: mView.frame.width-40, height: mView.frame.height)
        UiTableList.delegate = self
        UiTableList.dataSource = self
        //轮播图加载
        let pointY = 54 + UIApplication.shared.statusBarFrame.size.height
        cycleView  = CycleView(frame: CGRect(x: 0, y: pointY, width: UiTableList.frame.width, height: 220))
        cycleView.delegate = self
        cycleView.mode = .scaleAspectFill
        //本地图片测试--加载网络图片,请用第三方库如SDWebImage等
        //拼装图片地址
        var imgList : [String] = []
        var imgIdListStr : String = ""
        for i in 0..<imageListObjc.count{
            //截取app接口地址
            let b  = appUrl.index(appUrl.endIndex, offsetBy: -10)
            let c = appUrl[appUrl.startIndex..<b]
            imgIdListStr = imgIdListStr + String(imageListObjc[i].fileId) + ","
            // 拼成可读取的图片地址到数组中
            imgList.append("\(String(describing: c))\(imageListObjc[i].filePath)")
        }
        if imgIdListStr.count > 0{
            let imgIndex = imgIdListStr.index(imgIdListStr.endIndex, offsetBy: -1)
            imgIdListStr = String(imgIdListStr.prefix(upTo: imgIndex))
        }
        cameraViewController.imgIdListStr = cameraViewController.imgIdListStr + imgIdListStr
        cameraViewController.deviceDetailPageImageList = cameraViewController.deviceDetailPageImageList + imgList
        cycleView.imageURLStringArr =  imgList.count>0 ? imgList : ["拍照"]
        UiTableList.tableHeaderView = cycleView
        UiTableList.tableHeaderView?.frame = CGRect(x: 0, y: 10, width: KUIScreenWidth, height: 220)
        mView.addSubview(UiTableList)
        view.addSubview(mView)
        UiTableList.reloadData()
        UiTableList.separatorStyle = UITableViewCellSeparatorStyle.none
        UiTableList.showsVerticalScrollIndicator = false
    }

    @objc func goBackFromDeviceDetailViewController(){
        navigationController?.tabBarController?.tabBar.isHidden = false
        if flagePageFrom != 3{
        self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openEdit(){
        let deviceEditVc = DeviceEditViewController()
        self.hidesBottomBarWhenPushed = true
        deviceEditVc.pageType = "edit"
        deviceEditVc.deviceEditNo = self.eqCode
        deviceEditVc.deviceEditId = self.eqId
        if flagePageFrom == 1{//1:默认表示从列表页面跳转过来，2:表示从搜索页跳转过来
            deviceEditVc.isSearchFrom = false
        }else{
            deviceEditVc.isSearchFrom = true
        }
        self.navigationController?.pushViewController(deviceEditVc, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateDeviceDetail"), object: nil)
    }

}

//MARK: CycleViewDelegate
extension DeviceDetailViewController {
    //轮播图的点击代理方法
    func cycleViewDidSelectedItemAtIndex(_ index: NSInteger) {
//        cameraViewController.flagePageFrom = self.flagePageFrom
//        cameraViewController.equNo = eqCode
//        navigationController?.pushViewController(cameraViewController, animated: true)
    }
}

extension DeviceDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayForKey.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = "DeviceDetailCell1"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellName) as? DeviceDetailCell
        if cell == nil{
            cell = DeviceDetailCell(style:UITableViewCellStyle.default,reuseIdentifier:cellName)
        }
        let index = indexPath.row
        cell?.mLabelLeft.text = arrayForKey[index]
        if arrayForKey[index] == "供应商"{
            cell?.mLabelRight.frame = CGRect(x: 90, y: 0, width: UIScreen.main.bounds.size.width - 130, height: 40)
            cell?.mLabelRight.textAlignment = .center
        }else{
            cell?.mLabelRight.frame = CGRect(x: 90, y: 5, width: UIScreen.main.bounds.size.width - 130, height: 40)
            cell?.mLabelRight.textAlignment = .left
        }
        cell?.mLabelRight.text = arrayForVal[index]
        return cell!
    }


    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
//        self.navigationController?.pushViewController(AlarmAnalysisViewController(), animated: true)
        
    }
}


