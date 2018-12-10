//
//  PersonalDetailViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/22.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import SwiftyJSON


class PersonalDetailViewController: AddNavViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PersonalDetailList:UITableView!
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var json:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        // Do any additional setup after loading the view.
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        self.createTabList()
    }
    
    //每次进入页面刷新数据
    override func viewWillAppear(_ animated: Bool) {
        if PersonalDetailList != nil {
            getData()
        }
    }
    
    func getData(){
        let contentData : [String : Any] = ["method":"getUserInfo","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
            switch resultData.result {
            case .success(let value):
                self.json = JSON(value)["data"]
                print(self.json)
                print(JSON(value)["status"].description)
                if JSON(value)["status"].stringValue == "success"{
                    self.userDefault.set(self.json["email"].object, forKey: "UserEmail")
                    self.userDefault.set(self.json["mobile"].object, forKey: "UserMobile")
                    let imgurl = "http://" + self.userDefault.string(forKey: "AppUrlAndPort")! + (self.json["url"].stringValue)
                    self.userDefault.set(imgurl, forKey: "UserHeaderImg")
                    self.PersonalDetailList.reloadData()
                    self.PersonalDetailList.layoutIfNeeded()
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
    
    func createTabList(){
        PersonalDetailList = UITableView.init(frame: CGRect(x: 5, y: 5, width: kScreenWidth-10, height: kScreenHeight-navigationHeight-5))
        PersonalDetailList.separatorStyle = .none
        PersonalDetailList.delegate = self
        PersonalDetailList.dataSource = self
        PersonalDetailList.backgroundColor = allListBackColor
        self.view.backgroundColor = allListBackColor
        self.view.addSubview(PersonalDetailList)
        getData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70
        }else{
          return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.cellForRow(at: indexPath) as? PersonalDetailTableViewCell
        if cell == nil {
            
            cell = PersonalDetailTableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "cell")
            //这句话去掉默认点击效果
//            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            //            NSLog("初始化cell")
            
        }else {
//            cell?.removeFromSuperview()
            while cell?.contentView.subviews.last != nil {
                (cell?.contentView.subviews.last)?.removeFromSuperview()
            }
        }
        if indexPath.row == 0{
            cell?.setUpUI(isHeaderView: true, hasRightIcon: true,cellSize:CGSize(width: kScreenWidth-10, height: 70))
            cell?.itemTitle.text = "头像"
            let imgurl = "http://" + userDefault.string(forKey: "AppUrlAndPort")! + (json["url"].stringValue)
            cell?.itemImage.dowloadFromServer(link:imgurl as String, contentMode: .scaleAspectFill)
            cell?.itemImage.layer.cornerRadius = (cell?.itemImage.frame.width)! / 2
            // image还需要加上这一句, 不然无效
            cell?.itemImage.layer.masksToBounds = true
            tableView.allowsSelection = true
        }else if indexPath.row == 3 || indexPath.row == 4 {
            cell?.setUpUI(isHeaderView: false, hasRightIcon: true,cellSize:CGSize(width: kScreenWidth-10, height: 50))
            switch indexPath.row {
            case 3:
                cell?.itemTitle.text = "手机号"
                cell?.itemRealMsg.text = json["mobile"].stringValue
                break
            case 4:
                cell?.itemTitle.text = "邮箱"
                cell?.itemRealMsg.text = json["email"].stringValue
                break
            default:
                cell?.itemTitle.text = ""
                cell?.itemRealMsg.text = "内容\(indexPath.row)"
            }
            tableView.allowsSelection = true
        }else {
            cell?.setUpUI(isHeaderView: false, hasRightIcon: false,cellSize:CGSize(width: kScreenWidth-10, height: 50))
            switch indexPath.row {
            case 1:
                cell?.itemTitle.text = "登录名"
                cell?.itemRealMsg.text = json["user_name"].stringValue
                break
            case 2:
                cell?.itemTitle.text = "部门"
                cell?.itemRealMsg.text = ""//TODO
                break
            default:
                cell?.itemTitle.text = ""
                cell?.itemRealMsg.text = "内容\(indexPath.row)"
            }
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
        case 3:
            let changePhoneVc = CommentChangeViewController()
            let changePhoneNav = UINavigationController(rootViewController: changePhoneVc)
            changePhoneVc.title = "修改手机号"
            changePhoneVc.phoneText = (tableView.cellForRow(at: indexPath) as! PersonalDetailTableViewCell).itemRealMsg.text
            self.present(changePhoneNav, animated: false, completion: nil)
        case 4:
            let changeEmailVc = CommentChangeViewController()
            let changeEmailNav = UINavigationController(rootViewController: changeEmailVc)
            changeEmailVc.title = "修改邮箱"
            changeEmailVc.emailText = (tableView.cellForRow(at: indexPath) as! PersonalDetailTableViewCell).itemRealMsg.text
            self.present(changeEmailNav, animated: false, completion: nil)
        default:
            print("other")
        }
        //点击后颜色恢复
        tableView.deselectRow(at: indexPath, animated: true)
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
