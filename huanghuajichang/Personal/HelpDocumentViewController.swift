//
//  HelpDocumentViewController.swift
//  XinaoEnergy
//
//  Created by jun on 2018/8/8.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import WebKit

class HelpDocumentViewController: AddNavViewController,WKNavigationDelegate, WKUIDelegate {
    //直接声明
//    private var myWKWebView = WKWebView()
    private var progressView = UIProgressView()
    var open_url:String = "https://www.baidu.com"
    //懒加载wkWebView
    /*
     近期项目在使用WKWebView替代UIWebView，发现WKWebView竟然不能通过xib拖拽创建，只能通过手写代码实现。
     手写代码麻烦之处在于创建一个对象时需要设置很多关联属性，比如创建WKWebView对象，需要赋值navigationDelegate、布局frame，以及其他的相关属性，
     在未来的某个时期可能会增加更多的关联属性的设置，这样在-viewDidLoad中代码会越来越多，
     使用懒加载无疑可以将创建对象、设置对象属性的操作内聚于懒加载内部，减少-viewDidLoad中的代码量和复杂度，代码更具有可读性。
     */
//    lazy var wkWebView: WKWebView = {
//        () -> WKWebView in
//        let tempWebView = WKWebView()
//        tempWebView.navigationDelegate = self
//        return tempWebView
//    }()
    //进一步简化后的懒加载
    lazy var myWKWebView: WKWebView = {
        let tempWebView = WKWebView()
        tempWebView.navigationDelegate = self
        tempWebView.uiDelegate = self
        return tempWebView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "帮助文档"
        
        //传统webview的使用
//        let myWebView:UIWebView = UIWebView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
//        myWebView.backgroundColor = UIColor.white
//
//        let path = Bundle.main.path(forResource: "咕咚APP截图操作", ofType: "pdf")
//        let url = NSURL(fileURLWithPath: path!)
//        let urlRequest = NSURLRequest(url: url as URL)
//
//        myWebView.loadRequest(urlRequest as URLRequest)
//        self.view.addSubview(myWebView)
        
        //wkwebView的使用
        myWKWebView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-navigationHeight))//将navigationbar的高度减去，不然会显示不全
        myWKWebView.backgroundColor = UIColor.white
//        self.automaticallyAdjustsScrollViewInsets = false//具体什么效果未知
        
        //懒加载处已写
//        myWKWebView.navigationDelegate = self
//        myWKWebView.uiDelegate = self;
        
        //加载本地文件
//        let wkPath = Bundle.main.path(forResource: "咕咚APP截图操作", ofType: "pdf")
//        let wkUrl = NSURL(fileURLWithPath: wkPath!)
//        let wkUrlRequest = NSURLRequest(url: wkUrl as URL)
//        myWKWebView.load(wkUrlRequest as URLRequest)
        
        //加载网页
        let url = URL(string: open_url)
        let request = URLRequest(url: url!)
        myWKWebView.load(request)
        
        self.view.addSubview(myWKWebView)
        
        myWKWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        progressView = UIProgressView(frame: CGRect(x: 0, y: 44-2, width: UIScreen.main.bounds.size.width, height: 2))
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = UIColor.orange
        self.navigationController?.navigationBar.addSubview(progressView)
        
        

    }
    
    override func backItemPressed() {
        if myWKWebView.canGoBack {
            myWKWebView.goBack()
        }else{
            if let nav = self.navigationController {
//                nav.popViewController(animated: true)
                nav.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = myWKWebView.estimatedProgress == 1
            progressView.setProgress(Float(myWKWebView.estimatedProgress), animated: true)
            //progresss实时打印
//            print(myWKWebView.estimatedProgress)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
        self.navigationItem.title = webView.title
    }
    
    //离开页面，移除进度条监听
    deinit {
        print("con is deinit")
        myWKWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        progressView.reloadInputViews()
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
