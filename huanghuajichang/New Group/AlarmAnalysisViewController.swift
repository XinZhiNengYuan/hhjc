//
//  AlarmAnalysisViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Charts.Swift

class AlarmAnalysisViewController: UIViewController {
    
    var headerView : UIView!
    let buttons:NSMutableArray = ["当日", "当月", "当年"]
    // 把类定义成属性
    let tabButton = TabButton()
    // view
    var  buttonView:UIView!
    
    var scrollView : UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1).cgColor
        self.title = "报警分析"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        setHeader()
        setContentView()
    }
    func setHeader(){
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: 100))
        headerView.layer.backgroundColor = UIColor(red: 166/255, green: 201/255, blue: 237/255, alpha: 1).cgColor
        let image = UIImageView(frame: CGRect(x: 15, y: 15, width: 20, height: 20))
        image.image = UIImage(named: "alarm")
        headerView.addSubview(image)
        let textLabel = UILabel(frame: CGRect(x: 45, y: 15, width: 200, height: 20))
        textLabel.textColor = UIColor.white
        textLabel.text = "2018-05-01 12:23:34"
        headerView.addSubview(textLabel)
        let dec = UILabel(frame: CGRect(x: 20, y: 60, width: KUIScreenWidth-100, height: 20))
        dec.text = "1#发电机缸套水出口温度过高"
        dec.textColor = UIColor.white
        headerView.addSubview(dec)
        let status = UILabel(frame: CGRect(x: KUIScreenWidth-100, y: 30, width: 80, height: 40))
        status.text = "已恢复"
        status.textColor = UIColor.blue
        headerView.addSubview(status)
        view.addSubview(headerView)
    }
    func setContentView(){
        let contentView = UIView(frame: CGRect(x: 0, y: 110, width: KUIScreenWidth, height: 160))
        contentView.layer.backgroundColor = UIColor.white.cgColor
        // 先删除
        if buttonView != nil{
            buttonView.removeFromSuperview()
            buttonView = nil
        }
        // 再创建
        buttonView = tabButton.creatLineButton(buttonsFrame:CGRect(x: 15, y: 10, width: KUIScreenWidth-30, height: 30), dataArr: buttons)
        tabButton.delegate = self
        
        contentView.addSubview(buttonView)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 1))
        spearLine.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        contentView.addSubview(spearLine)
        
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: 120))
        scrollView.contentSize = CGSize(width: kScreenWidth*3, height: scrollView.frame.height)
        //设置起始偏移量
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        //隐藏水平指示条
        scrollView.showsHorizontalScrollIndicator = false
        //隐藏竖直指示条
        scrollView.showsVerticalScrollIndicator = false
        //开启分页效果
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        //设置代理
        scrollView.delegate = self
        contentView.addSubview(scrollView)
        
        view.addSubview(contentView)
        
        for i in 0..<3 {
            //设置柱状图
            if i == 0 {
                
            }else if i==1 {
                
            }else{
                
            }
        }
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension AlarmAnalysisViewController:TabButtonDelagate{
    func clickChangePage(_ tabButton: TabButton, buttonIndex: NSInteger) {
        print(buttonIndex)
    }
}

extension AlarmAnalysisViewController:UIScrollViewDelegate{
    //scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _ = scrollView.contentOffset.x / kScreenWidth
        //        pageControl!.currentPage = Int(offset)
    }
}
