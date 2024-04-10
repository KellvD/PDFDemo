//
//  CDAblumViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/10.
//

import UIKit

class CDAblumViewController: CDBaseAllViewController {
    
    private var isNeedReloadData: Bool = false
    private var isInterPop = false
    private var collectionView: CDAblumView!

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
        navi.loadData(title: "Media", subTitle: GetTodayFormat(), image: "Add Folder") { [weak self] in
            guard let self = self else {
                return
            }
            self.onCreateAlbumAction()

        }
        
        return navi
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        view.addSubview(self.navigation)
        view.backgroundColor = .white
        var maxH = CDViewHeight
        if CDSignalTon.shared.vipType == .not {
            self.bannerView.rootViewController = self
            self.bannerView.frame = CGRect(x: 0, y: CDViewHeight - self.bannerView.height, width: CDSCREEN_WIDTH, height: self.bannerView.height)
            view.addSubview(self.bannerView)
            
            maxH = self.bannerView.minY
        }
        
        collectionView = CDAblumView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: maxH - self.navigation.maxY))
        view.addSubview(collectionView)
        
        collectionView.selectedCellAction = {[weak self](folder, status) in
            guard let self = self else {
                return
            }
            if status == .select {

                self.isNeedReloadData = true
                self.isInterPop = true
                let vcc = CDMediaViewController()
                vcc.folder = folder
                vcc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vcc, animated: true)
//                CDSignalTon.shared.makeInterstitialAd { _ in}

            } else {
                self.deleteBarItemClick(folder: folder)
            }
        }
                
    }
    
    override func refreshVip() {
        self.bannerView.removeFromSuperview()
        collectionView.height = CDViewHeight - self.navigation.maxY
    }
    
    private func presentVipView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let flag = CDConfigFile.getBoolValueFromConfigWith(key: .isPresentVip)
            if !flag {
                CDConfigFile.setBoolValueToConfigWith(key: .isPresentVip, boolValue: true)
                self.vipVC.isShowInterAds = false
                self.present(self.vipVC, animated: true)

            }
        }
        
    }
    
    @objc func refreshDBData() {
        var folderArr = CDSqlManager.shared.queryDefaultAllMediaFolder()
        if folderArr.count == 0 {
            CDSignalTon.shared.addDefaultSafeFolder()
            folderArr = CDSqlManager.shared.queryDefaultAllMediaFolder()
        }
        collectionView.ablumArr = folderArr
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc func onCreateAlbumAction() {
        if CDSignalTon.shared.vipType == .not {
            self.present(self.vipVC, animated: true)
            return
        }
        addFollder(folderType: .Media) {[weak self] folder in
            guard let self = self else {
                return
            }
            self.isNeedReloadData = true
            self.isInterPop = true
            let vcc = CDMediaViewController()
            vcc.folder = folder
            vcc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vcc, animated: true)
//            CDSignalTon.shared.makeInterstitialAd { _ in}

        }
    }
    
    func deleteBarItemClick(folder: CDSafeFolder) {
        func deleteTheSelectFolder() {
            CDSqlManager.shared.updateOneSafeFolder(with: .delete, folderId: folder.folderId)
            // 删除目录下子文件
            CDSqlManager.shared.updateOneSafeFile(with: .delete, folderId: folder.folderId)
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {
                    return
                }
                self.refreshDBData()
                CDHUDManager.shared.showComplete("Done")
            }
        }
        
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            deleteTheSelectFolder()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    
}
