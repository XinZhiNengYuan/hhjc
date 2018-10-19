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
    let arrayForKey : Array<String> = ["设备名称"," 设备型号","所属位置","所属位置","所属位置","所属位置"]

    //获取屏幕宽度
    let screenWidth =  UIScreen.main.bounds.size.width
    //获取屏幕高度
    let screenHeight = UIScreen.main.bounds.size.height

//    let arrayForValue : Array<String> = ["燃气蒸汽锅炉","","","","",""]
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        // Do any additional setup after loading the view.
    }

    func setLayout(){
        self.title = "设备详情"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        view.backgroundColor = UIColor.white
        
        
        UiTableList.register(DeviceDetailCell.self, forCellReuseIdentifier: "DeviceDetail1")
        UiTableList.frame = CGRect(x: 20, y: 10, width: screenWidth-40, height: screenHeight-screenWidth/4)
        UiTableList.delegate = self
        UiTableList.dataSource = self
        //轮播图加载
        let pointY = 44 + UIApplication.shared.statusBarFrame.size.height
        let cycleView : CycleView = CycleView(frame: CGRect(x: 0, y: pointY, width: UIScreen.main.bounds.size.width, height: 220))
        cycleView.delegate = self
        cycleView.mode = .scaleAspectFill
        //本地图片测试--加载网络图片,请用第三方库如SDWebImage等
        cycleView.imageURLStringArr = ["banner01.jpg", "banner02.jpg", "banner03.jpg", "banner04.jpg"]
        UiTableList.tableHeaderView = cycleView
        view.addSubview(UiTableList)
        UiTableList.separatorStyle = UITableViewCellSeparatorStyle.none
    }




    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }

}

//MARK: CycleViewDelegate
extension DeviceDetailViewController {
    func cycleViewDidSelectedItemAtIndex(_ index: NSInteger) {
        print(index)
    }
}

extension DeviceDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = "DeviceDetailCell1"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellName) as? DeviceDetailCell
        if cell == nil{
            cell = DeviceDetailCell(style:UITableViewCellStyle.default,reuseIdentifier:cellName)
        }
        let index = indexPath.row
        cell?.mLabelLeft.text = arrayForKey[index]
        cell?.mLabelRight.text = "燃气蒸汽锅炉"
        return cell!
    }


}


