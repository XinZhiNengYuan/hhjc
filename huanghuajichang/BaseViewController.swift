//
//  BaseViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/8.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor(red: 52/255, green: 129/255, blue: 229/255, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false

        // Do any additional setup after loading the view.
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
