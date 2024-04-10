//
//  CDWebViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/10.
//

import UIKit

class CDWebViewController: CDBaseAllViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var dataArr: [CDWebPageInfo] = []
    private var sitArr: [CDWebPageInfo] = []

    private var isNeedReloadData = false
    private var isInterPop = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 112)
        navi.loadData(title: "Multi Websites", subTitle: "Most Visit:", image: "添加网页") { [weak self] in
            guard let self = self else {
                return
            }
            self.addPageAction()

        }
        return navi
    }()
    
    lazy var emptyView: CDEmptyView = {
        let alert = CDEmptyView(type: .web)
        view.addSubview(alert)
        view.bringSubviewToFront(alert)
        return alert
    }()
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(self.navigation)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        var maxH = CDViewHeight
        if CDSignalTon.shared.vipType == .not {
            self.bannerView.rootViewController = self
            self.bannerView.frame = CGRect(x: 0, y: CDViewHeight - self.bannerView.height, width: CDSCREEN_WIDTH, height: self.bannerView.height)
            view.addSubview(self.bannerView)
            
            maxH = self.bannerView.minY
//            startBannerAdsSdk()
        }
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: maxH - self.navigation.maxY), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDWebSiteCell", bundle: nil), forCellWithReuseIdentifier: "CDWebSiteCell")
        collectionView.register(UINib(nibName: "CDWebPageCell", bundle: nil), forCellWithReuseIdentifier: "CDWebPageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        refreshDBData()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDBData), name: NSNotification.Name("updateWebPage"), object: nil)


    }
    
    override func refreshVip() {
        self.bannerView.removeFromSuperview()
        collectionView.height = CDViewHeight - self.navigation.maxY
    }
    
    @objc func refreshDBData() {
        dataArr = CDSqlManager.shared.queryAllWebPage(type: .normal)
        sitArr = CDSqlManager.shared.queryAllWebPage(type: .lock)
        self.emptyView.isHidden = dataArr.count > 0
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    func addPageAction() {
        func addNewPage() {
            self.isNeedReloadData = true

            let vc = CDWebPageViewController()
            vc.isAdd = true
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
//            CDSignalTon.shared.makeInterstitialAd { _ in}

        }
        
        if CDSignalTon.shared.vipType == .not{
            self.guidedPayment {
                addNewPage()
            }
            return
        }else {
            addNewPage()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? sitArr.count : dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section == 0 ? CGSizeMake((CDSCREEN_WIDTH - 12 * 5)/4.0, 92) : CGSizeMake((CDSCREEN_WIDTH - 12 * 2 - 32)/2.0, 194)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 12 : 32
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDWebSiteCell", for: indexPath) as! CDWebSiteCell
            let web = sitArr[indexPath.item]
            cell.loadData(web)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDWebPageCell", for: indexPath) as! CDWebPageCell
        let web = dataArr[indexPath.item]
        cell.actionBlock = {[weak self] in
            guard let self = self else {
                return
            }
            if CDSignalTon.shared.vipType == .not {
                self.present(self.vipVC, animated: true)
                return
            }
            self.dataArr.remove(at: indexPath.item)
            self.collectionView.reloadData()
            CDSqlManager.shared.updateWebPagewWebType(type: .history, webId: web.webId)
            
        }
        cell.loadData(file: web, isBatchEdit: false)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let web = sitArr[indexPath.item]
            self.isNeedReloadData = true
            self.isInterPop = true

            if CDSignalTon.shared.vipType == .not {
                let id = CDConfigFile.getIntValueFromConfigWith(key: .freeWebsit)
                if id == -1 || id == web.webId {
                    let vc = CDWebPageViewController()
                    vc.file = web
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    CDConfigFile.setIntValueToConfigWith(key: .freeWebsit, intValue: web.webId)
//                    CDSignalTon.shared.makeInterstitialAd { _ in}

                } else {
                    self.present(self.vipVC, animated: true)
                }
                
            } else {
                let vc = CDWebPageViewController()
                vc.file = web
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
//                CDSignalTon.shared.makeInterstitialAd { _ in}
            }

        } else {
            self.isInterPop = true

            let web = dataArr[indexPath.item]
            let vc = CDWebPageViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.file = web
            self.navigationController?.pushViewController(vc, animated: true)
//            CDSignalTon.shared.makeInterstitialAd { _ in}

        }
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
