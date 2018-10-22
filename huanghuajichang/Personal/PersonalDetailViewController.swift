//
//  PersonalDetailViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/22.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class PersonalDetailViewController: AddNavViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PersonalDetailList:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        // Do any additional setup after loading the view.
        createTabList()
    }
    
    func createTabList(){
        PersonalDetailList = UITableView.init(frame: CGRect(x: 5, y: 5, width: kScreenWidth-10, height: kScreenHeight-64-5))
        PersonalDetailList.separatorStyle = .none
        PersonalDetailList.delegate = self
        PersonalDetailList.dataSource = self
        PersonalDetailList.backgroundColor = allListBackColor
        self.view.backgroundColor = allListBackColor
        self.view.addSubview(PersonalDetailList)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70
        }else{
          return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PersonalDetailTableViewCell
        if cell == nil {
            
            cell = PersonalDetailTableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "cell")
            //这句话去掉默认点击效果
//            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            //            NSLog("初始化cell")
            
        }
        if indexPath.row == 0{
            cell?.setUpUI(isHeaderView: true, hasRightIcon: true,cellSize:CGSize(width: kScreenWidth-10, height: 70))
            cell?.itemTitle.text = "头像"
            cell?.itemImage.image = UIImage(named: "Bitmap")
            tableView.allowsSelection = true
        }else if indexPath.row == 4 || indexPath.row == 5 {
            cell?.setUpUI(isHeaderView: false, hasRightIcon: true,cellSize:CGSize(width: kScreenWidth-10, height: 50))
            switch indexPath.row {
            case 4:
                cell?.itemTitle.text = "手机号"
                break
            case 5:
                cell?.itemTitle.text = "邮箱"
                break
            default:
                cell?.itemTitle.text = ""
            }
            cell?.itemRealMsg.text = "内容\(indexPath.row)"
            tableView.allowsSelection = true
        }else {
            cell?.setUpUI(isHeaderView: false, hasRightIcon: false,cellSize:CGSize(width: kScreenWidth-10, height: 50))
            switch indexPath.row {
            case 1:
                cell?.itemTitle.text = "登录名"
                break
            case 2:
                cell?.itemTitle.text = "部门"
                break
            case 3:
                cell?.itemTitle.text = "客户"
                break
            default:
                cell?.itemTitle.text = ""
            }
            
            cell?.itemRealMsg.text = "内容\(indexPath.row)"
            tableView.allowsSelection = false
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let headerVc = HeaderViewController()
            let hederNav = UINavigationController(rootViewController: headerVc)
            self.present(hederNav, animated: false, completion: nil)
        default:
            print("other")
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
