//
//  CDMediaViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/12.
//

import UIKit
import ZLPhotoBrowser
import JXSegmentedView
import SnapKit
class CDMediaViewController: CDBaseAllViewController,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout {
    private var dataArr: [CDSafeFileInfo] = []
    private var selectedImageArr: [CDSafeFileInfo] = []

    private var isNeedReloadData: Bool = true
    private var collectionView: UICollectionView!
    private var deleteItem: UIButton!
    private var moveItem: UIButton?
    private var loveItem: UIButton?
    private var putBackItem: UIButton?

    private var batchBtn: UIButton!
    private var backBtn: UIButton!
    private let editBtn = UIButton(type: .custom)
    private var selectCount: Int = 0

    public var modifyFolderHandler: ((CDSafeFolder)->Void)?
    public var folder: CDSafeFolder!
    public var fileType: CDSafeFileInfo.NSFileType = .ImageType
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNeedReloadData {
            isNeedReloadData = false
            refreshDBData()
            removeUnusedAblum()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.toolbar.dismiss()
    }
    
    private lazy var toolbar: CDToolBar = {
        var barType:[CDToolBar.CDToolsType] = []
        if folder.folderStatus == .Favourite {
            barType = [.delete, .like]
        }else if folder.folderStatus == .Delete {
            barType = [.delete, .putBack]
        } else {
            barType = [.delete, .move]
        }
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: barType, actionHandler: {[weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .delete,.like,.putBack:
                self.toolBarItemClick(type: type)
            case .move:
                self.moveBarItemClick()
            default:
                break
            }
        })
        
        UIDevice.keyWindow().addSubview(toolbar)
        self.deleteItem = toolbar.viewWithTag(CDToolBar.CDToolsType.delete.rawValue) as? UIButton
        self.moveItem = toolbar.viewWithTag(CDToolBar.CDToolsType.move.rawValue) as? UIButton
        self.loveItem = toolbar.viewWithTag(CDToolBar.CDToolsType.like.rawValue) as? UIButton
        self.putBackItem = toolbar.viewWithTag(CDToolBar.CDToolsType.putBack.rawValue) as? UIButton
        self.loveItem?.setImage("heart".image, for: .normal)

        return toolbar
    }()
    
    lazy var segmentView: CDMediaSegmentView = {
        let segmentView = CDMediaSegmentView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 60))
        segmentView.onClickHandler = {[weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .ImageType:
                self.fileType = .ImageType
                self.refreshDBData()
            case .VideoType:
                self.fileType = .VideoType
                self.refreshDBData()

                break
            default:
                break
            }
        }
        return segmentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        var collectionViewY = 0.0

        if folder.folderStatus == .All ||
            folder.folderStatus == .Custom {
            addBtn.isHidden = false
            addBtn.setImage("Add Media".image, for: .normal)
            self.view.addSubview(self.segmentView)
            collectionViewY = self.segmentView.maxY
        }
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: collectionViewY, width: CDSCREEN_WIDTH, height: CDViewHeight - collectionViewY), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDMediaCell", bundle: nil), forCellWithReuseIdentifier: "CDMediaCell")
        collectionView.register(CDBannerAdsFooterView.self, forCellWithReuseIdentifier: "CDBannerAdsFooterView")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        batchBtn = UIButton(type: .custom)
        batchBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        batchBtn.setImage("setting".image, for: .normal)
        batchBtn.setTitleColor(.customBlack, for: .normal)
        batchBtn.titleLabel?.font = .medium(18)
        batchBtn.contentHorizontalAlignment = .right
        batchBtn.addTarget(self, action: #selector(batchBtnClick), for: .touchUpInside)
        
        backBtn = UIButton(type: .custom)
        backBtn.setImage("back".image, for: .normal)
        backBtn.setTitle(folder.folderName, for: .normal)
        backBtn.setTitleColor(.customBlack, for: .normal)
        backBtn.titleLabel?.font = .medium(18)
        backBtn.contentHorizontalAlignment = .left
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.backBtn.refreshUI()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn)
        if folder.folderStatus == .Custom {
            editBtn.setImage("Edit_tool".image, for: .normal)
            editBtn.addTarget(self, action: #selector(editFolderBtnClick), for: .touchUpInside)
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backBtn),UIBarButtonItem(customView: editBtn)]
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)

        }
        view.bringSubviewToFront(addBtn)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshDBData), name: NSNotification.Name("addMediaSuccess"), object: nil)

        CDSignalTon.shared.rataApp(isGoStore: false)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let collecviewH = scrollView.frame.height
        if offsetY + collecviewH >= contentH {
            scrollView.contentInset.bottom = scrollView.maxY - addBtn.minY
        } else {
            scrollView.contentInset.bottom = 0
        }
    }
    
    @objc func refreshDBData() {
        if self.folder.folderStatus == .Favourite {
            self.dataArr = CDSqlManager.shared.queryAllFile(with: .lovely)
        } else if self.folder.folderStatus == .Delete{
            self.dataArr = CDSqlManager.shared.queryAllDeleteFile(folderType: .Media)
            CDSqlManager.shared.updateAllDeleteFileIsRead(with: .Media)
        } else {
            self.dataArr = CDSqlManager.shared.queryAllFile(with: self.fileType, folderId: self.folder.folderId)
        }
        DispatchQueue.main.async {
            
            self.emptyView.isHidden = self.dataArr.count > 0
            self.selectCount = 0
            self.collectionView.reloadData()
        }
    }
    
    func removeUnusedAblum() {
        if folder.folderStatus != .Delete {
            return
        }
        DispatchQueue.global().async {
            let folderArr = CDSqlManager.shared.queryAllDeleteFolder(folderType: .Media)
            folderArr.forEach { folder in
                let isExit = self.dataArr.contains { file in
                    file.folderId == folder.folderId
                }
                if !isExit {
                    let path = folder.folderPath.absolutePath
                    path.delete()
                    CDSqlManager.shared.deleteOneFolder(folderId: folder.folderId)
                }
            }
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if CDSignalTon.shared.vipType == .not && dataArr.count >= 3 {
            return dataArr.count + 1
        }
        
        return dataArr.count
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if CDSignalTon.shared.vipType == .not && indexPath.item == 3 {
            return CGSize(width: CDSCREEN_WIDTH - 4, height: self.bannerView.height + 10)
        }
        return CGSize(width: (CDSCREEN_WIDTH-10)/3, height: (CDSCREEN_WIDTH-10)/3)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if CDSignalTon.shared.vipType == .not && indexPath.item == 3 {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDBannerAdsFooterView", for: indexPath) as! CDBannerAdsFooterView
            if !cell.contentView.subviews.contains(self.bannerView) {
                self.bannerView.rootViewController = self
                self.bannerView.frame = CGRect(x: 2, y: 5, width: CDSCREEN_WIDTH - 4, height: self.bannerView.height)
                cell.contentView.addSubview(self.bannerView)
            }
            startBannerAdsSdk()
            return cell
        }
        var index = indexPath.item
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.item >= 3 ? indexPath.item - 1 : indexPath.item
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDMediaCell", for: indexPath) as! CDMediaCell
        let file = dataArr[index]
        cell.loadData(file: file, isBatchEdit: batchBtn.isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if CDSignalTon.shared.vipType == .not && indexPath.item == 3 {
            return
        }
        var index = indexPath.item
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.item >= 3 ? indexPath.item - 1 : indexPath.item
        }
        guard let cell: CDMediaCell = collectionView.cellForItem(at: indexPath) as? CDMediaCell else {
            return
        }
        if batchBtn.isSelected {
            let tmFile = dataArr[index]
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
            refreshUI()

        } else {
            self.isNeedReloadData = true
            let scrollerVC = CDMediaScrollerViewController()
            scrollerVC.fileArr = dataArr
            scrollerVC.currentIndex = index
            scrollerVC.folder = folder
            navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }
    
    
    // MARK: - lazy
    lazy var addMediaAlert: CDAddMediaView = {
        let alert = CDAddMediaView(selfType: .media) {[weak self] index in
            guard let self = self else {
                return
            }
            if index == 2 {
                self.addFromFileDocument()
            } else if index == 0  {
                self.addFromCamera()
            } else if index == 1 {
                self.addFromPhoto()
            }
        }
        UIDevice.keyWindow().addSubview(alert)
        return alert
    }()
    
    lazy var emptyView: CDEmptyView = {
        let alert = CDEmptyView(type: .ablum)
        view.addSubview(alert)
        view.bringSubviewToFront(alert)
        return alert
    }()
    
    @objc func editFolderBtnClick() {
        alert(title: "Rename Ablum",placeholder: "Enter a name for a ablum", filedText: folder.folderName , defaultTitle: "Rename") {[weak self] text in
            guard let self = self else {
                return
            }
            self.backBtn.setTitle(text, for: .normal)
            self.backBtn.refreshUI()
            self.folder.folderName = text
            CDSqlManager.shared.updateOneSafeFolder(with: text, folderId: self.folder.folderId)
        }
    }
    
    override func onAddDataAction() {
        self.addMediaAlert.pop()
    }
    
    // MARK: 批量按钮
    @objc func backBtnClick() {
        if batchBtn.isSelected {
            selectedImageArr.removeAll()
            if self.backBtn.currentTitle == "Selected All" { // 全选
                dataArr.forEach { (file) in
                    file.isSelected = .yes
                }
                selectCount = dataArr.count
            } else {// 全不选
                dataArr.forEach { (file) in
                    file.isSelected = .no
                }
                selectCount = 0
            }
            collectionView.reloadData()
            refreshUI()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc func batchBtnClick() {
        banchHandleFiles(isSelected: !batchBtn.isSelected)

    }
    
    private func banchHandleFiles(isSelected: Bool) {
        batchBtn.isSelected = isSelected
        if batchBtn.isSelected { // 点了选择操作
            backBtn.setTitle("Selected All", for: .normal)
            backBtn.setImage(nil, for: .normal)
            batchBtn.setTitle("Cancel", for: .normal)
            batchBtn.setImage(nil, for: .normal)
            if folder.folderStatus == .Custom ||
                folder.folderStatus == .All {
                self.addBtn.isHidden = true
                self.editBtn.isHidden = true

            }
            
            self.toolbar.pop()
        } else {
            // 1.全选变返回
            backBtn.setTitle(folder.folderName, for: .normal)
            backBtn.setImage(UIImage(named: "back"), for: .normal)
            batchBtn.setImage(UIImage(named: "setting"), for: .normal)
            batchBtn.setTitle(nil, for: .normal)
            if folder.folderStatus == .Custom ||
                folder.folderStatus == .All {
                self.addBtn.isHidden = false
                self.editBtn.isHidden = false
            }
            self.toolbar.dismiss()

        }
        dataArr.forEach { (file) in
            file.isSelected = .no
        }
        selectCount = 0

        refreshUI()
        collectionView.reloadData()
    }
    
    func refreshUI() {
        
        if batchBtn.isSelected && dataArr.count > 0 {
            backBtn.setTitle( selectCount == dataArr.count ? "Unselect": "Selected All", for: .normal)
        }
        self.backBtn.refreshUI()


        self.deleteItem?.isEnabled = selectCount > 0
        self.moveItem?.isEnabled = selectCount > 0
        self.loveItem?.isEnabled = selectCount > 0
        self.putBackItem?.isEnabled = selectCount > 0
    }

    
    // MARK: - Add
    func addFromCamera() {
        CDAuthorizationTools.checkPermission(type: .camera, presentVC: self) {[weak self] flag, message in
            guard let self = self else {
                return
            }
            
            if flag {
                DispatchQueue.main.async {
                    let camera = ZLCustomCamera()
                    camera.takeDoneBlock = {  image, videoUrl in
                        
                        CDSignalTon.shared.customPickerView = nil

                        if let tmpImage = image {
                            CDSignalTon.shared.saveOrigialImage(tmpImage, self.folder)
                        }
                        
                        if let tmpVideoUrl = videoUrl {
                            CDSignalTon.shared.saveFileWithUrl(fileUrl: tmpVideoUrl, folderInfo: self.folder)
                        }
                        self.refreshDBData()
                    }
                    CDSignalTon.shared.customPickerView = camera
                    self.showDetailViewController(camera, sender: nil)
                }
            }
        }
    }
    
    func addFromPhoto() {
        CDAuthorizationTools.checkPermission(type: .library, presentVC: self) {[weak self] flag, message in
            guard let self = self else {
                return
            }
            if flag {
                DispatchQueue.main.async {
                    let freeCount = CDConfigFile.getIntValueFromConfigWith(key: .library_photo)
                    if CDSignalTon.shared.vipType == .not && freeCount >= 1{
                        self.present(self.vipVC, animated: true)
                        return
                    }
                    
                    let config = ZLPhotoConfiguration.default()
                    config.allowEditVideo = false
                    config.allowEditImage = false
                    config.maxSelectVideoDuration = 60 * 60
                    config.allowSelectImage = self.fileType == .ImageType
                    config.allowSelectVideo = self.fileType == .VideoType
                    config.allowTakePhotoInLibrary = false
                    config.allowPreviewPhotos = false
                    config.maxSelectCount = 10000


                    let uiconfig = ZLPhotoUIConfiguration.default()
                    uiconfig.showAddPhotoButton = false
                    let ps = ZLPhotoPreviewSheet()
                   
                    ps.selectImageBlock = {  results, isOriginal in
                        if CDSignalTon.shared.vipType == .not && freeCount < 2{
                            CDConfigFile.setIntValueToConfigWith(key: .library_photo, intValue: freeCount + 1)
                        }
                        DispatchQueue.global().async {
                            CDSignalTon.shared.saveMedia(results, self.folder)
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name("addMediaSuccess"), object: nil)
                            
                            let sheet = UIAlertController(title: "Import Completed", message: "Your photos has been successfully imported into Hide photos & videos.\n\n Do you want to delete the imported photos from you photo library?", preferredStyle: .alert)
                            sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                                CDSignalTon.shared.deleteSystemPhoto(results)
                            }))
                            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(sheet, animated: true, completion: nil)
                        }
                    }
                    
                    ps.showPhotoLibrary(sender: self)
                }
            }
        }
    }
    
    func addFromFileDocument() {
        let flag = CDConfigFile.getIntValueFromConfigWith(key: .libraryFree_docment)
        if CDSignalTon.shared.vipType == .not && flag >= 1{
            
            self.present(self.vipVC, animated: true)
            return
        }
        
        let documentTypes = fileType == .VideoType ? "public.movie" : "public.image"
        super.tmpFolderInfo = folder
        super.docuemntPickerComplete = {[weak self](_ success: Bool) -> Void in
            guard let self = self else {
                return
            }
            if success {
                self.refreshDBData()
                if CDSignalTon.shared.vipType == .not && flag < 2{
                    CDConfigFile.setIntValueToConfigWith(key: .libraryFree_docment, intValue: flag + 1)
                }
            }
        }
        presentDocumentPicker(documentTypes: [documentTypes])

    }
    
    func popVip() {
        let sheet = UIAlertController(title: "Tip", message: "To select multiple photos in bulk, a subscription unlock is required. Unlock now!", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Upgrade Now", style: .destructive, handler: { (_) in
            self.present(self.vipVC, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
   
}

extension CDMediaViewController {
    func handelSelectedArr() {
        selectedImageArr.removeAll()
        selectedImageArr = dataArr.filter({ (tmp) -> Bool in
            tmp.isSelected == .yes
        })
    }
    
    private func toolBarItemClick(type: CDToolBar.CDToolsType) {
        var action = "Delete"
        if type == .like {
            action = "Like"
        }else if type == .putBack {
            action = "Put Back"
        }
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: action, style: .destructive, handler: { (_) in
            self.handelSelectedArr()
            switch type {
            case.delete:
                self.deleteBarItemClick()
            case .putBack:
                self.putBackItemClick()
            case .like:
                self.loveItemClick()
            default:
                break
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func moveBarItemClick() {
        handelSelectedArr()
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Move", style: .destructive, handler: {[weak self] (_) in
            guard let self = self else {
                return
            }
            let vc = CDMediaPickerViewController()
            vc.originalFolderId = self.folder.folderId
            vc.selectedArr = self.selectedImageArr
            vc.moveHandle = { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.refreshDBData()
                self.banchHandleFiles(isSelected: false)

            }
            self.present(CDNavigationController(rootViewController: vc), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
        

    }
    
    func deleteBarItemClick() {
        
        func delete() {
            CDHUDManager.shared.showWait()

            selectedImageArr.forEach { (tmpFile) in
                let thumbPath = tmpFile.thumbImagePath.absolutePath
                thumbPath.delete()
                let defaultPath = tmpFile.filePath.absolutePath
                defaultPath.delete()
                CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.fileId)
            }
            self.refreshDBData()
            self.banchHandleFiles(isSelected: false)
            CDHUDManager.shared.hideWait()

        }
        
        if folder.folderStatus == .Delete {
            if CDSignalTon.shared.vipType == .not {
                
                guidedPayment {
                    delete()
                }
            }else {
                delete()
                CDHUDManager.shared.showComplete("Done")

            }
        } else {
            CDHUDManager.shared.showWait()

            selectedImageArr.forEach { (tmpFile) in
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .delete, fileId: tmpFile.fileId)
            }
            self.refreshDBData()
            self.banchHandleFiles(isSelected: false)
            CDHUDManager.shared.hideWait()
            CDHUDManager.shared.showComplete("Done")
        }
        

    }
    
    func loveItemClick() {
        CDHUDManager.shared.showWait()

        selectedImageArr.forEach { (tmpFile) in
            CDSqlManager.shared.updateOneSafeFileGrade(with: .normal, fileId: tmpFile.fileId)
        }
        self.refreshDBData()
        self.banchHandleFiles(isSelected: false)
        CDHUDManager.shared.hideWait()
        CDHUDManager.shared.showComplete("Done")
    }
    
    func putBackItemClick() {
        func putBack() {
            CDHUDManager.shared.showWait()

            selectedImageArr.forEach { (tmpFile) in
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .normal, fileId: tmpFile.fileId)
                let life = CDSqlManager.shared.queryOneFolderLifeCircle(folderId: tmpFile.folderId)
                if life == .delete {
                    CDSqlManager.shared.updateOneSafeFolder(with: .normal, folderId: tmpFile.folderId)
                }
            }
            self.refreshDBData()
            self.banchHandleFiles(isSelected: false)
            CDHUDManager.shared.hideWait()
        }
        
        if CDSignalTon.shared.vipType == .not {
            guidedPayment {
                putBack()
            }
        }else {
            putBack()
            CDHUDManager.shared.showComplete("Done")
        }
    }
}


class CDBannerAdsFooterView: UICollectionViewCell {

}
