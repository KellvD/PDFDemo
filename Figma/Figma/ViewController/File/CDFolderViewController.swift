//
//  CDFolderViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/11.
//

import UIKit
import JXSegmentedView
class CDFolderViewController: CDBaseAllViewController,UITableViewDelegate, UITableViewDataSource {

    @objc dynamic private var dataArr: [[CDSafeFolder]] = []
    private var isNeedReloadData: Bool = false
    private var isInterPop = false

    private var tableblew: UITableView!
    private var addFolderBtn: UIButton = UIButton(type: .custom)
    private var backBtn: UIButton = UIButton(type: .custom)

    //move
    var isMovePicker: Bool = false
    var selectedArr:[CDSafeFileInfo] = []
    var moveHandler: ((Bool)->Void)?
    var originalFolderId: Int?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false

        if isNeedReloadData {
            isNeedReloadData = false
            refreshDBData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CDSignalTon.shared.vipType == .not && isInterPop {
            isInterPop = false

            self.startInterstitialAdsSdk()
        }
    }
    
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 112)
        navi.backgroundColor = .white
        
        navi.loadData(title: "File", subTitle: "Keep Important File Safe", image: "Add Folder") { [weak self] in
            guard let self = self else {
                return
            }
            self.onAddFolderAction()

        }
        
        return navi
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        view.backgroundColor = .white
        view.addSubview(self.navigation)
        
        var maxH = CDViewHeight
        if CDSignalTon.shared.vipType == .not {
            self.bannerView.rootViewController = self
            self.bannerView.frame = CGRect(x: 0, y: CDViewHeight - self.bannerView.height, width: CDSCREEN_WIDTH, height: self.bannerView.height)
            view.addSubview(self.bannerView)
            
            maxH = self.bannerView.minY
//            startBannerAdsSdk()
        }
        
        tableblew = UITableView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: maxH - self.navigation.maxY), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.backgroundColor = .white
        tableblew.separatorStyle = .none
        view.addSubview(tableblew)
        tableblew.register(CDFolderCell.self, forCellReuseIdentifier: "CDFolderCell")

        if isMovePicker {
            let cancelBtn = UIButton(type: .custom)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
            cancelBtn.setTitle("Cancel", for: .normal)
            cancelBtn.setTitleColor(.customBlack, for: .normal)
            cancelBtn.titleLabel?.font = UIFont.medium(17)
            cancelBtn.addTarget(self, action: #selector(onCancleMove), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addFolderBtn)
            navigationItem.title = "Move to"
            
        }

    }
    
    override func refreshVip() {
        self.bannerView.removeFromSuperview()
        tableblew.height = CDViewHeight - self.navigation.maxY
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "CDFolderCell"
        let cell: CDFolderCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CDFolderCell
        let info = dataArr[indexPath.section][indexPath.row]
        cell.loadData(info)
        cell.sperateLine.isHidden = indexPath.row == dataArr[indexPath.section].count - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isMovePicker {
            let info: CDSafeFolder = dataArr[indexPath.section][indexPath.row]
            onSaveDone(folder: info)
        } else {
            let info: CDSafeFolder = dataArr[indexPath.section][indexPath.row]
            tableblew.deselectRow(at: indexPath, animated: false)
    
            self.isNeedReloadData = true
            self.isInterPop = true
            let vcc = CDFilesViewController()
            vcc.folder = info
            vcc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vcc, animated: true)
//            CDSignalTon.shared.makeInterstitialAd { _ in}

        }

    }
    

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let fol = dataArr[indexPath.section][indexPath.row]
        let flag = fol.folderStatus == .Custom
        return flag
    }
 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let fol = dataArr[indexPath.section][indexPath.row]
        if fol.folderStatus != .Custom {
            return nil
        }
        let delete = UIContextualAction(style: .normal, title: "Delete") { _, _, hander in
            self.deleteBarItemClick(folder: fol, index: indexPath.row)
            hander(true)
        }
        delete.backgroundColor = UIColor(255, 59, 48)
        let action = UISwipeActionsConfiguration(actions: [delete])
        return action
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let radius = 12.0
        cell.backgroundColor = .clear
        let normalLayer = CAShapeLayer()
        let selectLayer = CAShapeLayer()
        let bounds = cell.bounds.insetBy(dx:16.0, dy:0)
        let rowNum = tableView.numberOfRows(inSection: indexPath.section)
        var bezierPath:UIBezierPath
        if(rowNum==1) {
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii:CGSize(width: radius, height: radius))
        }else{
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
        normalLayer.fillColor = UIColor(237, 244, 255).cgColor
        nomarBgView.layer.insertSublayer(normalLayer, at:0)
        nomarBgView.backgroundColor = .clear
        cell.backgroundView = nomarBgView

        let selectBgView = UIView(frame: bounds)
        selectLayer.fillColor = UIColor(213.0, 230.0, 244.0).cgColor
        selectBgView.layer.insertSublayer(selectLayer, at:0)
        cell.selectedBackgroundView = selectBgView

    }

    
    func refreshDBData() {

        if let originalFolderId = originalFolderId  {
            dataArr = CDSqlManager.shared.queryDefaultAllFileExitFolder(folderId: originalFolderId)
        } else {
            dataArr = CDSqlManager.shared.queryDefaultAllFileFolder()
        }
        tableblew.reloadData()
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }

    
    @objc func onAddFolderAction() {
        if CDSignalTon.shared.vipType == .not {
            self.present(self.vipVC, animated: true)
            return
        }
        
        addFollder(folderType: .File) { [weak self] folder in
            guard let self = self else {
                return
            }
            self.isNeedReloadData = true
            self.isInterPop = true

            let vcc = CDFilesViewController()
            vcc.folder = folder
            vcc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vcc, animated: true)
//            CDSignalTon.shared.makeInterstitialAd { _ in}

        }
    }
}

//Move
extension CDFolderViewController {
    @objc func onCancleMove() {
        guard let moveHandle = self.moveHandler else{
           return
        }
        self.dismiss(animated: true)
        moveHandle(false)
    }

    
    func onSaveDone(folder: CDSafeFolder) {
        CDHUDManager.shared.showWait()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            if folder.folderId > 0 && self.selectedArr.count > 0 {
                for index in 0..<self.selectedArr.count {
                    let file = self.selectedArr[index]
                    CDSignalTon.shared.moveFileToOtherFolder(file: file, moveFolder: folder)
                }
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete("Done!")
                    self.dismiss(animated: true)

                    if let moveHandle = self.moveHandler {
                        moveHandle(true)
                    }
                    
                }
            } else {
                DispatchQueue.main.async {
                    
                    CDHUDManager.shared.hideWait()
                    self.onCancleMove()
                }
            }
        }
        
    }
    
    @objc func deleteBarItemClick(folder: CDSafeFolder, index: Int) {
        
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            
            DispatchQueue.main.async {
                CDHUDManager.shared.showWait("")
            }
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else {
                    return
                }
                
                // 删除一级目录
                CDSqlManager.shared.updateOneSafeFolder(with: .delete, folderId: folder.folderId)
                CDSqlManager.shared.updateOneSafeFile(with: .delete, folderId: folder.folderId)
                
                DispatchQueue.main.async {
                    self.refreshDBData()
                    
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete("Done!")
                }
                
            }
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
}

extension CDFolderViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
