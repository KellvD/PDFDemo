//
//  CDVideoScrollerCell.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDVideoScrollerCell: UICollectionViewCell {

    lazy var imageScroller: CDImageScrollView = {
        let ss = CDImageScrollView(frame: self.bounds)
        self.contentView.addSubview(ss)
        return ss
    }()
    
    lazy var videoScroller: CDVideoPlayerView = {
        let ss = CDVideoPlayerView(frame: self.bounds)
        self.contentView.addSubview(ss)
        return ss
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }

    func loadData(_ fileInfo: CDSafeFileInfo) {
        if fileInfo.fileType == .ImageType {
            setScrollerImageData(fileInfo: fileInfo)
        } else {
            self.videoScroller.thumbimagePath = fileInfo.thumbImagePath.absolutePath
            self.videoScroller.videoPath = fileInfo.filePath.absolutePath
            
        }
        
    }

    func stopPlayer() {
        self.videoScroller.dellocPlayer()
    }

    func setScrollerImageData(fileInfo: CDSafeFileInfo) {
        DispatchQueue.global().async {
            let tmpPath = fileInfo.filePath.absolutePath
            let tmpImage = UIImage(contentsOfFile: tmpPath)
            let tmpData = NSData(contentsOfFile: tmpPath)
            DispatchQueue.main.async(execute: {
                self.imageScroller.loadImageView(image: tmpImage!, gifData: tmpData!)
            })
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
