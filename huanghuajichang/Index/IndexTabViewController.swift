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

class IndexTabViewController: BaseViewController,UINavigationControllerDelegate,ChartViewDelegate {
    
    var collectionView:UICollectionView!
    var bottomCollectionView:UICollectionView!
    
    var userDefault = UserDefaults.standard
    var userToken:String!
    var userId:String!
    var mainPointData:JSON = []
    
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
    
    var lineCircleColors:[UIColor]!=[]
    
    var rightBarButtonItem:UIBarButtonItem?
    
    var rightBarButton:UIButton!
    
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
        
        rightBarButton.addTarget(self, action: #selector(getNewMsg(sender:)), for: UIControlEvents.touchUpInside)
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
    }
    
    @objc func getNewMsg(sender:UIButton){
        sender.removeTarget(self, action: #selector(getNewMsg(sender:)), for: UIControlEvents.allEvents)
        sender.addTarget(self, action: #selector(removeMsg(sender:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem = sender.addMessage(operateBtn:sender, msg: "95")
    }
    
    @objc func removeMsg(sender:UIButton){
        sender.removeTarget(self, action: #selector(removeMsg(sender:)), for: UIControlEvents.allEvents)
        sender.addTarget(self, action: #selector(getNewMsg(sender:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem = sender.removeMessage(operateBtn: sender, msg: "")
        
        let AlarmListVc = AlarmListViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(AlarmListVc, animated: true)
        self.hidesBottomBarWhenPushed = false
        
    }
    
    
    //设备汇总
    func deviceTotal() {
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 136))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        
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
        let middleView:UIView = UIView.init(frame: CGRect(x: 0, y: 146, width: kScreenWidth, height: kScreenHeight-146*2-64 - 49))
        middleView.backgroundColor = UIColor.white
        self.view.addSubview(middleView)
        
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
            }else if i==1 {
                test2(lineChartView:electricLineChartView, originX: i)
            }else{
                test2(lineChartView:fuheLineChartView, originX: i)
            }
        }
        
    }
    
    func pageControlChanged(pageControl:UIPageControl) {
        let page = pageControl.currentPage
        
        print("当前显示的是第\(page+1)页")
        
    }
    
    //本月新增
    func currentNew() {
        let topHeight:CGFloat = kScreenHeight - 64 - 49 - 136
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: topHeight, width: kScreenWidth, height: 136))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        
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
    }
    
    ///获取设备用电监控模块、本月新增模块信息
    func getCurrentNew(){
        print("执行更换头像操作")
        MyProgressHUD.showStatusInfo("数据加载中...")
        let contentData : [String : Any] = ["method":"getEquipmentDetail","info":"","token":userToken,"user_id":userId]
        NetworkTools.requestData(.post, URLString: "http", parameters: contentData) { (resultData) in
            print(resultData)
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
        
        lineChartView.frame = CGRect(x: CGFloat(originX)*kScreenWidth + 20, y: 0, width: kScreenWidth - 40, height: self.scrollView.frame.height)
        scrollView.addSubview(lineChartView)
        lineChartView.delegate = self
        
        lineChartView.backgroundColor = UIColor.white//(red: 13/255.0, green: 21/255.0, blue: 40/255.0, alpha: 1)
        lineChartView.noDataText = "暂无数据"
        
        //设置交互样式
        lineChartView.scaleYEnabled = false //取消Y轴缩放
        lineChartView.doubleTapToZoomEnabled = true //双击缩放
        lineChartView.dragEnabled = true //启用拖动手势
        lineChartView.dragDecelerationEnabled = true //拖拽后是否有惯性效果
        lineChartView.dragDecelerationFrictionCoef = 0.9  //拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        lineChartView.extraTopOffset = 15 //正常规划的视图添加的距上边距
        
        //设置X轴样式
        let xAxis = lineChartView.xAxis
        xAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置X轴线宽
        xAxis.labelPosition = .bottom //X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = true;//绘制网格线
        xAxis.gridColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)//网格线颜色
        xAxis.spaceMin = 4;//设置label间隔
        xAxis.axisMinimum = 0
        xAxis.axisLineColor = UIColor(white: 1, alpha: 0.1605)
        xAxis.labelTextColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//label文字颜色
        
        //设置Y轴样式
        lineChartView.rightAxis.enabled = true  //绘制右边轴
        lineChartView.rightAxis.drawLabelsEnabled = false //不显示右边轴文本
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelCount = 16 //Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
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
        leftAxis.gridColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1) //网格线颜色
        leftAxis.gridAntialiasEnabled = true //开启抗锯齿
        
        
        //添加限制线
        let litmitLine = ChartLimitLine(limit: 260, label: "限制线")
        litmitLine.lineWidth = 2
        litmitLine.lineColor = UIColor.green
        litmitLine.lineDashLengths = [5.0,5.0] //虚线样式
        litmitLine.labelPosition = .rightTop  // 限制线位置
        litmitLine.valueTextColor = UIColor.brown
        litmitLine.valueFont = UIFont.systemFont(ofSize: 12)
        leftAxis.addLimitLine(litmitLine)
        leftAxis.drawLimitLinesBehindDataEnabled = true  //设置限制线绘制在折线图的后面
        
        //设置折线图描述及图例样式
        lineChartView.chartDescription?.text = "(kWh)" //折线图描述
        lineChartView.chartDescription?.position = CGPoint(x: 32, y: 7)
        lineChartView.chartDescription?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)  //描述字体颜色
        lineChartView.chartDescription?.font = NSUIFont.systemFont(ofSize: 10.0)
        lineChartView.legend.form = .line  // 图例的样式
        lineChartView.legend.formSize = 20  //图例中线条的长度
        lineChartView.legend.textColor = UIColor.darkGray
        
        
        //设置折线图的数据
        let xValues = ["x1","x2","x3","x4","x5","x6","x7","x8","x9","x10","x11","x12","x13","x14","x15","x16","x17","x18","x19","x20","x21","x22","x23","x24","x25","x26"]
        var newxValues:[String] = []
        for xValue in xValues{
            let newValue = xValue.components(separatedBy: "x")[1].appending("日")
            newxValues.append(newValue)
        }
        //        lineChartView.xAxis.valueFormatter = KMChartAxisValueFormatter.init(xValues as NSArray)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newxValues)
        //ineChartView.xAxis.labelCount = 12
        //lineChartView.leftAxis.valueFormatter = KMChartAxisValueFormatter.init()
        let leftValueFormatter = NumberFormatter()  //自定义格式
        leftValueFormatter.positiveSuffix = "亿"  //数字后缀单位
        
        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: leftValueFormatter)
        
        //曲线1
        var yDataArray1 = [ChartDataEntry]()
        for i in 0...xValues.count-1 {
            let y = arc4random()%100//暂时用100内的随机数填充数据
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            
            yDataArray1.append(entry)
            
            lineCircleColors.append(UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1))
        }
        
        let set1 = LineChartDataSet.init(values: yDataArray1, label: "test1")
        set1.colors = [UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1)]
        set1.drawCirclesEnabled = true //是否绘制转折点
        //set1.setCircleColor(UIColor(red: 59/255, green: 169/255, blue: 255/255, alpha: 1))//转折点圆圈的颜色
        set1.circleColors = lineCircleColors//为选中点变色做准备
        set1.circleHoleColor = UIColor.white //转折点内部的颜色
        set1.lineWidth = 1
        set1.circleRadius = 5//外圆半径
        set1.circleHoleRadius = 4//内圆半径
        set1.mode = .cubicBezier  //设置曲线是否平滑
        set1.drawValuesEnabled = false //设置是否显示折线上的数据        
        //开启填充色绘制
        set1.drawFilledEnabled = true
        //渐变颜色数组
        let gradientColors = [UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1).cgColor, UIColor.white.cgColor] as CFArray
        //每组颜色所在位置（范围0~1)
        let colorLocations:[CGFloat] = [1.0, 0.0]
        //生成渐变色
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: gradientColors, locations: colorLocations)
        //将渐变色作为填充对象s
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        
        //曲线2
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
        
        let data = LineChartData.init(dataSets: [set1, set2])//更改dataSets,决定曲线数量
        
        lineChartView.data = data
        //lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
        lineChartView.animate(xAxisDuration: 1)  //设置动画时间
        
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
        self.showMarkerView(operateView:chartView, value: "\(entry.y)")
        //将选中的数据点的颜色改成黄色
        var chartDataSet = LineChartDataSet()
        chartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let values = chartDataSet.values
        let index = values.index(where: {$0.x == highlight.x})  //获取索引
        chartDataSet.circleColors = lineCircleColors //还原
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
        chartDataSet.circleColors = lineCircleColors
        
        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    
    func test3()
    {
        pieChartView.frame = CGRect(x: 20, y: 0, width: kScreenWidth - 40, height: self.scrollView.frame.height)
        scrollView.addSubview(pieChartView)
//        pieChartView.backgroundColor = UIColor.init(red: 230/255, green: 253/255.0, blue: 253/255.0, alpha: 1)
        pieChartView.setExtraOffsets(left: 20, top: 10, right: 20, bottom: 10)  //设置这块饼的位置
        
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
        
        self.drawPieChartView()
        
    }
    
    func drawPieChartView()
    {
        let titles = ["0-1kW","1-5kW","5kW以上"]
        let yData = [40,30,30]
        var yVals = [PieChartDataEntry]()
        
        for i in 0...titles.count - 1
        {
            let entry = PieChartDataEntry.init(value: Double(yData[i]), label: titles[i])
            yVals.append(entry)
        }
        
        let dataSet = PieChartDataSet.init(values: yVals, label:"")
        dataSet.colors = [UIColor(red: 255/255, green: 209/255, blue: 0/255, alpha: 1),UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1),UIColor(red: 74/255, green: 179/255, blue: 238/255, alpha: 1)]
        //设置名称和数据的位置 都在内就没有折线了
        dataSet.xValuePosition = .insideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.sliceSpace = 1 //相邻块的距离
        dataSet.selectionShift = 6.66  //选中放大半径
        
        //指示折线样式
        dataSet.valueLinePart1OffsetPercentage = 1.2 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
        dataSet.valueLinePart1Length = 0.6 //折线中第一段长度占比
        dataSet.valueLinePart2Length = 1.8 //折线中第二段长度最大占比
        dataSet.valueLineWidth = 1.2 //折线的粗细
        dataSet.valueLineColor = UIColor(red: 113/255, green: 214/255, blue: 194/255, alpha: 1) //折线颜色
        
        let data = PieChartData.init(dataSets: [dataSet])
        //data.setValueFormatter(KMChartAxisValueFormatter.init()) //格式化值（添加个%）
        data.setValueFont(UIFont.systemFont(ofSize: 10.0))
        data.setValueTextColor(UIColor.lightGray)
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
        print(buttonIndex)
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
        
        let msgView:UIButton = UIButton.init(frame: CGRect(x: 12.5, y: 0, width: 15, height: 15))
        msgView.backgroundColor = UIColor.red
        msgView.layer.cornerRadius = 5
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
        msgView?.removeFromSuperview()
        
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(customView: operateBtn)
        return rightBarButtonItem
    }
}
