//
//  CDFilesViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/19.
//

import UIKit

class CDFilesViewController: CDBaseAllViewController,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout  {

    private var collectionView: UICollectionView!
    private var isNeedReloadData: Bool = false
    private var dataArr: [CDSafeFileInfo] = []

    private var bannderIndx = 3
    public var isSearch = false
    public var superId = ROOTSUPERID
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isNeedReloadData {
            isNeedReloadData = false
            refreshDBData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        view.backgroundColor = UIColor(234, 234, 234)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDHomeTableCell", bundle: nil), forCellWithReuseIdentifier: "CDHomeTableCell")
        
        collectionView.register(CDHomeImportHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CDHomeImportHeader")
        collectionView.register(CDBannerAdsFooterView.self, forCellWithReuseIdentifier: "CDBannerAdsFooterView")


        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(234, 234, 234)
        view.addSubview(collectionView)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: "app_back".image, style: .plain, target: self, action: #selector(onBackAction))
    }
    
    @objc func onBackAction() {
        if isSearch {
            self.dismiss(animated: true)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func refreshDBData() {
        dataArr = CDSqlManager.shared.queryAllFileFromFolder(superId: ROOTSUPERID)
        for _ in 0..<8 {
            let file = CDSafeFileInfo()
            dataArr.append(file)
        }
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if CDSignalTon.shared.vipType == .not && dataArr.count >= bannderIndx {
            return dataArr.count + 1
        }
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: CDSCREEN_WIDTH - 16 * 2, height: 64)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  CDSignalTon.shared.vipType == .not && indexPath.item == 3 {
            return CGSize(width: CDSCREEN_WIDTH - 16 * 2, height: 84)
        }
        
        return CGSizeMake(CDSCREEN_WIDTH - 16 * 2, 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if CDSignalTon.shared.vipType == .not && indexPath.item == 3 {
            
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
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CDHomeImportHeader", for: indexPath) as! CDHomeImportHeader
        headerView.enable = true
        headerView.actionHandler = {[weak self] text in
            guard let self = self,
            let text = text else {
                return
            }
            self.onSearchAction(text)
            
        }
        return headerView
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
    
    func onSearchAction(_ text: String) {
        
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
