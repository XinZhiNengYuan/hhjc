//
//  DeviceDetailViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/9/30.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController {

    let mView = UIView()
    let UiTableList = UITableView()
    let arrayForKey : Array<String> = ["设备名称"," 设备型号","所属位置","所属位置","所属位置","所属位置"]
//    let arrayForValue : Array<String> = ["燃气蒸汽锅炉","","","","",""]
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        // Do any additional setup after loading the view.
    }
    
    func setLayout(){
        mView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let listImages = UIView(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.size.width-20, height: 120))
        listImages.backgroundColor = UIColor.white
        listImages.layer.borderColor = UIColor.gray.cgColor
        listImages.layer.borderWidth = 1
        mView.addSubview(listImages)
        
        UiTableList.register(DeviceDetailCell.self, forCellReuseIdentifier: "DeviceDetail1")
        UiTableList.frame = CGRect(x: 0, y: 140, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-140)
        UiTableList.delegate = self
        UiTableList.dataSource = self
        mView.addSubview(UiTableList)
        UiTableList.separatorStyle = UITableViewCellSeparatorStyle.none
        mView.layer.backgroundColor = UIColor.white.cgColor
        view.addSubview(mView)
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
