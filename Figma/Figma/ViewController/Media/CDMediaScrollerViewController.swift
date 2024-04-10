//
//  CDMediaScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import MediaPlayer

class CDMediaScrollerViewController: CDBaseAllViewController {
    public var fileArr: [CDSafeFileInfo] = []
    public var currentIndex: Int!
    public var folder: CDSafeFolder!
    
    private var collectionView: UICollectionView!
    private var isHiddenBottom: Bool = false
    private var likeItem: UIButton?
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCurrentPlayCell()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHiddenBottom
    }
    
    lazy var toolBar: CDToolBar = {
        var barType:[CDToolBar.CDToolsType] = []
        if folder.folderStatus == .Favourite {
            barType = [.delete, .like]
        }else if folder.folderStatus == .Delete {
            barType = [.delete, .putBack]
        } else {
            barType = [.delete, .like, .move]
        }
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: barType) { [weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .delete:
                self.deleteBarItemClick()
            case .like:
                self.loveItemClick()
            case .move:
                self.moveItemClick()
            case .putBack:
                self.putBackItemClick()
            default:
                break
            }
        }
        toolbar.screenHeight = CDViewHeight
        self.likeItem = toolbar.viewWithTag(CDToolBar.CDToolsType.like.rawValue) as? UIButton
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.toolBar)
        view.bringSubviewToFront(self.toolBar)
        self.view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: self.toolBar.minY), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(CDVideoScrollerCell.self, forCellWithReuseIdentifier: "CDVideoScrollerCell")
        collectionView.register(CDImageScrollerCell.self, forCellWithReuseIdentifier: "CDImageScrollerCell")

        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage("back".image, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        cancelBtn.setTitle(folder.folderName, for: .normal)
        cancelBtn.setTitleColor(.customBlack, for: .normal)
        cancelBtn.titleLabel?.font = .medium(18)
        
//        let videoTap = UITapGestureRecognizer(target: self, action: #selector(onBarsHiddenOrNot))
//        self.view.addGestureRecognizer(videoTap)
        
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.isPagingEnabled = true

        let fileInfo = fileArr[currentIndex]
        self.likeItem?.setImage(fileInfo.grade == .lovely ? "heart".image : "Like_tool".image, for: .normal)


    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.currentIndex == 0
    }
    
    @objc func onBarsHiddenOrNot() {
        self.isHiddenBottom = !self.isHiddenBottom
        UIView.animate(withDuration: 0.25) {
            self.toolBar.minY = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - BottomBarHeight)
            self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)
        }
    }

    @objc func cancelBtnClick (){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func putBackItemClick() {
        let fileInfo = fileArr[currentIndex]
        func putBack() {
            CDHUDManager.shared.showWait()
            CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .normal, fileId: fileInfo.fileId)
            fileArr.remove(at: currentIndex)
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {
                    return
                }
                CDHUDManager.shared.hideWait()
                if self.fileArr.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.collectionView.reloadData()
                }
            }
        }

        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Put Back", style: .destructive, handler: { (_) in
            if CDSignalTon.shared.vipType == .not {
                self.guidedPayment {
                    putBack()
                }
            }else {
                putBack()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }

    // MARK: 收藏
    @objc func loveItemClick() {
        let fileInfo = fileArr[currentIndex]

        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            self.likeItem?.setImage("heart".image, for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(with: .lovely, fileId: fileInfo.fileId)
        } else {
            fileInfo.grade = .normal
            self.likeItem?.setImage("Like_tool".image, for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(with: .normal, fileId: fileInfo.fileId)
        }

        self.fileArr[currentIndex] = fileInfo
    }

    func moveItemClick() {
        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Move", style: .destructive, handler: {[weak self] (_) in
            guard let self = self else {
                return
            }
            let fileInfo = self.fileArr[self.currentIndex]
            let vc = CDMediaPickerViewController()
            vc.selectedArr = [fileInfo]
            vc.originalFolderId = self.folder.folderId
            vc.moveHandle = { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.fileArr.remove(at: self.currentIndex)
                if self.fileArr.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.collectionView.reloadData()
                }

            }
            self.present(CDNavigationController(rootViewController: vc), animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
        
        
    }
    
    // MARK: 删除
    @objc func deleteBarItemClick() {
        let fileInfo = fileArr[currentIndex]
 
        func deleteTheSelectImage() {
            func delete() {
                CDHUDManager.shared.showWait()
                let thumbPath = fileInfo.thumbImagePath.absolutePath
                thumbPath.delete()
                let defaultPath = fileInfo.filePath.absolutePath
                defaultPath.delete()
                CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)
                
            }
            
            func updateData() {
                fileArr.remove(at: currentIndex)
                
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {
                        return
                    }
                    CDHUDManager.shared.hideWait()
                    if self.fileArr.isEmpty {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.collectionView.reloadData()
                    }
                }
            }
            
            if folder.folderStatus == .Delete {
                if CDSignalTon.shared.vipType == .not {
                    
                    guidedPayment {
                        delete()
                        updateData()
                    }
                }else {
                    delete()
                    updateData()

                }
                
            } else {
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .delete, fileId: fileInfo.fileId)
                updateData()

            }
        }

        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            deleteTheSelectImage()

        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }

    @objc func shareBarItemClick() {
        if fileArr.isEmpty {
            return
        }
        let fileInfo = fileArr[currentIndex]
        let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
        let url = defaultPath.pathUrl
        presentShareActivityWith(dataArr: [url as NSObject]) { (_) in}
    }
    
    func stopCurrentPlayCell() {
        if fileArr.isEmpty {
            return
        }
        
        let fileInfo = fileArr[currentIndex]
        if fileInfo.fileType == .VideoType {
            let indexPath = IndexPath(item: self.currentIndex, section: 0)
            guard let cell: CDVideoScrollerCell = self.collectionView.cellForItem(at: indexPath) as? CDVideoScrollerCell else {
                return
            }
            cell.stopPlayer()
        }
    }
}

extension CDMediaScrollerViewController: UICollectionViewDelegate,
                                        UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fileInfo = fileArr[indexPath.item]
        if fileInfo.fileType == .VideoType {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDVideoScrollerCell", for: indexPath) as! CDVideoScrollerCell
            cell.loadData(fileInfo)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDImageScrollerCell", for: indexPath) as! CDImageScrollerCell
            cell.setScrollerImageData(fileInfo: fileInfo)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let firstIndexPath = collectionView.indexPathsForVisibleItems.first else {
            return
        }
        if fileArr.count > 0 {
            let page = firstIndexPath.item
            if page < fileArr.count {
               
                currentIndex = page
            } else {
                currentIndex = fileArr.count - 1
            }
            let fileinfo = fileArr[currentIndex]
            self.likeItem?.setImage(fileinfo.grade == .lovely ? "heart".image : "Like_tool".image, for: .normal)
        }

    }
}
