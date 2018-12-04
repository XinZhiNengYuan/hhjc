//
//  AlarmAnalysisViewController.swift
//  huanghuajichang
//
//  Created by zx on 2018/10/24.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Charts.Swift
import SwiftyJSON

class AlarmAnalysisViewController: UIViewController,ChartViewDelegate {
    
    var headerView : UIView!
    let buttons:NSMutableArray = ["当日", "当月", "当年"]
    // 把类定义成属性
    let tabButton = TabButton()
    // view
    var  buttonView:UIView!
    
    var contentView : UIView!
    
    var scrollView : UIScrollView!
    
    var barChartView = BarChartView()
    //报警详情ID
    var alarmDetailId:String!
    //从设备列表传值过来
    var alarmDetailInfo : JSON!
    
    let alarmAnalysisService = AlarmAnalysisViewService()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1).cgColor
        self.title = "报警分析"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "返回"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        requestForData()
    }
    
    func requestForData(){
        let userId = userDefault.string(forKey: "userId")
        let token = userDefault.string(forKey: "userToken")
        let contentData : [String : Any] = ["method":"getAlarmAnalysis","info":["objCode":alarmDetailId],"user_id":userId as Any,"token":token as Any]
        alarmAnalysisService.getData(contentData: contentData) { (successData) in
            self.setHeader()
            self.setContentView(successData: successData)
        }
    }
    //MARK:设置头部
    func setHeader(){
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: 100))
        headerView.layer.backgroundColor = UIColor(red: 166/255, green: 201/255, blue: 237/255, alpha: 1).cgColor
        let image = UIImageView(frame: CGRect(x: 15, y: 15, width: 20, height: 20))
        image.image = UIImage(named: "alarm")
        headerView.addSubview(image)
        let textLabel = UILabel(frame: CGRect(x: 45, y: 15, width: 200, height: 20))
        textLabel.textColor = UIColor.white
        textLabel.text = String.timeStampToString(timeStamp: self.alarmDetailInfo["alarmTime"].stringValue)
        headerView.addSubview(textLabel)
        let dec = UILabel(frame: CGRect(x: 20, y: 60, width: KUIScreenWidth-100, height: 20))
        dec.text = self.alarmDetailInfo["cimCode"].stringValue
        dec.textColor = UIColor.white
        headerView.addSubview(dec)
        let status = UILabel(frame: CGRect(x: KUIScreenWidth-100, y: 30, width: 80, height: 40))
        status.text = self.alarmDetailInfo["alarmTypeName"].stringValue
        status.textColor = UIColor.blue
        headerView.addSubview(status)
        view.addSubview(headerView)
    }
    
    //MARK:设置页面内容
    func setContentView(successData:AlarmAnalysisViewModule){
        contentView = UIView(frame: CGRect(x: 0, y: 110, width: KUIScreenWidth, height: KUIScreenHeight-100))
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
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: KUIScreenWidth, height: 1))
        spearLine.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        contentView.addSubview(spearLine)
        
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 41, width: KUIScreenWidth, height: contentView.frame.height-140))
        scrollView.contentSize = CGSize(width: KUIScreenWidth*3, height: scrollView.frame.height)
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
                setBarChart(i,successData: successData)
            }else if i==1 {
                setBarChart(i,successData: successData)
            }else{
                setBarChart(i,successData: successData)
            }
        }
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:设置柱状图
    func setBarChart(_ i:Int,successData:AlarmAnalysisViewModule){
        //添加barChartView
        
        if(i == 0){
            self.barChartView = BarChartView(frame: CGRect(x: 0, y: 0, width: KUIScreenWidth, height: scrollView.frame.height))
        }else if(i == 1){
            self.barChartView = BarChartView(frame: CGRect(x: KUIScreenWidth, y: 0, width: KUIScreenWidth, height: scrollView.frame.height))
        }else{
            self.barChartView = BarChartView(frame: CGRect(x: 2*KUIScreenWidth, y: 0, width: KUIScreenWidth, height: scrollView.frame.height))
        }
        self.barChartView.delegate = self //设置代理
        scrollView.addSubview(barChartView)
        
        //基本样式
        self.barChartView.backgroundColor = UIColor(red: 230/255, green: 253/255, blue: 253/255, alpha: 1)
        self.barChartView.noDataText = "暂无数据"//没有数据时的文字提示
        self.barChartView.drawValueAboveBarEnabled = true//数值显示在柱形的上面还是下面
//        self.barChartView.drawHighlightArrowEnabled = false;//点击柱形图是否显示箭头
        self.barChartView.drawBarShadowEnabled = false//是否绘制柱形的阴影背景
        
        //交互设置
        self.barChartView.scaleYEnabled = true//取消Y轴缩放
        self.barChartView.doubleTapToZoomEnabled = false//取消双击缩放
        self.barChartView.dragEnabled = true//启用拖拽图表
        self.barChartView.dragDecelerationEnabled = true//拖拽后是否有惯性效果
        self.barChartView.dragDecelerationFrictionCoef = 0.9//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        
        //X轴样式
        let xAxis = self.barChartView.xAxis
        xAxis.axisLineWidth = 1;//设置X轴线宽
        xAxis.labelPosition = .bottom  //X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = true   //不绘制网格线
//        xAxis.labelWidth = 4;//设置label间隔，若设置为1，则如果能全部显示，则每个柱形下面都会显示label
        xAxis.labelTextColor = UIColor(red: 176/255, green: 180/255, blue: 187/255, alpha: 1) //label文字颜色
        
        //右边Y轴样式
        self.barChartView.rightAxis.enabled = false;//不绘制右边轴
        
        //左边Y轴样式
        let leftAxis = self.barChartView.leftAxis//获取左边Y轴
        leftAxis.labelCount = 5 //Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = false //不强制绘制制定数量的label
//        leftAxis.showOnlyMinMaxEnabled = false //是否只显示最大值和最小值
        leftAxis.axisMinimum = 0;//设置Y轴的最小值
        leftAxis.drawZeroLineEnabled = true;//从0开始绘制
        leftAxis.axisMaximum = 4000;//设置Y轴的最大值
        leftAxis.inverted = false;//是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 0.5;//Y轴线宽
        leftAxis.axisLineColor = UIColor.gray;//Y轴颜色
        
        //设置Y轴上标签的样式
        leftAxis.labelPosition = .outsideChart   //label位置
        leftAxis.labelTextColor = UIColor.brown   //文字颜色
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)  //文字字体
        
        //设置Y轴上标签显示数字的格式
        let  leftFormatter = NumberFormatter()  //自定义格式
        leftFormatter.positiveSuffix = " $"  //数字后缀单位
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: leftFormatter)
        
        //设置Y轴上网格线的样式
//        leftAxis.gridLineDashLengths = [3.0, 3.0]   //设置虚线样式的网格线
        leftAxis.gridColor = UIColor.init(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)  //网格线颜色
        leftAxis.gridAntialiasEnabled = true   //开启抗锯齿
        
        //添加限制线
//        let limitLine = ChartLimitLine(limit: 3000, label: "限制线")
//        limitLine.lineWidth = 2
//        limitLine.lineColor = UIColor.green
//        limitLine.lineDashLengths = [5.0, 5.0]   //虚线样式
//        limitLine.labelPosition = .rightTop  //位置
//        leftAxis.addLimitLine(limitLine)  //添加到Y轴上
//        leftAxis.drawLimitLinesBehindDataEnabled = true  //设置限制线绘制在柱形图的后面
        
        //图例说明样式
        self.barChartView.legend.enabled = false  //不显示图例说明
        
        //右下角的description文字样式
        self.barChartView.chartDescription?.text = "" //不显示，就设为空字符串即可
        
        setData(i,successData: successData)
    }
    
    func setData(_ index : Int,successData:AlarmAnalysisViewModule)
    {
        var xVals = [String]()
        var yVals = [BarChartDataEntry]()
        
        switch index {
        case 0:
            for i in 0..<successData.dayData.count
            {
//                xVals.append(NSString(format: "%d年", "\(successData.dayData[i].lineName)") as String)
                xVals.append("\(successData.dayData[i].lineName)时")
                yVals.append(BarChartDataEntry.init(x: Double(i), y: Double(successData.dayData[i].lineData)!))
            }
        case 1:
            for i in 0..<successData.monthData.count
            {
//                xVals.append(NSString(format: "%d年", "\(successData.monthData[i].lineName)") as String)
                xVals.append("\(successData.monthData[i].lineName)日")
                yVals.append(BarChartDataEntry.init(x: Double(i), y: Double(successData.monthData[i].lineData)!))
            }
        case 2:
            for i in 0..<successData.yearData.count
            {
//                xVals.append(NSString(format: "%d年", "\(successData.yearData[i].lineName)") as String)
                xVals.append("\(successData.yearData[i].lineName)月")
                yVals.append(BarChartDataEntry.init(x: Double(i), y: Double(successData.yearData[i].lineData)!))
            }
        default:
            for i in 0..<10
            {
                xVals.append(NSString(format: "%d年", i+2010) as String)
            }
            for j in 0...10
            {
                let val = (Double)(arc4random_uniform(4000))
                
                yVals.append(BarChartDataEntry.init(x: Double(j), y: val))
            }
        }
        
        //chartView.xAxis.valueFormatter = KMChartAxisValueFormatter.init(xValues as NSArray)
        
        
        
       
        
        //创建BarChartDataSet对象，其中包含有Y轴数据信息，以及可以设置柱形样式
        let set1 = BarChartDataSet(values: yVals, label: "test")
        //set1.bar = 0.2  //柱形之间的间隙占整个柱形(柱形+间隙)的比例
        set1.drawValuesEnabled = true  //是否在柱形图上面显示数值
        set1.highlightEnabled = false  //点击选中柱形图是否有高亮效果，（双击空白处取消选中）
        set1.colors = ChartColorTemplates.material()
        
        
        //将BarChartDataSet对象放入数组中
        
        
        var dataSets = [BarChartDataSet]()
        
        
        dataSets.append(set1)
        
        //创建BarChartData对象, 此对象就是barChartView需要最终数据对象
        self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xVals)
        
        let data:BarChartData = BarChartData(dataSets: dataSets)
        data.setValueFont(UIFont.init(name: "HelveticaNeue-Light", size: 10))  //文字字体
        data.setValueTextColor(UIColor.orange)  //文字颜色
        data.barWidth = 0.7
        
        //自定义数据显示格式
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        //formatter.positiveFormat = " $"
        self.barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: formatter)
        
        
        self.barChartView.data = data
        self.barChartView.animate(xAxisDuration: 1)
        
    }
    //MARK - chartdelegate
    //点击选中柱形图时的代理方法
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    //没有选中柱形图时的代理方法
    func chartValueNothingSelected(_ chartView: ChartViewBase){
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //捏合放大或缩小柱形图时的代理方法
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    {
        
    }
    
    //拖拽图表时的代理方法
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)
    {
        
    }
}

extension AlarmAnalysisViewController:TabButtonDelagate{
    func clickChangePage(_ tabButton: TabButton, buttonIndex: NSInteger) {
        scrollView!.contentOffset = CGPoint(x:KUIScreenWidth * CGFloat(buttonIndex), y:0)
    }
}

extension AlarmAnalysisViewController:UIScrollViewDelegate{
    //scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _ = scrollView.contentOffset.x / kScreenWidth
        //        pageControl!.currentPage = Int(offset)
    }
}
