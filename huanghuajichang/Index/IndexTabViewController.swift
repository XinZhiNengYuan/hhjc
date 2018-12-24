//
//  IndexTabViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Charts.Swift
import Alamofire
import SwiftyJSON
import MJRefresh

class IndexTabViewController: BaseViewController,UINavigationControllerDelegate,ChartViewDelegate {
    
    var collectionView:UICollectionView!
    var bottomCollectionView:UICollectionView!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var mainPointData:JSON = []
    var mainEchartsData:JSON = []
    var maxId:Int = 0
    
    let buttons:NSMutableArray = ["功率构成", "电量曲线", "负荷曲线"]
    // 把类定义成属性
    let linebutton = LineButton()
    // view
    var  buttonView:UIView!
    
    var scrollView:UIScrollView!
    ///功率饼图
    let pieChartView = PieChartView()
    ///电量曲线
    let electricLineChartView = LineChartView()
    ///负荷曲线
    let fuheLineChartView = LineChartView()
    
    var electricLineCircleColors:[UIColor]!=[]
    var fuheLineCircleColors:[UIColor]!=[]
    
    var rightBarButtonItem:UIBarButtonItem?
    
    var rightBarButton:UIButton!
    
    var allContentView:UIScrollView!
    
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "智慧能源管理系统"
        self.navigationController?.title = "首页"
        //         rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "报警"), style: UIBarButtonItemStyle.done, target: self, action: #selector(getNewMsg(sender:)))
        //        rightBarButtonItem?.tintColor = UIColor.white//必须设置颜色，不然不出现～
        //        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        rightBarButton = UIButton.init()
        rightBarButton.setImage(UIImage(named: "报警"), for: UIControlState.normal)
        rightBarButton.tintColor = UIColor.white
        rightBarButton.tag = 8000
        rightBarButton.addTarget(self, action: #selector(openAlarm), for: UIControlEvents.touchUpInside)
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(customView: rightBarButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        userToken = self.userDefault.object(forKey: "userToken") as? String
        userId = self.userDefault.object(forKey: "userId") as? String
        
        // Do any additional setup after loading the view.
        deviceTotal()
        createMiddleTab()
        currentNew()
        getCurrentNew()
        //        getElectricControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let openStatus = self.userDefault.object(forKey: "hasOpenAlarmList")
        if openStatus == nil || openStatus as! Bool == false{
            maxId = 0
        }else{
            maxId = self.userDefault.integer(forKey: "maxId")
        }
        getALarmCount()
    }
    
    func getALarmCount(){
        MyProgressHUD.showStatusInfo("数据加载中...")
        let infoData = ["id":maxId]
        let contentData : [String : Any] = ["method":"getNewAlarmCount","info":infoData,"token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            //            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    //                    print(JSON(value)["data"])
                    self.userDefault.set(JSON(value)["data"]["maxAlarmId"].intValue, forKey: "maxId")
                    //刷新页面数据
                    if JSON(value)["data"]["newAlarmCount"].intValue > 0{
                        self.addNewMsg(msgNum: JSON(value)["data"]["newAlarmCount"].intValue)
                        self.userDefault.set(false, forKey: "hasOpenAlarmList")
                    }else{
                        self.removeMsg()
                    }
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///有新消息时，添加消息展示
    @objc func addNewMsg(msgNum:Int){
        let alarmBtn = self.navigationItem.rightBarButtonItem?.customView?.viewWithTag(8000) as! UIButton
        self.navigationItem.rightBarButtonItem = alarmBtn.addMessage(operateBtn:alarmBtn, msg: msgNum.description)
    }
    
    ///无新消息展示，或者已被点击过后
    @objc func removeMsg(){
        let alarmBtn = self.navigationItem.rightBarButtonItem?.customView?.viewWithTag(8000) as! UIButton
        self.navigationItem.rightBarButtonItem = alarmBtn.removeMessage(operateBtn: alarmBtn, msg: "")
    }
    
    @objc func openAlarm(){
        let AlarmListVc = AlarmListViewController()
        self.hidesBottomBarWhenPushed = true
        self.userDefault.set(true, forKey: "hasOpenAlarmList")
        self.navigationController?.pushViewController(AlarmListVc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    
    //设备汇总
    func deviceTotal() {
        allContentView = UIScrollView.init(frame: self.view.bounds)
        allContentView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        self.view.addSubview(allContentView)
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 136))
        topView.backgroundColor = UIColor.white
        allContentView.addSubview(topView)
        
        let topLabel:UILabel = UILabel.init(frame: CGRect(x: 15, y: 10, width: kScreenWidth-30, height: 20))
        topLabel.text = "设备汇总"
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textColor = allFontColor
        topLabel.numberOfLines = 0
        topView.addSubview(topLabel)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        topView.addSubview(spearLine)
        
        let layout = UICollectionViewFlowLayout.init()
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: 95), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.tag = 1
        collectionView.delegate = self
        collectionView.dataSource = self
        topView.addSubview(collectionView)
        
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(IndexTopCollectionViewCell().classForCoder, forCellWithReuseIdentifier: "topCollectionCell")
    }
    
    
    
    //功率，电量，负荷
    func createMiddleTab() {
        let middleView:UIView = UIView.init(frame: CGRect(x: 0, y: 146, width: kScreenWidth, height: kScreenHeight-146*2-navigationHeight - tabBarHeight))
        middleView.backgroundColor = UIColor.white
        allContentView.addSubview(middleView)
        
        // 先删除
        if buttonView != nil{
            buttonView.removeFromSuperview()
            buttonView = nil
        }
        // 再创建
        buttonView = linebutton.creatLineButton(buttonsFrame:CGRect(x: 15, y: 10, width: kScreenWidth-30, height: 30), dataArr: buttons)
        linebutton.delegate = self
        
        //buttonView.center = view.center
        middleView.addSubview(buttonView)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        middleView.addSubview(spearLine)
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: middleView.frame.height-41))
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
        middleView.addSubview(scrollView)
        //        let colors:[UIColor] = [UIColor.red,UIColor.orange,UIColor.yellow]
        for i in 0..<3 {
            //            let tmpView:UIView = UIView(frame: CGRect(x:kScreenWidth * CGFloat(i), y:0, width:kScreenWidth, height:scrollView.frame.height))
            //            tmpView.backgroundColor = colors[i]
            //            scrollView.addSubview(tmpView)
            if i == 0 {
                test3()
            }else if i==1 {//电量曲线
                test2(lineChartView:electricLineChartView, originX: i)
            }else{//负荷曲线
                test2(lineChartView:fuheLineChartView, originX: i)
            }
        }
        self.getElectricControl()
        
    }
    
    func pageControlChanged(pageControl:UIPageControl) {
        let page = pageControl.currentPage
        
        print("当前显示的是第\(page+1)页")
        
    }
    
    //本月新增
    func currentNew() {
        let topHeight:CGFloat = kScreenHeight - navigationHeight - tabBarHeight - 136
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: topHeight, width: kScreenWidth, height: 136))
        topView.backgroundColor = UIColor.white
        allContentView.addSubview(topView)
        
        let topLabel:UILabel = UILabel.init(frame: CGRect(x: 15, y: 10, width: kScreenWidth-50, height: 20))
        topLabel.text = "本月新增"
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textColor = allFontColor
        topLabel.numberOfLines = 0
        topView.addSubview(topLabel)
        
        let newRightBtn:UIButton = UIButton.init(frame: CGRect(x: kScreenWidth-35, y: 10, width: 20, height: 20))
        
        //下面这句即取图片的无色模式
        let rightImg = UIImage.init(named: "进入")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let newImageNormal = rightImg?.imageWithTintColor(color: UIColor.black,blendMode: .overlay)
        let newImageHighlight = rightImg?.imageWithTintColor(color: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),blendMode: .overlay)
        newRightBtn.setImage(newImageNormal, for: UIControlState.normal)
        newRightBtn.setImage(newImageHighlight, for: UIControlState.highlighted)
        newRightBtn.setEnlargeEdge(20.0)
        newRightBtn.addTarget(self, action: #selector(openNewList), for: UIControlEvents.touchUpInside)
        topView.addSubview(newRightBtn)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        topView.addSubview(spearLine)
        
        let layout = UICollectionViewFlowLayout.init()
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        bottomCollectionView = UICollectionView(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: 95), collectionViewLayout: layout)
        bottomCollectionView.backgroundColor = UIColor.white
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        bottomCollectionView.tag = 2
        topView.addSubview(bottomCollectionView)
        
        bottomCollectionView.alwaysBounceHorizontal = true
        bottomCollectionView.showsHorizontalScrollIndicator = false
        
        bottomCollectionView.register(IndexTopCollectionViewCell().classForCoder, forCellWithReuseIdentifier: "topCollectionCell")
        initMJRefresh()
    }
    
    //初始化下拉刷新/上拉加载
    func initMJRefresh(){
        //下拉刷新相关设置
        refresHeader.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        // 现在的版本要用mj_header
        
        refresHeader.setTitle("下拉刷新", for: .idle)
        refresHeader.setTitle("释放更新", for: .pulling)
        refresHeader.setTitle("正在刷新...", for: .refreshing)
        self.allContentView.mj_header = refresHeader
        
    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
//        sleep(2)
        //重现生成数据
        getCurrentNew()
        self.getElectricControl()
        let openStatus = self.userDefault.object(forKey: "hasOpenAlarmList")
        if openStatus == nil || openStatus as! Bool == false{
            maxId = 0
        }else{
            maxId = self.userDefault.integer(forKey: "maxId")
        }
        getALarmCount()
        //结束刷新
        allContentView.mj_header.endRefreshing()
    }
    
    ///获取设备用电监控模块曲线图信息
    func getElectricControl(){
        MyProgressHUD.showStatusInfo("数据加载中...")
        let contentData : [String : Any] = ["method":"getEquipmentRunData","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            //            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.mainEchartsData = JSON(value)["data"]
                    //                    print(self.mainEchartsData)
                    self.drawPieChartView()
                    self.drawLineViewData(lineChartView:self.electricLineChartView, originX:1)
                    self.drawLineViewData(lineChartView:self.fuheLineChartView, originX:2)
                    //刷新页面数据
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    ///获取设备用电监控模块、本月新增模块信息
    func getCurrentNew(){
        MyProgressHUD.showStatusInfo("数据加载中...")
        let contentData : [String : Any] = ["method":"getEquipmentDetail","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            //            print(resultData)
            switch resultData.result {
            case .success(let value):
                if JSON(value)["status"].stringValue == "success"{
                    self.mainPointData = JSON(value)["data"]
                    //刷新页面数据
                    self.collectionView.reloadData()
                    self.bottomCollectionView.reloadData()
                    MyProgressHUD.dismiss()
                }else{
                    MyProgressHUD.dismiss()
                    if JSON(value)["msg"].string == nil {
                        self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                    }else{
                        self.present(windowAlert(msges: JSON(value)["msg"].stringValue), animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                MyProgressHUD.dismiss()
                self.present(windowAlert(msges: "数据请求失败"), animated: true, completion: nil)
                print("error:\(error)")
                return
            }
        }
    }
    
    @objc func openNewList() {
        let newListVc = NewDeviceListViewController()
        let newListNav = UINavigationController(rootViewController: newListVc)
        openChildVC(childNavName:newListNav)
    }
    
    //打开子页面
    func openChildVC(childNavName:UINavigationController) {
        self.hidesBottomBarWhenPushed = true
        self.present(childNavName, animated: true, completion: nil)
        self.hidesBottomBarWhenPushed = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func test2(lineChartView:LineChartView, originX:Int)
    {
        
        lineChartView.frame = CGRect(x: CGFloat(originX)*kScreenWidth + 20, y: 0, width: kScreenWidth - 40, height: self.scrollView.frame.height-10)
        scrollView.addSubview(lineChartView)
        let currentMonth = UILabel.init(frame: CGRect(x: kScreenWidth - 70, y: 0, width: 50, height: 24))
        currentMonth.text = "当月"
        currentMonth.textAlignment = .center
//        currentMonth.sizeToFit()
        currentMonth.backgroundColor = UIColor.pg_color(withHexString: "#EEEEEE")
        lineChartView.addSubview(currentMonth)
        lineChartView.delegate = self
        lineChartView.tag = 4000 + originX
        
        lineChartView.backgroundColor = UIColor.white//(red: 13/255.0, green: 21/255.0, blue: 40/255.0, alpha: 1)
        lineChartView.noDataText = "暂无数据"
        
        //设置交互样式
        lineChartView.scaleYEnabled = false //取消Y轴缩放
        lineChartView.doubleTapToZoomEnabled = true //双击缩放
        lineChartView.dragEnabled = true //启用拖动手势
        lineChartView.dragDecelerationEnabled = true //拖拽后是否有惯性效果
        lineChartView.dragDecelerationFrictionCoef = 0.9  //拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        lineChartView.extraTopOffset = 25 //正常规划的视图添加的距上边距
        
        //设置X轴样式
        let xAxis = lineChartView.xAxis
        xAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置X轴线宽
        xAxis.labelPosition = .bottom //X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = false;//绘制网格线
        xAxis.gridColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)//网格线颜色
        xAxis.spaceMin = 4;//设置label间隔
        xAxis.axisMinimum = 0
        xAxis.axisLineColor = UIColor(white: 1, alpha: 0.1605)
        xAxis.labelTextColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//label文字颜色
        
        //设置Y轴样式
        lineChartView.rightAxis.enabled = true  //绘制右边轴
        lineChartView.rightAxis.drawLabelsEnabled = false //不显示右边轴文本
        let leftAxis = lineChartView.leftAxis
        //leftAxis.labelCount = 10 //Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = false //不强制绘制指定数量的label
        leftAxis.axisMinimum = 0 //设置Y轴的最小值
        leftAxis.drawZeroLineEnabled = true //从0开始绘制
        //leftAxis.axisMaximum = 1000 //设置Y轴的最大值
        leftAxis.inverted = false //是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置Y轴线宽
        //        leftAxis.axisLineColor = UIColor(white: 1, alpha: 0.1605)//Y轴颜色
        //leftAxis.valueFormatter = NumberFormatter()//自定义格式
        //leftAxis.s  //数字后缀单位
        leftAxis.labelPosition = .outsideChart//label位置
        leftAxis.labelTextColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//文字颜色
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)//文字字体
        
        //设置y网格样式
        //        leftAxis.gridLineDashLengths = [3.0,3.0]  //设置虚线样式的网格线
        leftAxis.drawGridLinesEnabled = false
        leftAxis.gridColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1) //网格线颜色
        leftAxis.gridAntialiasEnabled = true //开启抗锯齿
        
        
        //添加限制线
        let litmitLine = ChartLimitLine(limit: 5, label: "限制线")
        litmitLine.lineWidth = 1
        litmitLine.lineColor = UIColor.red
        litmitLine.lineDashLengths = [5.0,5.0] //虚线样式
        litmitLine.labelPosition = .rightTop  // 限制线位置
        litmitLine.valueTextColor = UIColor.brown
        litmitLine.valueFont = UIFont.systemFont(ofSize: 12)
        leftAxis.drawLimitLinesBehindDataEnabled = true  //设置限制线绘制在折线图的后面
        //        leftAxis.addLimitLine(litmitLine)
        
        //设置折线图描述及图例样式
        lineChartView.chartDescription?.text = "(kWh)" //折线图描述
        lineChartView.chartDescription?.position = CGPoint(x: 32, y: 7)
        lineChartView.chartDescription?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)  //描述字体颜色
        lineChartView.chartDescription?.font = NSUIFont.systemFont(ofSize: 10.0)
        lineChartView.legend.enabled = false//设置是否显示legend
        //        lineChartView.legend.form = .line  // 图例的样式
        //        lineChartView.legend.formSize = 20  //图例中线条的长度
        //        lineChartView.legend.textColor = UIColor.darkGray
    }
    
    ///折线图加载数据
    func drawLineViewData(lineChartView:LineChartView, originX:Int){
        //设置折线图的数据
        var lineValues:JSON
        var originalColor:UIColor
        if originX == 1{
            lineValues = self.mainEchartsData["electricUseLine"]
            originalColor = UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1)
        }else{
            lineValues = self.mainEchartsData["powerDataLine"]
            originalColor = UIColor(red: 247/255, green: 122/255, blue: 4/255, alpha: 1)
        }
        
        var newxValues:[String] = []
        for xValue in lineValues.enumerated(){
            let newValue = lineValues[xValue.offset]["lineName"].stringValue.components(separatedBy: " ")[0].components(separatedBy: "-")[2] + "日"
            newxValues.append(newValue)
        }
        //        lineChartView.xAxis.valueFormatter = KMChartAxisValueFormatter.init(xValues as NSArray)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newxValues)
        //ineChartView.xAxis.labelCount = 12
        //lineChartView.leftAxis.valueFormatter = KMChartAxisValueFormatter.init()
        //        let leftValueFormatter = NumberFormatter()  //自定义格式
        //        leftValueFormatter.positiveSuffix = "亿"  //数字后缀单位
        //
        //        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: leftValueFormatter)
        
        //曲线1
        var yDataArray1 = [ChartDataEntry]()
        for i in 0...lineValues.count-1 {
            let y = lineValues[i]["lineData"].stringValue//arc4random()%100//暂时用100内的随机数填充数据
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y) ?? 0.00)
            
            yDataArray1.append(entry)
            if originX == 1{
                electricLineCircleColors.append(originalColor)
            }else{
                fuheLineCircleColors.append(originalColor)
            }
        }
        
        let set1 = LineChartDataSet.init(values: yDataArray1, label: "test1")
        set1.colors = [originalColor]
        set1.drawCirclesEnabled = true //是否绘制转折点
        //set1.setCircleColor(UIColor(red: 59/255, green: 169/255, blue: 255/255, alpha: 1))//转折点圆圈的颜色
        //为选中点变色做准备
        if originX == 1{
            set1.circleColors = electricLineCircleColors
        }else{
            set1.circleColors = fuheLineCircleColors
        }
        set1.circleHoleColor = UIColor.white //转折点内部的颜色
        set1.lineWidth = 1
        set1.circleRadius = 3.0//外圆半径
        set1.circleHoleRadius = 2.0//内圆半径
        set1.mode = .cubicBezier  //设置曲线是否平滑
        set1.drawValuesEnabled = false //设置是否显示折线上的数据
        //开启填充色绘制
        set1.drawFilledEnabled = true
        //渐变颜色数组
        let gradientColors = [originalColor.cgColor, UIColor.white.cgColor] as CFArray
        //每组颜色所在位置（范围0~1)
        let colorLocations:[CGFloat] = [1.0, 0.0]
        //生成渐变色
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: gradientColors, locations: colorLocations)
        //将渐变色作为填充对象s
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 100.0)
        
        /*//曲线2
         var yDataArray2 = [ChartDataEntry]();
         for i in 0...(xValues.count-1) {
         let y = arc4random()%100
         let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
         
         yDataArray2.append(entry);
         }
         let set2 = LineChartDataSet.init(values: yDataArray2, label: "test2")
         set2.colors = [UIColor(red: 247/255, green: 122/255, blue: 4/255, alpha: 1)]
         set2.drawCirclesEnabled = false
         set2.lineWidth = 1.0
         set2.mode = .cubicBezier  //设置曲线是否平滑
         set2.drawValuesEnabled = false //设置是否显示折线上的数据
         */
        set1.setDrawHighlightIndicators(false)
        lineChartView.drawMarkers = false
        let data = LineChartData.init(dataSets: [set1])//更改dataSets,决定曲线数量
        
        lineChartView.data = data
        //lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
        lineChartView.animate(xAxisDuration: 1)  //设置动画时间
        
        //图表最多显示10个点
        lineChartView.setVisibleXRangeMaximum(10)
        lineChartView.setScaleMinima(1, scaleY: 1)
        //默认显示最一个数据
        lineChartView.moveViewToX(0)
        lineChartView.notifyDataSetChanged()//根据数据变化等，重绘视图
    }
    
    //点选中时的标注
    func showMarkerView(operateView:ChartViewBase,value:String)
    {
        let marker = MarkerView.init(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        marker.chartView = operateView
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        label.text = value
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        marker.addSubview(label)
        operateView.marker = marker
    }
    
    //MARK - chartdelegate
    //因为转折点内圈颜色是一起设定的，所以无法更改内部颜色
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        chartView.drawMarkers = true
        self.showMarkerView(operateView:chartView, value: "\(entry.y)")
        //将选中的数据点的颜色改成黄色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        chartDataSet.setDrawHighlightIndicators(true)
        let values = chartDataSet.values
        let index = values.index(where: {$0.x == highlight.x})  //获取索引
        
        if chartView.tag == 4001 {
            chartDataSet.circleColors = electricLineCircleColors //还原
        }else{
            chartDataSet.circleColors = fuheLineCircleColors //还原
        }
        chartDataSet.circleColors[index!] = .orange
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    //折线上的点取消选中回调
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        //print("取消选中的数据")
        
        //还原所有点的颜色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        if chartView.tag == 4001 {
            chartDataSet.circleColors = electricLineCircleColors //还原
        }else{
            chartDataSet.circleColors = fuheLineCircleColors //还原
        }
        chartDataSet.setDrawHighlightIndicators(false)
        chartView.drawMarkers = false
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat){
        //还原所有点的颜色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        if chartView.tag == 4001 {
            chartDataSet.circleColors = electricLineCircleColors //还原
        }else{
            chartDataSet.circleColors = fuheLineCircleColors //还原
        }
        chartDataSet.setDrawHighlightIndicators(false)
        chartView.drawMarkers = false
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat){
        //还原所有点的颜色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        if chartView.tag == 4001 {
            chartDataSet.circleColors = electricLineCircleColors //还原
        }else{
            chartDataSet.circleColors = fuheLineCircleColors //还原
        }
        chartDataSet.setDrawHighlightIndicators(false)
        chartView.drawMarkers = false
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    
    func test3()
    {
        pieChartView.frame = CGRect(x: 5, y: 0, width: kScreenWidth - 10, height: self.scrollView.frame.height)
        scrollView.addSubview(pieChartView)
//        pieChartView.backgroundColor = UIColor.init(red: 230/255, green: 253/255.0, blue: 253/255.0, alpha: 1)
        pieChartView.setExtraOffsets(left: 10, top: 5, right: 10, bottom: 5)  //设置这块饼的位置
        
        //        pieChartView.chartDescription?.text = "饼状图示例" //描述文字
        //        pieChartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)
        //        pieChartView.chartDescription?.textColor = UIColor.black
        
        pieChartView.usePercentValuesEnabled = true  //是否根据所提供的数据, 将显示数据转换为百分比格式
        //pieChartView.dragDecelerationEnabled = false //把拖拽效果关了
        pieChartView.drawEntryLabelsEnabled = true //显示区块文本
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 10) //区块文本的字体
        pieChartView.entryLabelColor = UIColor.white
        pieChartView.drawSlicesUnderHoleEnabled = true//是否显示区块文本
        
        pieChartView.drawHoleEnabled = true  //这个饼是空心的
        pieChartView.holeRadiusPercent = 0.6  //空心半径黄金比例
        pieChartView.holeColor = UIColor.white //空心颜色设置为白色
        //        pieChartView.transparentCircleRadiusPercent = 0.75  //半透明空心半径
        
        //        pieChartView.drawCenterTextEnabled = true //显示中心文本
        //        pieChartView.centerText = "饼状图"  //设置中心文本,你也可以设置富文本`centerAttributedText`
        
        //图例样式设置
        pieChartView.legend.maxSizePercent = 1  //图例的占比
        pieChartView.legend.form = .circle //图示：原、方、线
        pieChartView.legend.formSize = 8 //图示大小
        pieChartView.legend.formToTextSpace = 10 //文本间隔
        pieChartView.legend.font = UIFont.systemFont(ofSize: 12)
        pieChartView.legend.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        pieChartView.legend.horizontalAlignment = .center
        pieChartView.legend.verticalAlignment = .bottom
        
        self.pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
    }
    
    func drawPieChartView()
    {
        var yVals = [PieChartDataEntry]()
        for pieItem in self.mainEchartsData["powerDataPie"].enumerated()
        {
            let entry = PieChartDataEntry.init(value: Double(self.mainEchartsData["powerDataPie"][pieItem.offset]["lineData"].intValue), label: self.mainEchartsData["powerDataPie"][pieItem.offset]["lineName"].stringValue)
            if Double(self.mainEchartsData["powerDataPie"][pieItem.offset]["lineData"].intValue) > 0 {
                yVals.append(entry)
            }
        }
        
        if yVals.count == 0 {
            pieChartView.data = nil
            pieChartView.data?.notifyDataChanged()
            pieChartView.notifyDataSetChanged()
            pieChartView.noDataText = "暂无数据，请重新刷新"
            return
        }
        
        let dataSet = PieChartDataSet.init(values: yVals, label:"")
        var colors:[UIColor] = []
        for pieItem in self.mainEchartsData["powerDataPie"].enumerated(){
            if Double(self.mainEchartsData["powerDataPie"][pieItem.offset]["lineData"].intValue) > 0 {
                if self.mainEchartsData["powerDataPie"][pieItem.offset]["lineName"].stringValue.hasPrefix("0"){
                    colors.append(UIColor(red: 255/255, green: 209/255, blue: 0/255, alpha: 1))
                }else if self.mainEchartsData["powerDataPie"][pieItem.offset]["lineName"].stringValue.hasPrefix("1"){
                    colors.append(UIColor(red: 113/255, green: 214/255, blue: 194/255, alpha: 1))
                }else{
                    colors.append(UIColor(red: 74/255, green: 179/255, blue: 238/255, alpha: 1))
                }
            }
        }
        dataSet.colors = colors
        //设置名称和数据的位置 都在内就没有折线了
        dataSet.xValuePosition = .outsideSlice  //标签显示在外
        dataSet.yValuePosition = .outsideSlice  //数值显示在外
        dataSet.sliceSpace = 1 //相邻块的距离
        dataSet.selectionShift = 6.66  //选中放大半径
        
        //指示折线样式
        dataSet.valueLinePart1OffsetPercentage = 0.85 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
        dataSet.valueLinePart1Length = 0.2 //折线中第一段长度占比
        dataSet.valueLinePart2Length = 0.6 //折线中第二段长度最大占比
        dataSet.valueLineWidth = 1//折线的粗细
        dataSet.valueLineColor = UIColor(red: 113/255, green: 214/255, blue: 194/255, alpha: 1) //折线颜色
        
        let data = PieChartData.init(dataSets: [dataSet])
        let formatter = ChartDataValueFormatter.init()
        data.setValueFormatter(formatter)//格式化值（添加个%）
        data.setValueFont(UIFont.systemFont(ofSize: 10.0))
        data.setValueTextColor(UIColor.black)
        pieChartView.data = data
        
        
        
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

extension IndexTabViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //MARK - uciollectionViewDataSource
    @available(iOS 6.0, *)
    public func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        switch collectionView.tag {
        case 1:
            return 3
        default:
            return 2
        }
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCollectionCell", for: indexPath) as? IndexTopCollectionViewCell
        
        //因为直接加到cell里面的视图，所以获取cell子视图再清除即可；
        //如果加到contentview里面则需cell?.contentView.subviews
        let prevAddedSubViews = cell?.subviews
        for eachPreAddedSubView in prevAddedSubViews! {
            eachPreAddedSubView.removeFromSuperview()
        }
        switch collectionView.tag {
        case 1:
            if indexPath.row == 0 {
                cell?.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "设备台数")
                cell?.value.text = self.mainPointData["equipmentCount"].stringValue
                cell?.label.text = "设备台数"
                cell?.unitLabel.text = "(台)"
                return cell!
            }else if indexPath.row == 1 {
                cell?.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "额定总功率")
                cell?.value.text = self.mainPointData["powerTotal"].stringValue
                cell?.unitLabel.text = "(kW)"
                cell?.label.text = "额定总功率"
                return cell!
            }else{
                cell?.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "实时功率")
                cell?.value.text = self.mainPointData["powerRealTotal"].stringValue
                cell?.unitLabel.text = "(kW)"
                cell?.label.text = "实时功率"
                return cell!
            }
            
        default:
            if indexPath.row == 0 {
                cell?.setup(textColors: [allFontColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor(red: 226/255, green: 242/255, blue: 255/255, alpha: 1), title: "新增台数")
                cell?.value.text = self.mainPointData["newAddCount"].stringValue
                cell?.unitLabel.text = "(台)"
                cell?.label.text = "新增台数"
            }else{
                cell?.setup(textColors: [allFontColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor(red: 213/255, green: 240/255, blue: 227/255, alpha: 1), title: "新增功率")
                cell?.value.text = self.mainPointData["newAddPower"].stringValue
                cell?.label.text = "新增功率"
                cell?.unitLabel.text = "(kW)"
            }
            return cell!
        }
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 1:
            return CGSize.init(width: (kScreenWidth-70)/3, height: 75)
        default:
            return CGSize.init(width: (kScreenWidth-60)/2, height: 75)
        }
        
        
    }
    //cell左右边距
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    //cell上下边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    //设置section的内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //{top, left, bottom, right};
        return UIEdgeInsetsMake(10, 25, 10, 25) // margin between sections
    }
    //设置sectionHeader的大小
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize.zero
    }
}

extension IndexTabViewController:UIScrollViewDelegate{
    //scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _ = scrollView.contentOffset.x / kScreenWidth
        //        pageControl!.currentPage = Int(offset)
    }
}

extension IndexTabViewController:LineButtonDelagate{
    //#MARK - LineButtonDelegate
    //实现按钮控制页面的切换
    func clickChangePage(_ lineButton:LineButton, buttonIndex:NSInteger){
//        print(buttonIndex)
        scrollView!.contentOffset = CGPoint(x:kScreenWidth * CGFloat(buttonIndex), y:0)
    }
}

extension UIImage{
    /// 更改图片颜色
    public func imageWithTintColor(color : UIColor, blendMode:CGBlendMode) -> UIImage{
        //        UIGraphicsBeginImageContext(self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        if blendMode != .destinationIn {
            
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
            
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}

extension UIButton {
    public func addMessage(operateBtn:UIButton,msg:String) ->UIBarButtonItem{
        let oldMsgView = operateBtn.viewWithTag(500)
        if oldMsgView != nil {
            oldMsgView?.removeFromSuperview()
        }
        
        let msgView:UIButton = UIButton.init(frame: CGRect(x: 12.5, y: 0, width: 15, height: 15))
        msgView.backgroundColor = UIColor.red
        msgView.layer.cornerRadius = 7.5
        msgView.layer.masksToBounds = true
        msgView.setTitle(msg, for: UIControlState.normal)
        msgView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        msgView.tintColor = UIColor.white
        msgView.tag = 500
        operateBtn.addSubview(msgView)
        
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(customView: operateBtn)
        return rightBarButtonItem
    }
    public func removeMessage(operateBtn:UIButton, msg:String) ->UIBarButtonItem{
        let msgView = operateBtn.viewWithTag(500)
        if msgView != nil {
            msgView?.removeFromSuperview()
        }
        
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(customView: operateBtn)
        return rightBarButtonItem
    }
}
