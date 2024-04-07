//
//  CDSettingViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit

class CDSettingViewController: CDBaseAllViewController,UITableViewDelegate, UITableViewDataSource  {
    private let optionArr = ["Rate Us","Share","Privacy Policy","Terms of Use","Restore"]
    let appStoreUrl = "itms-apps://itunes.apple.com/app/id6476800308"

    private var tableblew: UITableView!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseBgColor
        tableblew = UITableView(frame: CGRect(x: 0, y: UIDevice.navigationFullHeight(), width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - UIDevice.navigationFullHeight()), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        tableblew.backgroundColor = .baseBgColor
        view.addSubview(tableblew)

        tableblew.register(UINib(nibName: "CDSettingCell", bundle: nil), forCellReuseIdentifier: "CDSettingCell")
        tableblew.register(UINib(nibName: "CDSettingHeaserCell", bundle: nil), forCellReuseIdentifier: "CDSettingHeaserCell")

        _ = UIButton(frame: CGRect(x: 16, y: UIDevice.navigationFullHeight() - 16 - 32, width: 32, height: 32), imageNormal: "app_back",target: self, function: #selector(backBtnClick), supView: self.view)
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01 : 12
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
        return indexPath.section == 0 ? 276 : 56
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            
            let cell: CDSettingHeaserCell! = tableView.dequeueReusableCell(withIdentifier: "CDSettingHeaserCell", for: indexPath) as? CDSettingHeaserCell
            return cell
        } else {
            let cell: CDSettingCell! = tableView.dequeueReusableCell(withIdentifier: "CDSettingCell", for: indexPath) as? CDSettingCell
            cell.titleL.text = optionArr[indexPath.section - 1]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableblew.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let title = optionArr[indexPath.row]

            if title == "Restore" {
//                NKIAPManager.viewController = self
//                NKIAPManager.restoreProduct { _ in}
            } else if title == "Share" {
                let url = URL(string: appStoreUrl)
                let activityVC = UIActivityViewController(activityItems: [GetAppName(), url as Any], applicationActivities: nil)
                activityVC.completionWithItemsHandler = {(_, complete, _, error) -> Void in
                }

                self.present(activityVC, animated: true, completion: nil)
            } else if title == "Terms of Use" {
                let vc = CDPrivateViewController()
                vc.url = "https://sites.google.com/view/hide-photos-terms-of-us/home"
                vc.titleName = title
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if title == "Rate Us" {
                CDSignalTon.shared.rataApp(isGoStore: true)
            } else if title == "Privacy Policy" {
                let vc = CDPrivateViewController()
                vc.url = "https://sites.google.com/view/hide-photos-privacy-policy/home"
                vc.titleName = title
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }

}
