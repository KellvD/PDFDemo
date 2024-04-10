//
//  CDPageViewController.swift
//  Figma
//
//  Created by dong chang on 2024/3/28.
//

import UIKit

class CDPageViewController: UIViewController {
    public var currentIndex: Int = 0
    private var collectionView: UICollectionView!

    @IBOutlet weak var termsbtn: UIButton!
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var pageContrrol: UIPageControl!
    
    @IBOutlet weak var bottomBtnss: UIView!
    
    var isOnlyWeekSub = false
    @IBOutlet weak var bottomCon: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor =
//        termsbtn.setTitleColor(UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1), for: .normal)
        bottomCon.constant = UIDevice.safeAreaBottom() > 0 ? 132 : 90
        termsbtn.titleLabel?.font = .medium(12)
        skipBtn.titleLabel?.font = .medium(12)

        skipBtn.setTitleColor(UIColor(red: 0.502, green: 0.514, blue: 0.557, alpha: 1), for: .normal)
//        privateBtn.setTitleColor(UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1), for: .normal)
        privateBtn.titleLabel?.font = .medium(12)
        
        restoreBtn.titleLabel?.font = .medium(12)

        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.titleLabel?.font = .medium(16)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - bottomCon.constant)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - bottomCon.constant), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CDPagesViewCell.self, forCellWithReuseIdentifier: "CDPagesViewCell")
        collectionView.register(CDPageVipCell.self, forCellWithReuseIdentifier: "CDPageVipCell")
        
        self.view.addSubview(collectionView)
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        continueBtn.layer.cornerRadius = 24
        
        self.view.bringSubviewToFront(pageContrrol)
        self.pageContrrol.isHidden = isOnlyWeekSub
        self.bottomBtnss.isHidden = !isOnlyWeekSub
        continueBtn.setTitle(isOnlyWeekSub ? "Subscribe Now": "Contine", for: .normal)

    }

    @IBAction func skipAction(_ sender: Any) {
        goTabar()
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        currentIndex += sender.currentPage

        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if currentIndex == 3 || isOnlyWeekSub {
            CDHUDManager.shared.showWait()
            NKIAPManager.purchaseProduct(productIDs: IAP_Week) {[weak self] flag in
                CDHUDManager.shared.hideWait()

                guard let self = self else {
                    return
                }
                if CDSignalTon.shared.vipType == .vip {
                    self.goTabar()
                }
            }
            
        } else {
            currentIndex += 1
            continueBtn.setTitle(currentIndex == 3 ? "Subscribe Now": "Contine", for: .normal)
            pageContrrol.isHidden = currentIndex == 3
            bottomBtnss.isHidden = currentIndex != 3

            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            pageContrrol.currentPage = currentIndex
        }

    }
    
    func alert() {
        let alert = UIAlertController(title: "", message: "Your all features has been unlock!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I Know", style: .default, handler: {[weak self] _ in
            guard let self = self else {
                return
            }
            self.goTabar()
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func termsActionn(_ sender: Any) {
        let vc = CDPrivateViewController()
        vc.url = "https://sites.google.com/view/hide-photos-terms-of-us/home"
        vc.titleName = "Terms of Use"
        let nav = CDNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @IBAction func privateAction(_ sender: Any) {
        let vc = CDPrivateViewController()
        vc.url = "https://sites.google.com/view/hide-photos-privacy-policy/home"
        vc.titleName = "Privacy Policy"
        let nav = CDNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        if CDSignalTon.shared.vipType == .vip {
            alert()
            return
        }
        NKIAPManager.viewController = self
        NKIAPManager.restoreProduct { [weak self] flag in
            CDHUDManager.shared.hideWait()
            
            guard let self = self else {
                return
            }
            if CDSignalTon.shared.vipType == .vip {
                
                self.goTabar()
            }
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
    
    func goTabar() {
        CDSignalTon.shared.tab = CDTabBarViewController()
        let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
        myDelegate.window?.rootViewController = CDSignalTon.shared.tab
    }

}


extension CDPageViewController: UICollectionViewDelegate,
                                        UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isOnlyWeekSub ? 1 : 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isOnlyWeekSub {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDPageVipCell", for: indexPath) as! CDPageVipCell
            cell.actionHandler = {[weak self] in
                guard let self = self else {
                    return
                }
                self.goTabar()
                
            }
            return cell
        }else {
            if indexPath.item == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDPageVipCell", for: indexPath) as! CDPageVipCell
                cell.actionHandler = {[weak self] in
                    guard let self = self else {
                        return
                    }
                    self.goTabar()
                    
                }
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDPagesViewCell", for: indexPath) as! CDPagesViewCell
            cell.imageview.image = "Replace this \(indexPath.item)".image
            if indexPath.item == 0 {
                cell.titleLabel.text = "Welcome to Hide Photos"
                cell.contentLabel.text = "Lock photos, videos, and all your data stay on your phone only."
            } else if indexPath.item == 1 {
                cell.titleLabel.text = "Multi Websites"
                cell.contentLabel.text = "Check out our multi website features open multi page at once."
                
            } else if indexPath.item == 2 {
                cell.titleLabel.text = "File Manager"
                cell.contentLabel.text = "Keep all your important file to a safe with password."
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isOnlyWeekSub {
            return
        }
        
        guard let firstIndexPath = collectionView.indexPathsForVisibleItems.first else {
            return
        }
        let page = firstIndexPath.item
        currentIndex = page

        continueBtn.setTitle(currentIndex == 3 ? "Subscribe Now": "Contine", for: .normal)
        pageContrrol.isHidden = page == 3
        bottomBtnss.isHidden = page != 3

        pageContrrol.currentPage = page
    }
}
