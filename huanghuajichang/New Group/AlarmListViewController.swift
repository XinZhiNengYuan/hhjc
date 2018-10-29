//
//  AlarmListViewController.swift
//  huanghuajichang
//
//  Created by 新奥数能 on 2018/10/26.
//  Copyright © 2018年 EnnergySuperHero. All rights reserved.
//

import UIKit
import MJRefresh

class AlarmListViewController: AddNavViewController {
    
    var leftSelect:UIButton!
    var rightSelect:UIButton!
    var alarmTableList:UITableView!
    // 顶部刷新
    let refresHeader = MJRefreshNormalHeader()
    // 底部刷新
    let refreshFooter = MJRefreshBackNormalFooter()
    
    var selectorView:UIView!
    var selector:UIPickerView!
    var clickedBtnTag:Int!
    
    var selectorData:NSMutableArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "报警列表"
        self.view.backgroundColor = allListBackColor
        // Do any additional setup after loading the view.
        createUI()
    }
    
    func createUI(){
        leftSelect = UIButton.init(frame: CGRect(x: 0, y: 0, width: (kScreenWidth-1)/2, height: 40))
        leftSelect.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        leftSelect.set(image: UIImage(named: "下拉"), title: "设备单位", titlePosition: UIViewContentMode.left, additionalSpacing: 2, state: UIControlState.normal)
        leftSelect.tag = 3001
        leftSelect.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(leftSelect)
        
        rightSelect = UIButton.init(frame: CGRect(x: (kScreenWidth-1)/2+1, y: 0, width: (kScreenWidth-1)/2, height: 40))
        rightSelect.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: UIControlState.normal)
        rightSelect.set(image: UIImage(named: "下拉"), title: "报警类型", titlePosition: UIViewContentMode.left, additionalSpacing: 2, state: UIControlState.normal)
        rightSelect.tag = 3002
        rightSelect.addTarget(self, action: #selector(customSelector(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(rightSelect)
        
        ///列表
        alarmTableList = UITableView.init(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: kScreenHeight-64-40))
        alarmTableList.backgroundColor = allListBackColor
        alarmTableList.delegate = self
        alarmTableList.dataSource = self
        alarmTableList.separatorStyle = .none
        self.view.addSubview(alarmTableList)
        alarmTableList.register(AlarmListTableViewCell.self, forCellReuseIdentifier: "alarmCell")
        
        initMJRefresh()
        
        ///选择弹出框
        selectorView = UIView.init(frame:CGRect(x: 0, y: kScreenHeight-64-240, width: kScreenWidth, height: 240))
        selectorView.isHidden = true
        self.view.addSubview(selectorView)
        
        let selectorToolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        selectorToolBar.backgroundColor = UIColor.white
        let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        selectorToolBar.setItems([cancelBtn,flexSpace, doneBtn], animated: false)
        selectorToolBar.sizeToFit()
        selectorView.addSubview(selectorToolBar)
        
        selector = UIPickerView.init(frame:CGRect(x: 0, y: 40, width: kScreenWidth, height: 200))
        selector.delegate = self
        selector.dataSource = self
        selector.backgroundColor = UIColor.white
        selectorView.addSubview(selector)
    }
    
    //初始化下拉刷新/上拉加载
    func initMJRefresh(){
        //下拉刷新相关设置
        refresHeader.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.headerRefresh))
        // 现在的版本要用mj_header
        
        refresHeader.setTitle("下拉刷新", for: .idle)
        refresHeader.setTitle("释放更新", for: .pulling)
        refresHeader.setTitle("正在刷新...", for: .refreshing)
        self.alarmTableList.mj_header = refresHeader
        //初始化上拉加载
        init_bottomFooter()
    }
    
    //上拉加载初始化设置
    func init_bottomFooter(){
        //上刷新相关设置
        refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(DailyRecordViewController.footerRefresh))
        //self.bottom_footer.stateLabel.isHidden = true // 隐藏文字
        //是否自动加载（默认为true，即表格滑到底部就自动加载,这个我建议关掉,要不然效果会不好）
//        refreshFooter.isAutomaticallyRefresh = false
        refreshFooter.isAutomaticallyChangeAlpha = true //自动更改透明度
        //修改文字
        refreshFooter.setTitle("上拉上拉上拉", for: .idle)//普通闲置的状态
        //        refreshFooter.setTitle("释放更新", for: .pulling)
        refreshFooter.setTitle("加载加载加载", for: .refreshing)//正在刷新的状态
        refreshFooter.setTitle("没有没有更多数据了", for: .noMoreData)//数据加载完毕的状态
        //将上拉加载的控件与 tableView控件绑定起来
        self.alarmTableList.mj_footer = refreshFooter
    }
    
    // 顶部刷新
    @objc func headerRefresh(){
        
        print("下拉刷新")
        //服务器请求数据的函数
        //        self.getTableViewData()
        //重新加载tableView数据
        //self.my_tableview.reloadData()
        //结束下拉刷新
        self.alarmTableList.mj_header.endRefreshing()
    }
    
    // 底部刷新
    @objc func footerRefresh(){
        
        print("上拉刷新")
        //结束下拉刷新
        self.alarmTableList.mj_footer.endRefreshing()
    }
    
    @objc func customSelector(sender:UIButton){
        clickedBtnTag = sender.tag
        switch clickedBtnTag {
        case 3001:
            selectorData = [12,13,14,15,16,17]
        default:
            selectorData = [22,23,24,25,26,27]
        }
        
        selector.reloadAllComponents()
        selectorView.isHidden = false
        
    }
    @objc func cancelButtonAction(){
        selectorView.isHidden = true
    }
    
    @objc func doneButtonAction(){
        let selectBtn = self.view.viewWithTag(clickedBtnTag) as! UIButton
        let selectIndex = selector.selectedRow(inComponent: 0)
        let selectText = "\(selectorData[selectIndex])"
        selectBtn.setTitle(selectText, for: UIControlState.normal)
        
        selectorView.isHidden = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func backItemPressed () {
        self.navigationController?.popViewController(animated: false)
    }

}

extension AlarmListViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    //MARK - dataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    //MARk - delegate
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        <#code#>
//    }
//
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        <#code#>
//    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectorData == []{
            return nil
        }else {
            return (selectorData?[row] as! Int).description
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        <#code#>
//    }
    
}

extension AlarmListViewController:UITableViewDelegate, UITableViewDataSource{
    //MARK - dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var alarmListCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell") as? AlarmListTableViewCell
        if alarmListCell == nil {
            alarmListCell = AlarmListTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "alarmCell")
        }
        alarmListCell?.itemTitle.text = "节能器吸热能力明显下降"
        alarmListCell?.itemStatus.text = "一般告警"
        alarmListCell?.itemName.text = "安兴彩纤光伏站"
        alarmListCell?.itemTime.text = "2018-06-05 12:09:45"
        alarmListCell?.changUI(realTitle:(alarmListCell?.itemTitle.text)!,realStatus:(alarmListCell?.itemStatus.text)!)
        return alarmListCell!
    }
    
    //MARK - delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarmAnalysisVc = AlarmAnalysisViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(alarmAnalysisVc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

///带图标，文字的按钮
extension UIButton {
    @objc func set(image anImage: UIImage?, title: String, titlePosition: UIViewContentMode, additionalSpacing: CGFloat, state: UIControlState){
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)
        positionLabelRespectToImage(title:title, position: titlePosition, spacing: additionalSpacing);
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
        
    }
    private func positionLabelRespectToImage(title: String, position: UIViewContentMode, spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedStringKey.font: titleFont!])
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),                left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
                titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),                left: -(imageSize.width), bottom: 0, right: 0)
                imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        }
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
        
    }
}
