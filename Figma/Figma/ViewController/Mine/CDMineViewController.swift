//
//  CDMineViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/10.
//

import UIKit

import MessageUI
class CDMineViewController: CDBaseAllViewController,UITableViewDelegate, UITableViewDataSource {
    
    private var tableblew: UITableView!

    let optionArr = ["Restore Purchase","Share Our App","Rate Us","Terms of Use","Privacy Policy"]
    let iconArr = ["复费","分享","评分","规则","隐私"]
    let appStoreUrl = "itms-apps://itunes.apple.com/app/id6476800308"
    var isInterPop = false
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false
        tableblew.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 112)
        navi.loadData(title: "Settings", subTitle:"", image: "") { }

        return navi
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.navigation)
        view.backgroundColor = .white
        tableblew = UITableView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: CDViewHeight - self.navigation.maxY), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        tableblew.backgroundColor = .baseBgColor
        view.addSubview(tableblew)

        tableblew.register(UINib(nibName: "CDMineHeaderCell", bundle: nil), forCellReuseIdentifier: "CDMineHeaderCell")
        tableblew.register(CDFolderCell.self, forCellReuseIdentifier: "CDFolderCell")
        // Do any additional setup after loading the view.
       
        let backBtn = UIButton(type: .custom)
        backBtn.width = 150
        backBtn.setImage("back".image, for: .normal)
        backBtn.contentHorizontalAlignment = .left
        backBtn.setTitleColor(.customBlack, for: .normal)
        backBtn.titleLabel?.font = .medium(18)
        backBtn.setTitle("Setttings", for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        16
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 367 : 64
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : optionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell: CDMineHeaderCell! = tableView.dequeueReusableCell(withIdentifier: "CDMineHeaderCell", for: indexPath) as? CDMineHeaderCell
            cell.actionHandler = { [weak self] type in
                guard let self = self else {
                    return
                }
                switch type {
                case .faceid:
                    self.setFaceIdClick()
                case  .passcode:
                    self.setPasswordClick()
                case  .upgrade:
                    self.present(self.vipVC, animated: true)
                }
            }
            cell.updateSwitch()
            return cell
        } else {
            let cell: CDFolderCell! = tableView.dequeueReusableCell(withIdentifier: "CDFolderCell", for: indexPath) as? CDFolderCell
            cell.titleLabel.text = optionArr[indexPath.row]
            cell.iconView.image = iconArr[indexPath.row].image
            cell.sperateLine.isHidden = indexPath.row == optionArr.count - 1
            return cell
        }
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
        normalLayer.fillColor = UIColor.white.cgColor
        nomarBgView.layer.insertSublayer(normalLayer, at:0)
        nomarBgView.backgroundColor = .clear
        cell.backgroundView = nomarBgView
        
        let selectBgView = UIView(frame: bounds)
        selectLayer.fillColor = UIColor.lightGray.cgColor
        selectBgView.layer.insertSublayer(selectLayer, at:0)
        cell.selectedBackgroundView = selectBgView

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableblew.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let title = optionArr[indexPath.row]

            if title == "Restore Purchase" {
                if CDSignalTon.shared.vipType == .vip {
                    CDHUDManager.shared.showText("Your all features has been unlock!")
                    return
                }
                NKIAPManager.viewController = self
                NKIAPManager.restoreProduct { _ in}
            } else if title == "Share Our App" {
                let url = URL(string: appStoreUrl)
                let activityVC = UIActivityViewController(activityItems: [GetAppName(), url as Any], applicationActivities: nil)
                activityVC.completionWithItemsHandler = {(_, complete, _, error) -> Void in
                }

                self.present(activityVC, animated: true, completion: nil)
            } else if title == "Terms of Use" {
                let vc = CDPrivateViewController()
                vc.url = "https://sites.google.com/view/hide-photos-terms-of-us/home"
                vc.titleName = title
                let nav = CDNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            } else if title == "Rate Us" {
                CDSignalTon.shared.rataApp(isGoStore: true)
            } else if title == "Privacy Policy" {
                let vc = CDPrivateViewController()
                vc.url = "https://sites.google.com/view/hide-photos-privacy-policy/home"
                vc.titleName = title
                let nav = CDNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                
            }
        }
    }
    
    func setPasswordClick() {
        let vc = CDLockViewController()
        vc.viewType = .set
        self.isInterPop = true
        vc.hidesBottomBarWhenPushed = true
        vc.setAction = { [weak self] in
            guard let self = self else {
                return
            }
            if CDSignalTon.shared.vipType == .not && self.isInterPop {
                self.isInterPop = false

                self.startInterstitialAdsSdk()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)

        
    }
    
    func setFaceIdClick() {
//        let vc = CDFaceViewController()
//        vc.isLogin = false
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
        self.isInterPop = true

        CDAuthorizationTools.checkPermission(type: .faceId, presentVC: self) { [weak self] flag,_ in
            guard let self = self else {
                return
            }
            if flag {
                CDConfigFile.setBoolValueToConfigWith(key: .faceSwitch, boolValue: true)

                if CDSignalTon.shared.vipType == .not && self.isInterPop {
                    self.isInterPop = false
                    
                    DispatchQueue.main.async {
                        self.startInterstitialAdsSdk()
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableblew.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
}

extension CDMineViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
