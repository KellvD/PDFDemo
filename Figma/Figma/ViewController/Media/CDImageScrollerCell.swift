//
//  CDImageCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
class CDImageScrollerCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scroller: CDImageScrollView = {
        let ss = CDImageScrollView(frame: self.bounds)
        self.contentView.addSubview(ss)
        return ss
    }()

    func setScrollerImageData(fileInfo: CDSafeFileInfo) {
        DispatchQueue.global().async {
            let tmpPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            let tmpImage = UIImage(contentsOfFile: tmpPath)
            let tmpData = NSData(contentsOfFile: tmpPath)
            DispatchQueue.main.async(execute: {
                self.scroller.loadImageView(image: tmpImage!, gifData: tmpData!)
            })

        }

    }

    func setImageData(fileInfo: CDSafeFileInfo) {
       
    }
}
