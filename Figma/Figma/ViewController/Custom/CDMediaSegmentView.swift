//
//  CDMediaSegmentView.swift
//  Figma
//
//  Created by dong chang on 2024/2/4.
//

import UIKit

class CDMediaSegmentView: UIView {

    private var videoBtn = UIButton(type: .custom)
    private var photoBtn = UIButton(type: .custom)

    public var onClickHandler: ((CDSafeFileInfo.NSFileType) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        photoBtn.setImage("photo_select".image, for: .selected)
        photoBtn.setImage("photo_normal".image, for: .normal)
        photoBtn.setTitle("Photo", for: .normal)
        photoBtn.setTitleColor(.white, for: .selected)
        photoBtn.setTitleColor(UIColor(187, 189, 195), for: .normal)
        photoBtn.tag = 0
        var con = UIButton.Configuration.plain()
        con.imagePlacement = .leading
        con.imagePadding = 6
        photoBtn.configuration = con
        photoBtn.tintColor = .clear
        photoBtn.titleLabel?.font = .medium(16)
        photoBtn.addTarget(self, action: #selector(onMediaClick), for: .touchUpInside)

        self.addSubview(photoBtn)
        photoBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(105)
            make.height.equalTo(40)
        }
        photoBtn.layer.cornerRadius = 20
        
        
        videoBtn.setImage("video_select".image, for: .selected)
        videoBtn.setImage("video_normal".image, for: .normal)
        videoBtn.setTitle("Videos", for: .normal)
        videoBtn.configuration?.imagePadding = 6

        videoBtn.setTitleColor(.white, for: .selected)
        videoBtn.setTitleColor(UIColor(187, 189, 195), for: .normal)
        videoBtn.tag = 1
        videoBtn.configuration = con
        videoBtn.tintColor = .clear

        videoBtn.titleLabel?.font = .medium(16)
        videoBtn.addTarget(self, action: #selector(onMediaClick), for: .touchUpInside)
        self.addSubview(videoBtn)
        videoBtn.snp.makeConstraints { make in
            make.left.equalTo(photoBtn.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(105)
            make.height.equalTo(40)
        }
        videoBtn.layer.cornerRadius = 20
        onMediaClick(send: photoBtn)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func onMediaClick(send: UIButton) {
        if send.tag == 0 {
            photoBtn.isSelected = true
            photoBtn.backgroundColor = .customBlack

            videoBtn.isSelected = false
            videoBtn.backgroundColor = UIColor(246, 246, 247)
        } else {
            photoBtn.isSelected = false
            videoBtn.backgroundColor = .customBlack

            videoBtn.isSelected = true
            photoBtn.backgroundColor = UIColor(246, 246, 247)
        }
        
        guard let onClickHandler = onClickHandler else {
            return
        }
        onClickHandler(send.tag == 0 ?.ImageType : .VideoType)
    }
    
}
