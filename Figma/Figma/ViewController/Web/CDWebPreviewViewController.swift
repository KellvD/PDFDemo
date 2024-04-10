//
//  CDWebPreviewViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/15.
//

import UIKit

class CDWebPreviewViewController: CDBaseAllViewController,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var dataArr: [CDWebPageInfo] = []
    private var selectedArr:[CDWebPageInfo] = []
    private var selectCount: Int = 0
    private var isEdit = false
    private var rightItemBtn: UIButton!
    private var leftItemBtn: UIButton!
    var naItem: UINavigationItem!
    var backBlock: (() -> Void)?

    lazy var popView: CDPopMenuView = {
        let popView = CDPopMenuView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH),
                                    imageArr: ["选择", "关闭所有网页"],
                                    titleArr: ["Select Tabs", "Close All Tabs"])
        popView.popDelegate = self
        self.view.addSubview(popView)
        return popView
    }()

    lazy var editBar: CDToolBar = {
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: [.edit, .addBg, .done]) { [weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .edit:
                self.editActtion()
            case .done:
                self.doneActtion()
            case .addBg:
                self.addActtion()
            default:
                break
            }
        }
        view.addSubview(toolbar)
        return toolbar
    }()
    
    lazy var closeTab: CDToolBar = {
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: [.close]) { [weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .close:
                self.closeAction()
            default:
                break
            }
        }
        toolbar.closeTabItem.isEnabled = false
        view.addSubview(toolbar)
        return toolbar
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        naItem.leftBarButtonItem = UIBarButtonItem(customView: leftItemBtn)
        naItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        self.tabBarController?.hidesBottomBarWhenPushed = true


    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var maxH: CGFloat = 0

        if CDSignalTon.shared.vipType == .not {
            self.bannerView.rootViewController = self
            self.bannerView.frame = CGRect(x: 0, y: CDViewHeight - self.bannerView.height, width: CDSCREEN_WIDTH, height: self.bannerView.height)
            view.addSubview(self.bannerView)
            
            maxH = self.bannerView.height
//            startBannerAdsSdk()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: self.editBar.minY - maxH), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDWebPageCell", bundle: nil), forCellWithReuseIdentifier: "CDWebPageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        leftItemBtn = UIButton(type: .custom)
        self.leftItemBtn.setTitleColor(.customBlack, for: .normal)
        self.leftItemBtn.titleLabel?.font = UIFont.regular(16)
        self.leftItemBtn.setTitle("Select All", for: .normal)
        self.leftItemBtn.isHidden = true
        self.leftItemBtn.addTarget(self, action: #selector(leftItemClick), for: .touchUpInside)
        
        rightItemBtn = UIButton(type: .custom)
        self.rightItemBtn.setTitleColor(.customBlack, for: .normal)
        self.rightItemBtn.titleLabel?.font = UIFont.regular(16)
        self.rightItemBtn.setTitle("Done", for: .normal)
        self.rightItemBtn.isHidden = true
        self.rightItemBtn.addTarget(self, action: #selector(rightItemClick), for: .touchUpInside)
        refreshDBData()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDBData), name: NSNotification.Name("updateWebPage"), object: nil)



    }
    
    override func refreshVip() {
        self.bannerView.removeFromSuperview()
        collectionView.height = self.editBar.minY
    }
    
    @objc func refreshDBData() {
        dataArr = CDSqlManager.shared.queryAllWebPage(type: .normal)
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake((CDSCREEN_WIDTH - 12 * 2 - 32)/2.0, 194)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDWebPageCell", for: indexPath) as! CDWebPageCell
        let file = dataArr[indexPath.item]
        cell.loadData(file: file, isBatchEdit: isEdit)
        
        cell.actionBlock = { [weak self] in
            guard let self = self else {
                return
            }
            self.editCell(index: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if isEdit {
            editCell(index: indexPath)

        } else {
            let scrollerVC = CDWebPageViewController()
            scrollerVC.file = dataArr[indexPath.row]
            navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }


    func editActtion() {
        self.popView.showPopView()
    }
    
    func addActtion() {
        func addNewPage() {
            let vc = CDWebPageViewController()
            vc.isAdd = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if CDSignalTon.shared.vipType == .not {
            self.guidedPayment {
                addNewPage()
            }
            return
        }else {
            addNewPage()
        }
 
    }
    
    func doneActtion() {
        guard let backBlock = backBlock else {
            return
        }
        backBlock()
    }
    
    func closeAction () {
        if CDSignalTon.shared.vipType == .not {
            self.present(self.vipVC, animated: true)
            return
        }
        
        selectedArr = dataArr.filter({ file in
            file.isSelected == .yes
        })
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Close \(selectCount) Tabs", style: .destructive, handler: { (_) in
            CDHUDManager.shared.showWait()
            DispatchQueue.global().async { [weak self] in
                guard let self = self else {
                    return
                }
                self.deleteThePage()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func deleteThePage() {
        if CDSignalTon.shared.vipType == .not {
            self.present(self.vipVC, animated: true)
            return
        }
        
        selectedArr.forEach { (tmpFile) in
           
            let thumbPath = tmpFile.thumbImagePath.absolutePath
            thumbPath.delete()
            CDSqlManager.shared.updateWebPagewWebType(type: .history, webId: tmpFile.webId)
            let index = dataArr.firstIndex(of: tmpFile)
            dataArr.remove(at: index!)
            
        }
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {
                return
            }
            self.leftItemBtn.isHidden = true
            self.rightItemBtn.isHidden = true
            self.closeTab.dismiss()
            self.editBar.pop()
            self.selectCount = 0
            self.collectionView.reloadData()
            CDHUDManager.shared.hideWait()
            CDHUDManager.shared.showComplete("Done")
        }
    }
    
    func editCell(index: IndexPath){
        guard let cell = collectionView.cellForItem(at: index) as? CDWebPageCell else {
            return
        }
        
        if isEdit {
            let tmFile = dataArr[index.item]
            if tmFile.isSelected == .no {
                cell.isSelected = true
                selectCount += 1
                tmFile.isSelected = .yes
            } else {
                cell.isSelected = false
                selectCount -= 1
                tmFile.isSelected = .no
            }
            cell.reloadSelectImageView()
            closeTab.closeTabItem.isEnabled = selectCount > 0

        } else {
            if CDSignalTon.shared.vipType == .not {
                self.present(self.vipVC, animated: true)
                return
            }
            let tmFile = dataArr[index.item]
            self.dataArr.remove(at: index.item)
            self.collectionView.reloadData()
            CDSqlManager.shared.updateWebPagewWebType(type: .history, webId: tmFile.webId)
        }
    }
    
    @objc func leftItemClick(senderr: UIButton) {
        if senderr.currentTitle == "Select All" {
            senderr.setTitle("Unselect", for: .normal)
            dataArr.forEach { (file) in
                file.isSelected = .yes
            }
            selectCount = dataArr.count
            collectionView.reloadData()
            closeTab.closeTabItem.isEnabled = true
        } else {
            senderr.setTitle("Select All", for: .normal)
            dataArr.forEach { (file) in
                file.isSelected = .no
            }
            selectCount = 0
            collectionView.reloadData()
        }
    }
    
    @objc func rightItemClick(sender: UIButton) {
        isEdit = false
        leftItemBtn.isHidden = true
        sender.isHidden = true
        
        dataArr.forEach { (file) in
            file.isSelected = .no
        }
        selectCount = 0
        collectionView.reloadData()
        self.closeTab.dismiss()
        editBar.pop()
    }
}


extension CDWebPreviewViewController: CDPopMenuViewDelegate {
    // MARK:
    func onSelectedPopMenu(title: String) {
        self.popView.dismiss()
        isEdit = true
        editBar.dismiss()
        if title == "Select Tabs" {
            collectionView.reloadData()
        } else if title == "Close All Tabs" {
            dataArr.forEach { (file) in
                file.isSelected = .yes
            }
            selectCount = dataArr.count
            collectionView.reloadData()
        }
        
        closeTab.pop()
        self.leftItemBtn.isHidden = false
        self.rightItemBtn.isHidden = false


    }
}
