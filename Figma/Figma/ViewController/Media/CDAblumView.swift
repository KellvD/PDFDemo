//
//  CDAblumView.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//

import UIKit


class CDAblumView: UICollectionView,
                   UICollectionViewDelegate,
                   UICollectionViewDataSource {
    enum SelectCellStatus: Int {
        case delete
        case select
    }
    var ablumArr: [CDSafeFolder] = []
    var selectedCellAction: ((CDSafeFolder, SelectCellStatus) -> Void)?
    private var isBatchEdit = false

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        let width = (CDSCREEN_WIDTH - 16 * 2 - 4)/2
        layout.itemSize = CGSize(width: width, height: width + 32)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .vertical
        super.init(frame: frame, collectionViewLayout: layout)
        

        self.register(UINib(nibName: "CDAlbumCell", bundle: nil), forCellWithReuseIdentifier: "CDAlbumCell")

        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.white

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ablumArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDAlbumCell", for: indexPath) as! CDAlbumCell
        let folder = ablumArr[indexPath.item]
        cell.loadData(folder: folder)
        
       if folder.folderStatus == .Custom {
            cell.longTapHandler = { [weak self] in
                guard let self = self,
                      let selectedCellAction = self.selectedCellAction else {
                    return
                }
                selectedCellAction(self.ablumArr[indexPath.item], .delete)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let folder = ablumArr[indexPath.item]
        guard let selectedCellAction = selectedCellAction else {
            return
        }
        selectedCellAction(folder, .select)
    }
}
