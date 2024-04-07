//
//  CDCustomView.swift
//  PDF
//
//  Created by dong chang on 2024/3/23.
//

import UIKit

class CDCustomView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {

    var dataArr: [String] =  []
    var actionHandler: ((String)->Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDToolCell", for: indexPath) as! CDToolCell
//        let model = dataArr[indexPath.section][indexPath.item]
//        cell.loadData(tool: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
