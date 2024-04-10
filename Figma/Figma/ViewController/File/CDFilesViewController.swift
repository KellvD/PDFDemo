//
//  CDFilesViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/12.
//

import UIKit
import Combine
class CDFilesViewController: CDBaseAllViewController, UITableViewDelegate, UITableViewDataSource  {
    private var tableblew: UITableView!
    private var batchBtn: UIButton!
    private var toolbar: CDToolBar!
    private var backBtn: UIButton!
    private let editBtn = UIButton(type: .custom)
    
    private var deleteItem: UIButton?
    private var moveItem: UIButton?
    private var putBackItem: UIButton?

    private var fileArr: [CDSafeFileInfo] = []
    private var searchDefaultArr: [CDSafeFileInfo] = []
    private var isNeedReloadData: Bool = false // 是否刷新数据
    private var selectCount: Int = 0
    private var selectedFileArr: [CDSafeFileInfo] = []
    private var searchText: String? = ""
    private var coveryView: CDCoveryView!
    public var folder = CDSafeFolder()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isNeedReloadData {
            isNeedReloadData = false
            refreshData()
            removeUnusedAblum()

        }
    }
    lazy var addMediaAlert: CDAddMediaView = {
        let alert = CDAddMediaView(selfType: .file) {[weak self] type in
            guard let self = self else {
                return
            }
            if type == 2  {
                self.addFromDocument()
            } else if type == 0 {
                self.addNewNote()
            } else if type == 1 {
                self.addFromClipboard()
            }
        }
        UIDevice.keyWindow().addSubview(alert)
        return alert
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        isNeedReloadData = true
        var barType:[CDToolBar.CDToolsType] = []
        if folder.folderStatus == .Delete {
            barType = [.delete, .putBack]
        } else {
            barType = [.delete, .move]
        }
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: barType, actionHandler: {[weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .delete,.putBack:
                self.toolBarItemClick(type: type)
            case .move:
                self.moveBarItemClick()
            default:
                break
            }
            
        })
        self.deleteItem = toolbar.viewWithTag(CDToolBar.CDToolsType.delete.rawValue) as? UIButton
        self.moveItem = toolbar.viewWithTag(CDToolBar.CDToolsType.move.rawValue) as? UIButton
        self.putBackItem = toolbar.viewWithTag(CDToolBar.CDToolsType.putBack.rawValue) as? UIButton

        view.addSubview(self.toolbar)
        
        let searchBar = CDCustomSearchBar(frame: CGRect(x: 0, y: 10, width: CDSCREEN_WIDTH, height: 32))
        view.addSubview(searchBar)
        searchBar.actionBlock = {[weak self]text in
            guard let self = self else {
                return
            }
            self.searchRefreshData(text)
        }
        
        searchBar.didBeginEditBlock = {[weak self] in
            guard let self = self else {
                return
            }
            self.coveryView.pop()
        }

        tableblew = UITableView(frame: CGRect(x: 0, y: searchBar.maxY + 8, width: CDSCREEN_WIDTH, height: CDViewHeight - searchBar.maxY + 8), style: .grouped)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.backgroundColor = .baseBgColor
        tableblew.separatorStyle = .none
        view.addSubview(tableblew)
        tableblew.register(CDFilesCell.self, forCellReuseIdentifier: "CDFilesCell")
        tableblew.register(UITableViewCell.self, forCellReuseIdentifier: "bannerCell")

        
        batchBtn = UIButton(type: .custom)
        batchBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        batchBtn.setImage(UIImage(named: "setting"), for: .normal)
        batchBtn.setTitleColor(.customBlack, for: .normal)
        batchBtn.titleLabel?.font = .medium(18)
        batchBtn.contentHorizontalAlignment = .right
        batchBtn.addTarget(self, action: #selector(batchBtnClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn!)

        backBtn = UIButton(type: .custom)
        backBtn.setImage("back".image, for: .normal)
        backBtn.setTitle(folder.folderName, for: .normal)
        backBtn.setTitleColor(.customBlack, for: .normal)
        backBtn.titleLabel?.font = .medium(18)
        backBtn.contentHorizontalAlignment = .left
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.refreshUI()
        if folder.folderStatus == .Custom {
            editBtn.setImage("Edit_tool".image, for: .normal)
            editBtn.addTarget(self, action: #selector(editFolderBtnClick), for: .touchUpInside)
            navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backBtn),UIBarButtonItem(customView: editBtn)]
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)

        }
        
        coveryView = CDCoveryView(frame: tableblew.frame)
        view.addSubview(coveryView)
        view.bringSubviewToFront(coveryView)
        coveryView.dismissHandler = { [weak self] in
            guard let self = self else {
                return
            }
            searchBar.finishSearch()
            self.searchRefreshData(nil)
        }
        
        if folder.folderStatus != .Delete {
            addBtn.isHidden = false
            view.bringSubviewToFront(addBtn)
            addBtn.setImage("Add Files".image, for: .normal)
        }

        CDSignalTon.shared.rataApp(isGoStore: false)
    }
    
    override func refreshVip() {
        self.tableblew.reloadData()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !batchBtn.isSelected
    }
    
    lazy var emptyView: CDEmptyView = {
        let alert = CDEmptyView(type: .folder)
        view.addSubview(alert)
        view.bringSubviewToFront(alert)
        return alert
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if CDSignalTon.shared.vipType == .not && fileArr.count > 0 {
            return fileArr.count + 1
        }
        return fileArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if CDSignalTon.shared.vipType == .not && section == 1 {
            return 0.01
        }
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if CDSignalTon.shared.vipType == .not && section == 1 {
            return 0.01
        }
        return 12
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if CDSignalTon.shared.vipType == .not && indexPath.section == 1 {
            return self.bannerView.height
        }
        return 117
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if CDSignalTon.shared.vipType == .not && indexPath.section == 1 {
            
            let cell:UITableViewCell = tableblew.dequeueReusableCell(withIdentifier: "bannerCell", for: indexPath)
            if !cell.contentView.subviews.contains(self.bannerView) {
                
                self.bannerView.rootViewController = self
                self.bannerView.frame = CGRect(x: 16, y: 0, width: CDSCREEN_WIDTH - 32, height: self.bannerView.height)
                cell.contentView.addSubview(self.bannerView)
                
            }
            startBannerAdsSdk()
            return cell
            
        }
        var index = indexPath.section
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.section == 0 ? 0 : indexPath.section - 1
        }
        
        let cellId = "CDFilesCell"
        let cell: CDFilesCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CDFilesCell
        let fileInfo =  fileArr[index]
        cell.loadData(fileInfo, searchText: searchText)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        var index = indexPath.section
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.section == 0 ? 0 : indexPath.section - 1
        }
        if batchBtn.isSelected {
            let tmpFile = fileArr[index]
            if tmpFile.isSelected == .yes {
                selectCount -= 1
                tmpFile.isSelected = .no
            } else {
                selectCount += 1
                tmpFile.isSelected = .yes
            }
            refreshUI()
            tableblew.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            
        } else {

            tableblew.deselectRow(at: indexPath, animated: false)
            isNeedReloadData = true
            let fileInfo = fileArr[index]
            if fileInfo.filePath.suffix == "txt" {
                let playVC = CDNewFileViewController()
                playVC.fileInfo = fileInfo
                playVC.folder = folder
                self.navigationController?.pushViewController(playVC, animated: true)
            } else {
                let filePath = fileInfo.filePath.absolutePath
                let url = filePath.pathUrl
                let documentVC = UIDocumentInteractionController(url: url)
                documentVC.name = fileInfo.fileName
                documentVC.delegate = self
                documentVC.presentPreview(animated: true)
            }
        }

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !batchBtn.isSelected
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if CDSignalTon.shared.vipType == .not && indexPath.section == 1 {
            return nil
        }
        
        var index = indexPath.section
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.section == 0 ? 0 : indexPath.section - 1
        }
        
        let tmpFile: CDSafeFileInfo = fileArr[index]
        //
        let delete = UIContextualAction(style: .normal, title: "Delete") { (_, _, _) in
            tmpFile.isSelected = .yes
            self.selectedFileArr = [tmpFile]
            self.toolBarItemClick(type: .delete)
        }
        delete.backgroundColor = UIColor(255, 59, 48)
        let action = UISwipeActionsConfiguration(actions: [delete])
        return action
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let normalLayer = CAShapeLayer()
        let selectLayer = CAShapeLayer()

        let radius = 12.0
        cell.backgroundColor = .clear
        let bounds = cell.bounds.insetBy(dx:16.0, dy:0)
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii:CGSize(width: radius, height: radius))

        normalLayer.path = bezierPath.cgPath
        selectLayer.path = bezierPath.cgPath

        normalLayer.borderColor = UIColor.red.cgColor
        normalLayer.borderWidth = 1
        
        let nomarBgView = UIView(frame: bounds)
        normalLayer.fillColor = UIColor(255, 255, 255).cgColor
        nomarBgView.layer.insertSublayer(normalLayer, at:0)
        nomarBgView.backgroundColor = .clear
        cell.backgroundView = nomarBgView
    
        let selectBgView = UIView(frame: bounds)
        selectLayer.fillColor = UIColor(236, 240, 244).cgColor
        selectBgView.layer.insertSublayer(selectLayer, at:0)
        cell.selectedBackgroundView = selectBgView
        if CDSignalTon.shared.vipType == .not && indexPath.section == 1 {
            normalLayer.borderWidth = 0
            return
        }
        var index = indexPath.section
        if CDSignalTon.shared.vipType == .not {
            index = indexPath.section == 0 ? 0 : indexPath.section - 1
        }
        if batchBtn.isSelected {
            
            let tmpFile = fileArr[index]
            if tmpFile.isSelected == .yes {
                normalLayer.borderWidth = 1.5
                normalLayer.strokeColor = UIColor(red: 0.239, green: 0.541, blue: 0.969, alpha: 1).cgColor
                
            } else {
                normalLayer.borderWidth = 0
            }
        } else {
            normalLayer.borderWidth = 0
        }
    }
    
    func searchRefreshData(_ text: String?) {
        self.coveryView.dismiss()

        guard let text = text,
             !text.isEmpty else {
            searchText = nil
            fileArr = searchDefaultArr
            tableblew.reloadData()
            return
        }
        searchText = text
        let arr = searchDefaultArr.filter { file in
            file.fileName.contains(text)
        }
        fileArr = arr
        tableblew.reloadData()
    }
    
    private func handelSelectedArr() {
        selectedFileArr.removeAll()
        fileArr.forEach { (tmpFile) in
            if tmpFile.isSelected == .yes {
                selectedFileArr.append(tmpFile)
            }
        }
        
    }
    
    func removeUnusedAblum() {
        if folder.folderStatus != .Delete && self.fileArr.count == 0{
            return
        }
        let folderArr = CDSqlManager.shared.queryAllDeleteFolder(folderType: .File)
        folderArr.forEach { folder in
            let isExit = self.fileArr.contains { file in
                file.folderId == folder.folderId
            }
            if !isExit {
                let path = folder.folderPath.absolutePath
                path.delete()
                CDSqlManager.shared.deleteOneFolder(folderId: folder.folderId)
            }
        }
        
    }
    
    private func refreshData() {
        if self.folder.folderStatus == .Delete{
            fileArr = CDSqlManager.shared.queryAllDeleteFile(folderType: .File)
            CDSqlManager.shared.updateAllDeleteFileIsRead(with: .File)

        } else {
            fileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folder.folderId)
        }
        
        searchDefaultArr = fileArr
        tableblew.reloadData()
        self.emptyView.isHidden = !fileArr.isEmpty
        self.tableblew.isHidden = fileArr.isEmpty
    }
    
    func toolBarPop() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            var rect = self.toolbar.frame
            rect.origin.y = CDViewHeight - BottomBarHeight
            self.toolbar.frame = rect
            
            var rect1 = self.tableblew.frame
            rect1.size.height = self.toolbar.minY - rect1.minY
            self.tableblew.frame = rect1
            self.addBtn.minY = self.toolbar.minY - rect1.minY - 48 - 30

        }
    }
    
    func toolBarDismiss() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            var rect = self.toolbar.frame
            rect.origin.y = CDViewHeight
            self.toolbar.frame = rect
            
            var rect1 = self.tableblew.frame
            rect1.size.height = self.toolbar.minY
            self.tableblew.frame = rect1
            self.addBtn.minY = CDViewHeight - 48 - 40

        }
        
    }
    
    override func onAddDataAction() {
        self.addMediaAlert.pop()
    }
    
    @objc func batchBtnClick() {
        banchHandleFiles(isSelected: !batchBtn.isSelected)
    }
    
    private func banchHandleFiles(isSelected: Bool) {
        selectCount = 0
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
            toolBarPop()
            
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
            toolBarDismiss()
            
        }
        fileArr.forEach { (tmpFile) in
            tmpFile.isSelected = .no
        }
        refreshUI()
        tableblew.reloadData()
    }
    
    func refreshUI() {
        if batchBtn.isSelected && fileArr.count > 0 {
            backBtn.setTitle( selectCount ==  fileArr.count ? "Unselect": "Selected All", for: .normal)
        }
        self.deleteItem?.isEnabled = selectCount > 0
        self.moveItem?.isEnabled = selectCount > 0
        self.putBackItem?.isEnabled = selectCount > 0

        backBtn.refreshUI()

    }
    
    @objc func editFolderBtnClick() {
        alert(title: "Rename Folder",placeholder: "Enter a name for a file", filedText: folder.folderName , defaultTitle: "Rename") {[weak self] text in
            guard let self = self else {
                return
            }
            self.backBtn.setTitle(text, for: .normal)
            self.backBtn.refreshUI()
            self.folder.folderName = text
            CDSqlManager.shared.updateOneSafeFolder(with: text, folderId: self.folder.folderId)
        }
    }
    
    @objc func backBtnClick() {
        if batchBtn.isSelected { //
            if self.backBtn.currentTitle == "Selected All" { // 全选
                self.backBtn.setTitle("Unselect", for: .normal)

                fileArr.forEach { (tmpFile) in
                    tmpFile.isSelected = .yes
                }
                selectCount = fileArr.count
            } else {
                backBtn.setTitle("Selected All", for: .normal)

                fileArr.forEach { (tmpFile) in
                    tmpFile.isSelected = .no
                }
                selectCount = 0
            }
            tableblew.reloadData()
            refreshUI()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }


    func addNewNote() {
        isNeedReloadData = true
        let new = CDNewFileViewController()
        new.isAddNew = true
        new.folder = folder
        self.navigationController?.pushViewController(new, animated: true)
    }
    
    func addFromClipboard() {
        if let copiedText = UIPasteboard.general.string {
            
            _ = CDSignalTon.shared.savePlainText(fileName: "Untitled", content: copiedText, folder: folder)
            CDHUDManager.shared.showComplete("Done")
            self.refreshData()
        } else {
            CDHUDManager.shared.showText("There is no text in the clipboard")
        }
    }
    
    func addFromDocument() {
        let flag = CDConfigFile.getIntValueFromConfigWith(key: .libraryFree_docment)
        if CDSignalTon.shared.vipType == .not && flag >= 2{
            
            self.present(self.vipVC, animated: true)
            return
        }
        
        let documentTypes = ["public.text", "com.adobe.pdf", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt", "public.data"]
        super.tmpFolderInfo = folder
        super.docuemntPickerComplete = {[weak self](_ success: Bool) -> Void in
            guard let self = self else {
                return
            }
            if success {
                self.refreshData()
                if CDSignalTon.shared.vipType == .not && flag < 2{
                    CDConfigFile.setIntValueToConfigWith(key: .libraryFree_docment, intValue: flag + 1)
                }
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CDFilesViewController {
    private func toolBarItemClick(type: CDToolBar.CDToolsType) {
        var action = "Delete"
        if type == .putBack {
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
            default:
                break
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func deleteBarItemClick() {
        func delete() {
            CDHUDManager.shared.showWait()
            self.selectedFileArr.forEach { (tmpFile) in
                let defaultPath = tmpFile.filePath.absolutePath
                defaultPath.delete()
                CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.fileId)
            }
            self.refreshData()
            self.banchHandleFiles(isSelected: false)
            CDHUDManager.shared.hideWait()
        }
        if self.folder.folderStatus == .Delete {
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
            self.selectedFileArr.forEach { (tmpFile) in
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .delete, fileId: tmpFile.fileId)
            }
            self.refreshData()
            self.banchHandleFiles(isSelected: false)
            CDHUDManager.shared.hideWait()
            CDHUDManager.shared.showComplete("Done")

        }
        
    }

    private func moveBarItemClick() {
        handelSelectedArr()

        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Move", style: .destructive, handler: {[weak self] (_) in
            guard let self = self else {
                return
            }
            
            let folderList = CDFolderViewController()
            folderList.isMovePicker = true
            folderList.selectedArr = self.selectedFileArr
            folderList.originalFolderId = self.folder.folderId
            folderList.moveHandler = { result in
                if result {
                    self.refreshData()
                    self.banchHandleFiles(isSelected: false)

                }
            }
            self.present(CDNavigationController(rootViewController: folderList), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func putBackItemClick() {
        func putBack() {
            CDHUDManager.shared.showWait()

            selectedFileArr.forEach { (tmpFile) in
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .normal, fileId: tmpFile.fileId)
                let folderInfo = CDSqlManager.shared.queryOneFolderLifeCircle(folderId: tmpFile.folderId)
                if folderInfo == .delete {
                    CDSqlManager.shared.updateOneSafeFolder(with: .normal, folderId: tmpFile.folderId)
                }
            }
            self.refreshData()
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

extension CDFilesViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
}
