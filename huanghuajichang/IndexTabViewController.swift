//
//  IndexTabViewController.swift
//  huanghuajichang
//
//  Created by zx on 1976/4/1.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import Charts.Swift

class IndexTabViewController: BaseViewController,UINavigationControllerDelegate,ChartViewDelegate {
    
    var collectionView:UICollectionView!
    var bottomCollectionView:UICollectionView!
    
    let buttons:NSMutableArray = ["功率构成", "电量曲线", "负荷曲线"]
    // 把类定义成属性
    let linebutton = LineButton()
    // view
    var  buttonView:UIView!
    
    var scrollView:UIScrollView!
    
    let pieChartView = PieChartView()
    let lineChartView = LineChartView()
    
    var lineCircleColors:[UIColor]!=[]
    
    let topValueColor:UIColor = UIColor(red: 8/255, green: 128/255, blue: 237/255, alpha: 1)
    let allFontColor:UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    let allUnitColor:UIColor = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "智慧能源管理系统"
        self.navigationController?.title = "首页"
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "报警"), style: UIBarButtonItemStyle.done, target: self, action: #selector(openNewDetail))
        rightBarButtonItem.tintColor = UIColor.white//必须设置颜色，不然不出现～
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
//        self.navigationItem.rightBarButtonItem.set
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        // Do any additional setup after loading the view.
        deviceTotal()
        createMiddleTab()
        currentNew()
    }
    
    //设备汇总
    func deviceTotal() {
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH, height: 136))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        
        let topLabel:UILabel = UILabel.init(frame: CGRect(x: 15, y: 10, width: kSCREEN_WIDTH-30, height: 20))
        topLabel.text = "设备汇总"
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textColor = allFontColor
        topLabel.numberOfLines = 0
        topView.addSubview(topLabel)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kSCREEN_WIDTH, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        topView.addSubview(spearLine)
        
        let layout = UICollectionViewFlowLayout.init()
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 41, width: kSCREEN_WIDTH, height: 95), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.tag = 1
        collectionView.delegate = self
        collectionView.dataSource = self
        topView.addSubview(collectionView)
        
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(IndexTopCollectionViewCell().classForCoder, forCellWithReuseIdentifier: "topCollectionCell")
        collectionView.register(RealTimeReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    
    
    //功率，电量，负荷
    func createMiddleTab() {
        let middleView:UIView = UIView.init(frame: CGRect(x: 0, y: 146, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT-146*2-64 - 49))
        middleView.backgroundColor = UIColor.white
        self.view.addSubview(middleView)
        
        // 先删除
        if buttonView != nil{
            buttonView.removeFromSuperview()
            buttonView = nil
        }
        // 再创建
        buttonView = linebutton.creatLineButton(buttonsFrame:CGRect(x: 15, y: 10, width: kSCREEN_WIDTH-30, height: 30), dataArr: buttons)
        linebutton.delegate = self
        
        //buttonView.center = view.center
        middleView.addSubview(buttonView)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kSCREEN_WIDTH, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        middleView.addSubview(spearLine)
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 41, width: kSCREEN_WIDTH, height: middleView.frame.height-41))
        scrollView.contentSize = CGSize(width: kSCREEN_WIDTH*3, height: scrollView.frame.height)
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
//            let tmpView:UIView = UIView(frame: CGRect(x:kSCREEN_WIDTH * CGFloat(i), y:0, width:kSCREEN_WIDTH, height:scrollView.frame.height))
//            tmpView.backgroundColor = colors[i]
//            scrollView.addSubview(tmpView)
            if i == 0 {
                test3()
            }else{
                test2(originX: i)
            }
        }
        
    }
    
    func pageControlChanged(pageControl:UIPageControl) {
        let page = pageControl.currentPage
        
        print("当前显示的是第\(page+1)页")
        
    }
    
    //本月新增
    func currentNew() {
        let topHeight:CGFloat = kSCREEN_HEIGHT - 64 - 49 - 136
        let topView:UIView = UIView.init(frame: CGRect(x: 0, y: topHeight, width: kSCREEN_WIDTH, height: 136))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        
        let topLabel:UILabel = UILabel.init(frame: CGRect(x: 15, y: 10, width: kSCREEN_WIDTH-50, height: 20))
        topLabel.text = "本月新增"
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textColor = allFontColor
        topLabel.numberOfLines = 0
        topView.addSubview(topLabel)
        
        let newRightBtn:UIButton = UIButton.init(frame: CGRect(x: kSCREEN_WIDTH-35, y: 10, width: 20, height: 20))
        let rightImg = UIImage.init(named: "进入")
        let newImageNormal = rightImg?.imageWithTintColor(color: UIColor.black,blendMode: .overlay)
        let newImageHighlight = rightImg?.imageWithTintColor(color: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1),blendMode: .overlay)
        newRightBtn.setImage(newImageNormal, for: UIControlState.normal)
        newRightBtn.setImage(newImageHighlight, for: UIControlState.highlighted)
        newRightBtn.addTarget(self, action: #selector(openNewDetail), for: UIControlEvents.touchUpInside)
        topView.addSubview(newRightBtn)
        
        let spearLine:UIView = UIView.init(frame: CGRect(x: 0, y: 40, width: kSCREEN_WIDTH, height: 1))
        spearLine.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        topView.addSubview(spearLine)
        
        let layout = UICollectionViewFlowLayout.init()
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        bottomCollectionView = UICollectionView(frame: CGRect(x: 0, y: 41, width: kSCREEN_WIDTH, height: 95), collectionViewLayout: layout)
        bottomCollectionView.backgroundColor = UIColor.white
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        bottomCollectionView.tag = 2
        topView.addSubview(bottomCollectionView)
        
        bottomCollectionView.alwaysBounceHorizontal = true
        bottomCollectionView.showsHorizontalScrollIndicator = false
        
        bottomCollectionView.register(IndexTopCollectionViewCell().classForCoder, forCellWithReuseIdentifier: "topCollectionCell")
    }
    
    @objc func openNewDetail() {
        print("dsd")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func test2(originX:Int)
    {
        
        lineChartView.frame = CGRect(x: CGFloat(originX)*kSCREEN_WIDTH + 20, y: 0, width: kSCREEN_WIDTH - 40, height: self.scrollView.frame.height)
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
        
        //设置X轴样式
        let xAxis = lineChartView.xAxis
        xAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置X轴线宽
        xAxis.labelPosition = .bottom //X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = false;//不绘制网格线
        xAxis.spaceMin = 4;//设置label间隔
        xAxis.axisMinimum = 0
        xAxis.axisLineColor = UIColor(white: 1, alpha: 0.1605)
        xAxis.labelTextColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//label文字颜色
        
        //设置Y轴样式
        lineChartView.rightAxis.enabled = false  //不绘制右边轴
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelCount = 16 //Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = false //不强制绘制指定数量的label
        leftAxis.axisMinimum = 0 //设置Y轴的最小值
        leftAxis.drawZeroLineEnabled = true //从0开始绘制
        //leftAxis.axisMaximum = 1000 //设置Y轴的最大值
        leftAxis.inverted = false //是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置Y轴线宽
        leftAxis.axisLineColor = UIColor(white: 1, alpha: 0.1605)//Y轴颜色
        //leftAxis.valueFormatter = NumberFormatter()//自定义格式
        //leftAxis.s  //数字后缀单位
        leftAxis.labelPosition = .outsideChart//label位置
        leftAxis.labelTextColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)//文字颜色
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)//文字字体
        
        
        //设置网格样式
        leftAxis.gridLineDashLengths = [3.0,3.0]  //设置虚线样式的网格线
        leftAxis.gridColor = UIColor.init(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 0.1) //网格线颜色
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
        lineChartView.chartDescription?.text = "折线图" //折线图描述
        lineChartView.chartDescription?.textColor = UIColor.cyan  //描述字体颜色
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
        
        var yDataArray1 = [ChartDataEntry]()
        for i in 0...xValues.count-1 {
            let y = arc4random()%500
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            
            yDataArray1.append(entry)
            
            lineCircleColors.append(UIColor(red: 59/255, green: 169/255, blue: 255/255, alpha: 1))
        }
        
        
        let set1 = LineChartDataSet.init(values: yDataArray1, label: "test1")
        set1.colors = [UIColor(red: 59/255, green: 169/255, blue: 255/255, alpha: 1)]
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
        let gradientColors = [UIColor(red: 59/255, green: 169/255, blue: 255/255, alpha: 1).cgColor, UIColor.white.cgColor] as CFArray
        //每组颜色所在位置（范围0~1)
        let colorLocations:[CGFloat] = [1.0, 0.0]
        //生成渐变色
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: gradientColors, locations: colorLocations)
        //将渐变色作为填充对象s
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        
        var yDataArray2 = [ChartDataEntry]();
        for i in 0...(xValues.count-1) {
            let y = arc4random()%500+1
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            
            yDataArray2.append(entry);
        }
        let set2 = LineChartDataSet.init(values: yDataArray2, label: "test2")
        set2.colors = [UIColor.green]
        set2.drawCirclesEnabled = false
        set2.lineWidth = 1.0
        
        let data = LineChartData.init(dataSets: [set1])
        
        lineChartView.data = data
        //lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBack)
        lineChartView.animate(xAxisDuration: 1)  //设置动画时间
        
    }
    
    func showMarkerView(value:String)
    {
        let marker = MarkerView.init(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        marker.chartView = self.lineChartView
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        label.text = value
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        marker.addSubview(label)
        self.lineChartView.marker = marker
    }
    
    //MARK - chartdelegate
    //因为转折点内圈颜色是一起设定的，所以无法更改内部颜色
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        self.showMarkerView(value: "\(entry.y)")
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
        pieChartView.frame = CGRect(x: 20, y: 0, width: kSCREEN_WIDTH - 40, height: self.scrollView.frame.height)
        scrollView.addSubview(pieChartView)
//        pieChartView.backgroundColor = UIColor.init(red: 230/255, green: 253/255.0, blue: 253/255.0, alpha: 1)
        pieChartView.setExtraOffsets(left: 20, top: 10, right: 20, bottom: 10)  //设置这块饼的位置
        
//        pieChartView.chartDescription?.text = "饼状图示例" //描述文字
//        pieChartView.chartDescription?.font = UIFont.systemFont(ofSize: 12)
//        pieChartView.chartDescription?.textColor = UIColor.black
        
        pieChartView.usePercentValuesEnabled = true  //转化为百分比
        //pieChartView.dragDecelerationEnabled = false //把拖拽效果关了
        pieChartView.drawEntryLabelsEnabled = true //显示区块文本
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 10) //区块文本的字体
        pieChartView.entryLabelColor = UIColor.white
        pieChartView.drawSlicesUnderHoleEnabled = true
        
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
        
        let dataSet = PieChartDataSet.init(values: yVals, label:"test")
        dataSet.colors = [UIColor(red: 255/255, green: 209/255, blue: 0/255, alpha: 1),UIColor(red: 54/255, green: 204/255, blue: 107/255, alpha: 1),UIColor(red: 74/255, green: 179/255, blue: 238/255, alpha: 1)] //设置名称和数据的位置 都在内就没有折线了
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
        return 3
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCollectionCell", for: indexPath) as! IndexTopCollectionViewCell
        
        
        switch collectionView.tag {
        case 1:
            if indexPath.row == 0 {
                cell.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "设备台数")
                cell.value.text = "100000"
                cell.label.text = "设备台数"
                cell.unitLabel.text = "(台)"
                return cell
            }else if indexPath.row == 1 {
                cell.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "额定总功率")
                cell.value.text = "100000"
                cell.unitLabel.text = "(kW)"
                cell.label.text = "额定总功率"
                return cell
            }else{
                cell.setup(textColors: [topValueColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor.white, title: "设备台数")
                cell.value.text = "100000"
                cell.unitLabel.text = "(kW)"
                cell.label.text = "实时功率"
                return cell
            }
            
        default:
            if indexPath.row == 0 {
                cell.setup(textColors: [allFontColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor(red: 226/255, green: 242/255, blue: 255/255, alpha: 1), title: "新增台数")
                cell.value.text = "100000"
                cell.unitLabel.text = "(台)"
                cell.label.text = "新增台数"
            }else{
                cell.setup(textColors: [allFontColor, allFontColor, allUnitColor], cellBackGroundColor: UIColor(red: 213/255, green: 240/255, blue: 227/255, alpha: 1), title: "新增功率")
                cell.value.text = "100000"
                cell.label.text = "新增功率"
                cell.unitLabel.text = "(kW)"
            }
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        var reusableview:UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader
        {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! RealTimeReusableView
            
            (reusableview as! RealTimeReusableView).label.text = String(format: "第 %d 个页眉", arguments: [indexPath.section])
        }
        
        return reusableview
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 1:
            return CGSize.init(width: (kSCREEN_WIDTH-70)/3, height: 75)
        default:
            return CGSize.init(width: (kSCREEN_WIDTH-60)/2, height: 75)
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
        _ = scrollView.contentOffset.x / kSCREEN_WIDTH
        //        pageControl!.currentPage = Int(offset)
    }
}

extension IndexTabViewController:LineButtonDelagate{
    //#MARK - LineButtonDelegate
    //实现按钮控制页面的切换
    func clickChangePage(_ lineButton:LineButton, buttonIndex:NSInteger){
        print(buttonIndex)
        scrollView!.contentOffset = CGPoint(x:kSCREEN_WIDTH * CGFloat(buttonIndex), y:0)
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
//
//extension UIBarButtonItem {
//    public func addMessage(msg:String) ->UIBarButtonItem{
////        let newBarButton =
//    }
//}
