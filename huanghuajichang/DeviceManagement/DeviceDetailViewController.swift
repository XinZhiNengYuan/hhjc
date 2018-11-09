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
    var equId : Int = -1
    let deviceDetailViewService = DeviceDetailViewService()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData(id: equId)
    }
    //MARK:数据请求
    func getData(id:Int){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String:Any] = ["method":"getEquipmentById","user_id": userId as Any,"token": token as Any,"info":["oneId":"","twoId":"","id":id]]
        deviceDetailViewService.getData(contentData: contentData, finishedData: { (resultData) in
            self.setVal(val: resultData, call: {
                self.setLayout()
            })
        }) { (errorData) in
            self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
        }
    }
    
    //MARK:组装页面所需的数据
    func setVal(val:DeviceDetailViewModule,call:()->()){
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
        call()
        
    }
    //MARK:样式设计
    func setLayout(){
        self.title = "设备详情"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        view.backgroundColor = UIColor.white
        
        
        UiTableList.register(DeviceDetailCell.self, forCellReuseIdentifier: "DeviceDetail1")
        UiTableList.frame = CGRect(x: 20, y: 0, width: KUIScreenWidth-40, height: KUIScreenHeight)
        UiTableList.delegate = self
        UiTableList.dataSource = self
        //轮播图加载
        let pointY = 54 + UIApplication.shared.statusBarFrame.size.height
        let cycleView : CycleView = CycleView(frame: CGRect(x: 0, y: pointY, width: KUIScreenWidth, height: 220))
        cycleView.delegate = self
        cycleView.mode = .scaleAspectFill
        //本地图片测试--加载网络图片,请用第三方库如SDWebImage等
        cycleView.imageURLStringArr = ["banner01.jpg", "banner02.jpg", "banner03.jpg", "banner04.jpg"]
        UiTableList.tableHeaderView = cycleView
        view.addSubview(UiTableList)
        UiTableList.separatorStyle = UITableViewCellSeparatorStyle.none
        UiTableList.showsVerticalScrollIndicator = false
    }

    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }

}

//MARK: CycleViewDelegate
extension DeviceDetailViewController {
    func cycleViewDidSelectedItemAtIndex(_ index: NSInteger) {
        navigationController?.pushViewController(CameraViewController(), animated: true)
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
        self.navigationController?.pushViewController(AlarmAnalysisViewController(), animated: true)
        
    }
}


