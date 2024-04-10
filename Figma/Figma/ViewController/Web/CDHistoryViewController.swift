//
//  CDHistoryTableViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/15.
//

import UIKit

class CDHistoryViewController: CDBaseAllViewController,UITableViewDelegate, UITableViewDataSource {
    private var isNeedReloadData: Bool = false
    private var tableblew: UITableView!
    private var dataArr: [CDWebPageInfo] = []
    private var searchDefaaultArr: [CDWebPageInfo] = []
    private var rightItemBtn = UIButton(type: .custom)
    var naItem: UINavigationItem!
    var backBlock: (() -> Void)?
    private var searchText: String?

    
    lazy var closeTab: CDToolBar = {
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: [.done]) { [weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .done:
                self.doneItemClick()
            default:
                break
            }
        }
        view.addSubview(toolbar)
        
        guard let doneItem = toolbar.viewWithTag(CDToolBar.CDToolsType.done.rawValue) as? UIButton else {
           return toolbar
        }
        doneItem.maxX = CDSCREEN_WIDTH - 20
        
        return toolbar
    }()
    
    lazy var searchBar: CDCustomSearchBar = {
        let searchBar = CDCustomSearchBar(frame: CGRect(x: CDSCREEN_WIDTH, y: StatusHeight, width: CDSCREEN_WIDTH, height: 40))
        UIDevice.keyWindow().addSubview(searchBar)
        searchBar.actionBlock = {[weak self] text in
            guard let self = self else {
                return
            }
            self.searchRefreshData(text)
        }
        return searchBar
    }()
    
    lazy var coveryView: CDCoveryView = {
        let vv = CDCoveryView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        view.addSubview(vv)
        view.bringSubviewToFront(vv)
        vv.dismissHandler = { [weak self] in
            guard let self = self else {
                return
            }
            self.searchBar.finishSearch()
            self.searchRefreshData(nil)
           
        }
        return vv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.hidesBottomBarWhenPushed = true
        naItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        refreshDBData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var maxH = CDViewHeight
        if CDSignalTon.shared.vipType == .not {
            self.bannerView.rootViewController = self
            self.bannerView.frame = CGRect(x: 0, y: CDViewHeight - self.bannerView.height, width: CDSCREEN_WIDTH, height: self.bannerView.height)
            view.addSubview(self.bannerView)
            
            maxH = self.bannerView.minY
//            startBannerAdsSdk()
        }
        
        tableblew = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: self.closeTab.minY - maxH), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        tableblew.backgroundColor = .white
        view.addSubview(tableblew)
        tableblew.register(UINib(nibName: "WebHistoryHeader", bundle: nil), forCellReuseIdentifier: "WebHistoryHeader")
        tableblew.register(WebHistoryCell.self, forCellReuseIdentifier: "WebHistoryCell")

        rightItemBtn.contentHorizontalAlignment = .right
        self.rightItemBtn.setImage("search-normal".image, for: .normal)
        self.rightItemBtn.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        refreshDBData()
    }
    
    override func refreshVip() {
        self.bannerView.removeFromSuperview()
        tableblew.height = self.closeTab.minY
    }
    
    func refreshDBData() {
        dataArr = CDSqlManager.shared.queryAllWebPage(type: .history)
        searchDefaaultArr = dataArr
        tableblew.reloadData()
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 44 : 62

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : dataArr.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let cell: WebHistoryHeader! = tableView.dequeueReusableCell(withIdentifier: "WebHistoryHeader", for: indexPath) as? WebHistoryHeader
            cell.selectionStyle = .none
            return cell
        } else {
            let cell: WebHistoryCell! = tableView.dequeueReusableCell(withIdentifier: "WebHistoryCell", for: indexPath) as? WebHistoryCell
            let tmpFile = dataArr[indexPath.row]
            cell.loadData(file: tmpFile, searchText: searchText)
            cell.lineView.isHidden = indexPath.row == dataArr.count - 1

            return cell
        }
    }
    
    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            return nil
        }
        let tmpFile = dataArr[indexPath.row]
        //
        let delete = UIContextualAction(style: .normal, title: "Delete") {[weak self] (_, _, _) in
            guard let self = self else {
                return
            }
            CDSqlManager.shared.deleteOneWebage(webId: tmpFile.webId)
            self.dataArr.remove(at: indexPath.row)
            self.tableblew.reloadData()
        }
        delete.backgroundColor = UIColor(255, 59, 48)
        let action = UISwipeActionsConfiguration(actions: [delete])
        return action
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        let radius = 12.0
        cell.backgroundColor = .clear
        let normalLayer = CAShapeLayer()
        let selectLayer = CAShapeLayer()
        let bounds = cell.bounds.insetBy(dx:16.0, dy:0)
        let rowNum = tableView.numberOfRows(inSection: indexPath.section)
        var bezierPath:UIBezierPath
        if(rowNum==1) {
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii:CGSize(width: radius, height: radius))
        } else {
            if(indexPath.row==0) {
                bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:[UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii:CGSize(width: radius, height: radius))
            }else if(indexPath.row==rowNum-1) {
                bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [UIRectCorner.bottomLeft,UIRectCorner.bottomRight], cornerRadii:CGSize(width: radius, height: radius))
            }else{
                bezierPath = UIBezierPath(rect: bounds)
            }
        }
        normalLayer.path = bezierPath.cgPath
        selectLayer.path = bezierPath.cgPath
        let nomarBgView = UIView(frame: bounds)
        normalLayer.fillColor = UIColor(243, 243, 243).cgColor
        nomarBgView.layer.insertSublayer(normalLayer, at:0)
        nomarBgView.backgroundColor = .clear
        cell.backgroundView = nomarBgView
        
        let selectBgView = UIView(frame: bounds)
        selectLayer.fillColor = UIColor.lightGray.cgColor
        selectBgView.layer.insertSublayer(selectLayer, at:0)
        cell.selectedBackgroundView = selectBgView

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
         let vc = CDWebPageViewController()
        vc.file = dataArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func searchRefreshData(_ text: String?) {
        self.coveryView.dismiss()

        guard let text = text else {
            UIView.animate(withDuration: 0.05) {
                self.searchBar.minX = CDSCREEN_WIDTH
            }
            searchText = nil
            dataArr = searchDefaaultArr
            tableblew.reloadData()
            return
        }
        if text.isEmpty {
            searchText = nil
            dataArr = searchDefaaultArr
            tableblew.reloadData()
        }else {
            searchText = text
            let arr = searchDefaaultArr.filter { file in
                file.webUrl.contains(text)
            }
            dataArr = arr
            tableblew.reloadData()
        }
    }
    
    //MARK:
    @objc func rightItemClick(sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            self.searchBar.minX = 0
            self.coveryView.pop()
        }
        self.searchBar.searchFiles.becomeFirstResponder()
        
    }
    
    func doneItemClick() {
        guard let backBlock = backBlock else {
            return
        }
        backBlock()
    }
}


