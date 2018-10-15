//
//  ChangePasswordViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/20.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit

class ChangePasswordViewController: AddNavViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        self.title = "更改密码"
        createUI()
    }
    
    func createUI () {
        for i in 0...1 {
            let numberCell: UIButton = UIButton.init(frame: CGRect(x: 0, y: CGFloat(i*80 + 40), width: kScreenWidth, height: 50))
            numberCell.layer.borderWidth = 1
            numberCell.layer.borderColor = UIColor.init(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) .cgColor
            numberCell.layer.masksToBounds = true
            numberCell.tag = i
            numberCell.backgroundColor = UIColor.white
            numberCell.addTarget(self, action: #selector(openChange(btn:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(numberCell)
            
            let numberLabel:UILabel = UILabel.init(frame: CGRect(x: 20, y: 15, width: kScreenWidth-60, height: 20))
            if i==0 {
                numberLabel.text = "更改输入密码"
            }else{
                numberLabel.text = "更改手势密码"
            }
            let rightButton:UIButton = UIButton.init(frame: CGRect(x: kScreenWidth-40, y: 15, width: 20, height: 20))
            rightButton.setImage(UIImage.init(named: "rightBtn"), for: UIControlState.normal)
            
            
            numberCell.addSubview(numberLabel)
            numberCell.addSubview(rightButton)
        }
        
    }
    
    @objc func openChange(btn:UIButton){
        print(btn.tag)
        print(btn.state)
        if btn.state == UIControlState(rawValue: 1) {
            btn.backgroundColor = UIColor.gray
            UIView.animate(withDuration: 2) {
                btn.backgroundColor = UIColor.white
            }
            let numberViewController = ChangeNumberPasswordViewController()
            self.navigationController?.pushViewController(numberViewController, animated: true)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
