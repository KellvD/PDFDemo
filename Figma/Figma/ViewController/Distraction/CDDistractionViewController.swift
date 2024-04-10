//
//  CDDistractionViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/11.
//

import UIKit
import FamilyControls
import Combine
class CDDistractionViewController: CDBaseAllViewController,UITableViewDelegate, UITableViewDataSource {

    private var tableblew: UITableView!
    var cancel: AnyCancellable?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 112)
        navi.loadData(title: "Distraction Apps", subTitle: "App Restrictions ", image: "帮助") { [weak self] in
            guard let self = self else {
                return
            }
        }
        return navi
    }()
    let titleArr = ["","Disallow app deletion","Disallow app installation","Disallow in-app purchases"]
    let subTitleArr = ["","Prevent accidental deletion of all apps to avoid losing precious chat records","Prevent App Store from installing new apps ","Prevent accidental payments and incurring additional charges"]
    let iconArr = ["","禁止删除app","禁止下载app","禁止app内购"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.navigation)
        tableblew = UITableView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - self.navigation.maxY), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        tableblew.backgroundColor = .white
        view.addSubview(tableblew)
        tableblew.register(UINib(nibName: "CDDistractionHeaderCell", bundle: nil), forCellReuseIdentifier: "CDDistractionHeaderCell")
        tableblew.register(UINib(nibName: "CDDistractionCell", bundle: nil), forCellReuseIdentifier: "CDDistractionCell")

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 163 : 106
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell: CDDistractionHeaderCell! = tableView.dequeueReusableCell(withIdentifier: "CDDistractionHeaderCell", for: indexPath) as? CDDistractionHeaderCell
            cell.titleLabel.text = "Restrictions 0 Apps"
            cell.subTitleLabel.text = "Restrict opening specific apps and prevent excessive gaming"
            cell.actionBlock = {
                let vc = CDDistractionSettingViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        } else {
            let cell: CDDistractionCell! = tableView.dequeueReusableCell(withIdentifier: "CDDistractionCell", for: indexPath) as? CDDistractionCell
            cell.titleLabel.text = titleArr[indexPath.section]
            cell.contentLabel.text = subTitleArr[indexPath.section]
            cell.iconView.image = iconArr[indexPath.section].image
            cell.actionBlock = {[weak self] isOn in
                guard let self = self else {
                    return
                }
                self.switchClick(indexPath.section)
            }
            return cell
        }
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
        normalLayer.fillColor = UIColor(241, 245, 250).cgColor
        nomarBgView.layer.insertSublayer(normalLayer, at:0)
        nomarBgView.backgroundColor = .clear
        cell.backgroundView = nomarBgView
        
        let selectBgView = UIView(frame: bounds)
        selectLayer.fillColor = UIColor.lightGray.cgColor
        selectBgView.layer.insertSublayer(selectLayer, at:0)
        cell.selectedBackgroundView = selectBgView

    }
    
    func switchClick(_ index: Int) {
        if index == 0 {
            print("TODO: delete")
        } else if index == 1 {
            print("TODO: install")
            let url = "App-Prefs:root=General&path=USAGE/SCREEN_TIME"
            UIApplication.shared.open(URL(string: url)!)
        }else {
            print("TODO: iap")
            checkPermissions { flag in
                
            }
        }
        
    }

    
    func checkPermissions(complete: @escaping ((Bool)->Void)) {
//        STS.is
//        Task {
//            let center = AuthorizationCenter.shared
//            if #available(iOS 16.0, *) {
//                do {
//                    try await center.requestAuthorization(for: .individual)
//
//                } catch {
//                    assertionFailure("\(error.localizedDescription)")
//                }
//            } else {
//                center.requestAuthorization { result in
//                    switch result {
//                    case .success():
//                        print("dsd")
//                    case .failure(let error):
//                        print("request failed:\(error.localizedDescription)")
//                    }
//                }
//            }
//
//            switch center.authorizationStatus {
//            case .notDetermined:
//                print("申请授权 未授权")
//
//            case .denied:
//                print("申请授权 jujue")
//
//            case .approved:
//                print("申请授权 approved")
//                let url = "App-Prefs:root=General&path=USAGE/SCREEN_TIME"
//                await UIApplication.shared.open(URL(string: url)!)
//            @unknown default:
//                break
//
//            }
//        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

