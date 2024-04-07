//
//  CDHomeViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit
import ZLPhotoBrowser

class CDHomeViewController: CDBaseAllViewController,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var isNeedReloadData: Bool = false
    private var dataArr: [CDSafeFileInfo] = []

    private var bannderIndx = 3
    private var moreIndex = 0
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
    
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 80)
        navi.backgroundColor = .baseBgColor

        navi.loadData(title: "Files", subTitle: "", image: "set") { [weak self] in
            guard let self = self else {
                return
            }
            let vc = CDPurchaseViewController()
//            let nibb = UINib(nibName: "CDPurchaseViewController", bundle: nil)
//            let vc = nibb.instantiate(withOwner: self, options: nil).first as! CDPurchaseViewController

            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }
        return navi
    }()
    
    lazy var addFolder: CDNewFolderAlert = {
        let guaideView = CDNewFolderAlert()
        guaideView.actionHandler = {[weak self] text in
               guard let self = self else {
                   return
               }
            self.addFoldder(text)
        }

        return guaideView
    }()
    
    lazy var moreActionAlert: CDSheetAlert = {
        let alert = CDSheetAlert(items: [.saveAlbum,.rename,.move,.copy,.delete])
        alert.actionHandler = {[weak self] item in
            guard let self = self else {
                return
            }
            self.moreAction(action: item)
        }
        return alert
    }()
    
    lazy var sortAlert: CDSheetAlert = {
        let alert = CDSheetAlert(items: [.timeNewOld,.timeOldNew,.fileBigsmall,.filesmallBig])
        alert.actionHandler = {[weak self] item in
            guard let self = self else {
                return
            }
            self.sortAction(action: item)
        }
        return alert
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        view.addSubview(self.navigation)
        view.backgroundColor = .baseBgColor

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: CDViewHeight - self.navigation.maxY), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDHomeImportCell", bundle: nil), forCellWithReuseIdentifier: "CDHomeImportCell")
        collectionView.register(UINib(nibName: "CDHomeTableCell", bundle: nil), forCellWithReuseIdentifier: "CDHomeTableCell")

        collectionView.register(UINib(nibName: "CDHomeTableHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CDHomeTableHeader")
        
        collectionView.register(CDHomeImportHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CDHomeImportHeader")
        collectionView.register(CDBannerAdsFooterView.self, forCellWithReuseIdentifier: "CDBannerAdsFooterView")


        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .baseBgColor
        view.addSubview(collectionView)
    }
    
    @objc func refreshDBData() {
        dataArr = CDSqlManager.shared.queryAllFileFromFolder(superId: ROOTSUPERID)
        
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 && CDSignalTon.shared.vipType == .not && dataArr.count >= bannderIndx {
            return dataArr.count + 1
        }
        return section == 0 ? 2 : dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: CDSCREEN_WIDTH - 16 * 2, height: 64)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  indexPath.section == 1 && CDSignalTon.shared.vipType == .not && indexPath.item == 3 {
            return CGSize(width: CDSCREEN_WIDTH - 16 * 2, height: 84)
        }
        
        return indexPath.section == 0 ? CGSizeMake((CDSCREEN_WIDTH - 12 * 2 - 16 * 2)/2.0, 78) : CGSizeMake(CDSCREEN_WIDTH - 16 * 2, 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 8 : 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDHomeImportCell", for: indexPath) as! CDHomeImportCell
            
            cell.titleLabel.text = indexPath.item == 0 ? "Import File".localize() : "Import Image".localize()
            cell.iconView.image =  indexPath.item == 0 ? "files_file".image : "files_image".image
            return cell
        } else {
            if CDSignalTon.shared.vipType == .not && indexPath.item == bannderIndx {

                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDBannerAdsFooterView", for: indexPath) as! CDBannerAdsFooterView
                cell.backgroundColor = .gray
                cell.startBannerAdsSdk()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDHomeTableCell", for: indexPath) as! CDHomeTableCell
            var index = indexPath.item
            if CDSignalTon.shared.vipType == .not {
                index = indexPath.item >= 3 ? indexPath.item - 1 : indexPath.item
            }
            let file = dataArr[index]
            cell.loadData(file: file)
            cell.actionHandler = {[weak self] in
                guard let self = self else {
                    return
                }
                self.moreActionAlert.show()
            }
            

            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CDHomeImportHeader", for: indexPath) as! CDHomeImportHeader
            headerView.enable = false
            headerView.actionHandler = {[weak self] _ in
                guard let self = self else {
                    return
                }
                let vcc = CDFilesViewController()
                vcc.title = "Search".localize()
                vcc.modalPresentationStyle = .fullScreen
                self.present(CDNavigationController(rootViewController: vcc), animated: true)
            }
            return headerView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CDHomeTableHeader", for: indexPath) as! CDHomeTableHeader
            headerView.actionHandler = {[weak self] index in
                guard let self = self else {
                    return
                }
                if index == 1 {
                    self.addFolder.show()
                } else {
                    self.sortAlert.show()
                }
            }
            return headerView
            
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                addFromPhoto()
            } else if indexPath.item == 1 {
                addFromDocument()
            }
        } else {
            if CDSignalTon.shared.vipType == .not && indexPath.item == bannderIndx {
                return
            }
            var index = indexPath.item
            if CDSignalTon.shared.vipType == .not {
                index = indexPath.item >= bannderIndx ? indexPath.item - 1 : indexPath.item
            }
            moreIndex = index
            let file = dataArr[index]
            if file.type == .folder {
                let vcc = CDFilesViewController()
                vcc.title = "\(file.name)"
                vcc.superId = file.selfId
                vcc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vcc, animated: true)
            } else {
                
            }
        }
    }
    
    func moreAction(action: SheetItem) {
        let tmpFile = dataArr[moreIndex]
        switch action {
        case .saveAlbum:
            break
        case .rename:break
        case .move:break
        case .copy:
            break
        case .delete:
            let thumbPath = tmpFile.thumbPath.absolutePath
            thumbPath.delete()
            let defaultPath = tmpFile.path.absolutePath
            defaultPath.delete()
            CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.selfId)
            
        default:
            break
        }
    }
    
    func sortAction(action: SheetItem) {
        switch action {
        
        case .timeNewOld:
            dataArr = dataArr.sorted { f1, f2 in
                f1.createTime > f2.createTime
            }
            collectionView.reloadData()
        case .timeOldNew:
            dataArr = dataArr.sorted { f1, f2 in
                f1.createTime < f2.createTime
            }
            collectionView.reloadData()
        case .fileBigsmall:
            dataArr = dataArr.sorted { f1, f2 in
                f1.size > f2.size
            }
            collectionView.reloadData()
        case .filesmallBig:
            dataArr = dataArr.sorted { f1, f2 in
                f1.size < f2.size
            }
            collectionView.reloadData()
        default:
            break
        }
    }
    
    
    func addFoldder(_ text: String) {
        let folder = CDSafeFileInfo()
        folder.createTime = GetTimestamp()
        folder.name = text
        folder.superId = ROOTSUPERID
        folder.size = 0
        folder.type = .folder
        let folderPath = String.RootPath().appendingPathComponent(str: text)
        folderPath.create()
        folder.path = folderPath
        folder.userId = FIRSTUSERID
        _ = CDSqlManager.shared.addSafeFileInfo(fileInfo: folder)

    }
    func sortDataArr() {
        print("sortDataArr")

    }
    func addFromPhoto() {
        CDAuthorizationTools.checkPermission(type: .library, presentVC: self) {[weak self] flag, message in
            guard let self = self else {
                return
            }
            if flag {
                DispatchQueue.main.async {
//                    let freeCount = CDConfigFile.getIntValueFromConfigWith(key: .library_photo)
//                    if CDSignalTon.shared.vipType == .not && freeCount >= 1{
//                        self.present(self.vipVC, animated: true)
//                        return
//                    }
                    
                    let config = ZLPhotoConfiguration.default()
                    config.allowEditVideo = false
                    config.allowEditImage = false
                    config.allowSelectImage = true
                    config.allowSelectVideo = false
                    config.allowTakePhotoInLibrary = false
                    config.allowPreviewPhotos = false
                    config.maxSelectCount = 1


                    let uiconfig = ZLPhotoUIConfiguration.default()
                    uiconfig.showAddPhotoButton = false
                    let ps = ZLPhotoPreviewSheet()
                   
                    ps.selectImageBlock = {  results, isOriginal in
//                        if CDSignalTon.shared.vipType == .not && freeCount < 2{
//                            CDConfigFile.setIntValueToConfigWith(key: .library_photo, intValue: freeCount + 1)
//                        }
//                        DispatchQueue.global().async {
//                            CDSignalTon.shared.saveMedia(results, self.folder)
//                        }
//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: NSNotification.Name("addMediaSuccess"), object: nil)
//
//                            let sheet = UIAlertController(title: "Import Completed", message: "Your photos has been successfully imported into Hide photos & videos.\n\n Do you want to delete the imported photos from you photo library?", preferredStyle: .alert)
//                            sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
//                                CDSignalTon.shared.deleteSystemPhoto(results)
//                            }))
//                            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                            self.present(sheet, animated: true, completion: nil)
//                        }
                    }
                    
                    ps.showPhotoLibrary(sender: self)
                }
            }
        }
    }
    
    func addFromDocument() {
        let flag = CDConfigFile.getIntValueFromConfigWith(key: .libraryFree_docment)
//        if CDSignalTon.shared.vipType == .not && flag >= 2{
//
//            self.present(self.vipVC, animated: true)
//            return
//        }
        
//        let documentTypes = ["public.text", "com.adobe.pdf", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt", "public.data"]
////        super.tmpFolderInfo = folder
//        super.docuemntPickerComplete = {[weak self](_ success: Bool) -> Void in
//            guard let self = self else {
//                return
//            }
//            if success {
////                self.refreshData()
//                if CDSignalTon.shared.vipType == .not && flag < 2{
//                    CDConfigFile.setIntValueToConfigWith(key: .libraryFree_docment, intValue: flag + 1)
//                }
//            }
//        }
//        presentDocumentPicker(documentTypes: documentTypes)
    }
}


class CDBannerAdsFooterView: UICollectionViewCell {
//    lazy var bannerView: GADBannerView = {
//        let vv = GADBannerView(adSize: GADAdSizeBanner)
//        vv.adUnitID = "ca-app-pub-6968510103744100/5259653199"
//        vv.delegate = self
//        startBannerAdsSdk()
//
//        return vv
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
//        self.bannerView.rootViewController = self
//        self.bannerView.frame = CGRect(x: 0, y: 5, width: frame.width, height: self.bannerView.height)
//        contentView.addSubview(self.bannerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startBannerAdsSdk() {
        DispatchQueue.main.async {
//            guard !self.isMobileAdsStartCalld else { return }
//            self.isMobileAdsStartCalld = true
//            self.bannerView.load(GADRequest())
        }
    }
}
