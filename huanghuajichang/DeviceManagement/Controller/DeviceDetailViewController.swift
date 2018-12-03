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
    let deviceDetailViewService = DeviceDetailViewService()
    let cameraViewController = CameraViewController()
    var cycleView : CycleView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData(eqCode: eqCode)
    }
    
    //MARK:数据请求
    func getData(eqCode:String){
        navigationController?.tabBarController?.tabBar.isHidden = true
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentByCode","user_id": userId as Any,"token": token as Any,"info":["id":eqCode]]
        deviceDetailViewService.getData(contentData: contentData, finishedData: { (resultData) in
            self.setVal(val: resultData, call: { (arrPic) in
                self.setLayout(arrPic: arrPic)
            })
        }) { (errorData) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
        }
    }
    
    //MARK:组装页面所需的数据
    func setVal(val:DeviceDetailViewModule,call:(_ picArr:[equPhotos])->()){
        //这两个数组顺序要保持一致
        arrayForVal.append(val.categoryNameSmall) //所属单位
        arrayForVal.append(val.equName) //设备名称
        arrayForVal.append(val.coOneAndcoTwo) //所属单位
        arrayForVal.append(val.specification) //规格型号
        arrayForVal.append(String(val.power)) //功率
        arrayForVal.append(val.kksCode) //设备标识
        arrayForVal.append(val.spName) //供应商
        arrayForVal.append(val.manufactureDate) //生产日期
        arrayForVal.append(val.installDate) //安装日期
        
        
        arrayForKey.append("所属类型")
        arrayForKey.append("设备名称")
        arrayForKey.append("所属单位")
        arrayForKey.append("规格型号")
        arrayForKey.append("功率")
        arrayForKey.append("设备标识")
        arrayForKey.append("供应商")
        arrayForKey.append("生产日期")
        arrayForKey.append("安装日期")
        call(val.photoList)
        
    }
    
    //MARK:样式设计
    func setLayout(arrPic imageListObjc : [equPhotos]){
        self.title = "设备详情"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBackFromDeviceDetailViewController))
        view.backgroundColor = UIColor.white
        var mView : UIView!
        if flagePageFrom == 1{
            mView = UIView(frame: CGRect(x: 0, y: 20, width: KUIScreenWidth, height: KUIScreenHeight-(navigationController?.navigationBar.frame.height)!-UIApplication.shared.statusBarFrame.height-20))
        }else{
            mView = UIView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.height)!+UIApplication.shared.statusBarFrame.height+20, width: KUIScreenWidth, height: KUIScreenHeight-(navigationController?.navigationBar.frame.height)!-UIApplication.shared.statusBarFrame.height-20))
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
        mView.addSubview(UiTableList)
        view.addSubview(mView)
        UiTableList.separatorStyle = UITableViewCellSeparatorStyle.none
        UiTableList.showsVerticalScrollIndicator = false
    }

    @objc func goBackFromDeviceDetailViewController(){
        navigationController?.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }

}

//MARK: CycleViewDelegate
extension DeviceDetailViewController {
    func cycleViewDidSelectedItemAtIndex(_ index: NSInteger) {
        cameraViewController.flagePageFrom = self.flagePageFrom
        cameraViewController.equNo = eqCode
        navigationController?.pushViewController(cameraViewController, animated: true)
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
        cell?.mLabelRight.text = arrayForVal[index]
        return cell!
    }


    //tableView点击事件
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
//        self.navigationController?.pushViewController(AlarmAnalysisViewController(), animated: true)
        
    }
}


