//
//  GuidViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/12/15.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit


class GuideViewController: UIViewController {
    var scrollView:UIScrollView!
    var pageControl:UIPageControl!
    var startBtn:UIButton!
    var imageData:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageData = ["引导页1","引导页2","引导页3"]
        // Do any additional setup after loading the view.
        loadCustomLayout()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //载入自定义布局
    func loadCustomLayout(){
        scrollView=UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        scrollView.isPagingEnabled=true
        scrollView.showsHorizontalScrollIndicator=false
        scrollView.showsVerticalScrollIndicator=false
        scrollView.contentSize=CGSize(width: 3*kScreenWidth, height: kScreenHeight)
        for i in imageData.enumerated(){
            let image=UIImage(named: imageData[i.offset] as! String)
            let imageView=UIImageView(image: image)
            imageView.frame=CGRect(x: CGFloat(i.offset)*kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight)
            imageView.contentMode = UIViewContentMode.scaleToFill
            scrollView.addSubview(imageView)
            
        }
        pageControl=UIPageControl(frame: CGRect(x: kScreenWidth/2-100, y: kScreenHeight-100, width: 200, height: 100))
        startBtn=UIButton(frame: CGRect(x: kScreenWidth/2-95, y: kScreenHeight-bottomSafeAreaHeight - 60, width: 190, height: 35))
        pageControl.addTarget(self, action: #selector(pageChangeSroll(sender:)), for: UIControlEvents.valueChanged)
        pageControl.numberOfPages=imageData.count
        pageControl.currentPage=0
        
        startBtn.setTitle("马上体验", for: UIControlState.normal)
        startBtn.backgroundColor = UIColor.white
        startBtn.layer.cornerRadius = 10
        startBtn.setTitleColor(UIColor(red: 12/255, green: 128/255, blue: 231/255, alpha: 1), for: UIControlState.normal)
        startBtn.addTarget(self, action: #selector(guideOver), for: UIControlEvents.touchUpInside)
        startBtn.isHidden=true
        
        
        scrollView.bounces=false
        scrollView.delegate=self
        self.view.addSubview(scrollView)
        self.view.addSubview(pageControl)
        self.view.addSubview(startBtn)
        
    }
    
    @objc func pageChangeSroll(sender:UIPageControl){
        let scrollViewsize = self.scrollView.frame.size
        let rect=CGRect(x: CGFloat(sender.currentPage)*scrollViewsize.width, y: 0, width: scrollViewsize.width, height: scrollViewsize.height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    //开始使用app
    @objc func guideOver(){
        let login = LoginViewController()
        self.present(login, animated: true, completion: nil)
    }
    
    
}
extension GuideViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset=scrollView.contentOffset
            pageControl.currentPage=Int(offset.x/kScreenWidth)
            if(pageControl.currentPage == imageData.count - 1){
                startBtn.isHidden=false
            }else{
                startBtn.isHidden=true
            }
    }
}
