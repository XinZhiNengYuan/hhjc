//
//  AddNavViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/21.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import Kingfisher

class AddNavViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //action后的方法名如果加“：”则方法里面需要传button；如果没有“：”，则空着即可
        //只有文字
        //        let item = UIBarButtonItem(title: "done", style: UIBarButtonItemStyle.done, target: self, action: #selector(HelpDocumentViewController.backToparent))
        //        self.navigationItem.leftBarButtonItem = item
        
        //设置只有图片显示
        let leftBarBtn = UIBarButtonItem(title: "", style: .plain, target: self,
                                         action: #selector(backItemPressed))
        leftBarBtn.image = UIImage(named: "返回")
        //用于消除左边空隙，要不然按钮顶不到最前面;实际发现可以没有
        //        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
        //                                     action: nil)
        //        spacer.width = -10
        //        spacer.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        leftBarBtn.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false//去掉导航栏的半透明效果
        self.navigationItem.leftBarButtonItem = leftBarBtn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backItemPressed(){
        //present出的页面用dismiss不然会找不到上一页
        self.dismiss(animated: true, completion: nil)
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
