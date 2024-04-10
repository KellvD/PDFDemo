//
//  CDMediaPickerViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//

import UIKit
extension CDMediaPickerViewController {
    public typealias CDMoveFilesHandle = (_ folder: CDSafeFolder?) -> Void
}

class CDMediaPickerViewController: CDBaseAllViewController {
    
    private var collectionView: CDAblumView!
    var isMovePicker: Bool = true // true 已有图片移动选择ablum， false 快捷添加选择
    var selectedArr:[CDSafeFileInfo] = []
    var originalFolderId: Int?
    var moveHandle: CDMediaPickerViewController.CDMoveFilesHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView = CDAblumView(frame: CGRect(x: 0, y: 27, width: CDSCREEN_WIDTH, height: self.view.height))
        view.addSubview(collectionView)
                                                   
        collectionView.selectedCellAction = {[weak self] folder, status in
            guard let self = self else {
                return
            }

            self.onSaveDone(folder: folder)
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.customBlack, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.medium(17)
        cancelBtn.addTarget(self, action: #selector(onCancleMove), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        
        navigationItem.title = "Move to"
        
        let batchBtn = UIButton(type: .custom)
        batchBtn.setImage(UIImage(named: "Add Files Folder"), for: .normal)
        batchBtn.addTarget(self, action: #selector(onAddFolderAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn)
        refreshDBData()
    }
     
    func refreshDBData() {
        let folderArr = CDSqlManager.shared.queryDefaultAllMediaExitFolder(folderId: originalFolderId)
        collectionView.ablumArr = folderArr
        collectionView.reloadData()
    }
    
    @objc func onAddFolderAction() {
        let count = CDSqlManager.shared.queryCustomFoldersCount(folderType: .Media)
        if CDSignalTon.shared.vipType != .vip && count >= 3 {
            self.present(self.vipVC, animated: true)
            return
        }
        addFollder(folderType: .Media) {[weak self]folder in
            guard let self = self else {
                return
            }
            self.refreshDBData()
            self.onSaveDone(folder: folder)
        }
    }
    
    @objc func onCancleMove() {
        self.dismiss(animated: true)
    }
    
        
    func onSaveDone(folder: CDSafeFolder) {
        if !isMovePicker {
            self.onCancleMove()
            guard let moveHandle = self.moveHandle else {
                return
            }
            moveHandle(folder)
            return
        }
        CDHUDManager.shared.showWait()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            if folder.folderId > 0 && self.selectedArr.count > 0 {
                for index in 0..<self.selectedArr.count {
                    let file = self.selectedArr[index]
                    CDSignalTon.shared.moveFileToOtherFolder(file: file, moveFolder: folder)
                }
                DispatchQueue.main.async {[weak self] in
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete("Done!")
                    guard let self = self,
                          let moveHandle = self.moveHandle else {
                        return
                    }
                    self.onCancleMove()
                    moveHandle(folder)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    CDHUDManager.shared.hideWait()
                    self.onCancleMove()
                }
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

}
