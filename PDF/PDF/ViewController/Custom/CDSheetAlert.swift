//
//  CDSheetAlert.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit
enum SheetItem: Int {
    case exportPdf
    case exportImages
    case exportLongPicture
    case saveAlbum
    case rename
    case move
    case copy
    case delete
    case timeNewOld
    case timeOldNew
    case fileBigsmall
    case filesmallBig
}

class CDSheetAlert: UIView {
    var actionHandler: ((SheetItem)->Void)?
    private var items: [SheetItem] = []
    private let itemTexts = ["Export as PDF","Export as image(s)","Export as a long picture",
                    "Save To Album","Rename","Move","Copy File","Delete",
                    "Time: New-Old","Time: Old-New","File: Big-Small","File: Small-Big"]

    init(items: [SheetItem]) {
        super.init(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        self.items = items
        let backGroundView = UIView(frame: frame)
        backGroundView.alpha = 0.6
        addSubview(backGroundView)
        
        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)
        UIDevice.keyWindow().addSubview(self)
        UIDevice.keyWindow().bringSubviewToFront(self)
        
        let closeBtn = UIButton(frame: CGRect(x: CDSCREEN_WIDTH/2.0 - 16, y: CDSCREEN_HEIGTH - 32 - 32, width: 32, height: 32),imageNormal: "purchase_close", target: self, function: #selector(dismiss), supView: self)
        
        closeBtn.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        closeBtn.layer.cornerRadius = 16
        
        let space: CGFloat = 1.5
        let radius: CGFloat = 24
        let height = items.count * 56 + (items.count - 1) * Int(space)
        let stackview = UIStackView(frame: CGRect(x: 16, y: Int(closeBtn.minY) - height - 12, width: Int(CDSCREEN_WIDTH) - 32, height: height))
        stackview.axis = .vertical
        stackview.spacing = space
        stackview.distribution = .fillEqually // 子视图等分布局

        self.addSubview(stackview)
        stackview.backgroundColor = UIColor(234, 237, 244)
        stackview.layer.cornerRadius = radius
        
        for i in 0..<items.count {
            let item = items[i]
            let button = UIButton(text: itemTexts[item.rawValue], target: self, function: #selector(onSheetAction))
            button.size = CGSize(width: stackview.width, height: 56)
            if item == .delete {
                button.setTitleColor(UIColor(red: 1, green: 0.312, blue: 0.25, alpha: 1), for: .normal)
            }else {
                button.setTitleColor(UIColor(red: 0.255, green: 0.443, blue: 1, alpha: 1), for: .normal)
            }
            button.titleLabel?.font = .helvBold(16)
            button.backgroundColor = .white
            button.tag = item.rawValue + 100
            if i == 0 {
                button.addRadius(corners: [.topLeft,.topRight], size: CGSize(width: radius, height: radius))
            } else if i == items.count - 1 {
                button.addRadius(corners: [.bottomRight,.bottomLeft], size: CGSize(width: radius, height: radius))
            }else {
                button.addRadius(corners: .allCorners, size: CGSize(width: 0, height: 0))
            }
            stackview.addArrangedSubview(button)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSheetAction(sender: UIButton) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(SheetItem(rawValue: sender.tag - 100)!)
    }
    
    
    func show() {
        DispatchQueue.main.async {
            self.isHidden = false

            UIView.animate(withDuration: 0.25, animations: {
                self.minY = 0
            }) { (_) in}
        }
    }
    
    @objc func dismiss() {
        self.isHidden = true
        self.minY = self.height
    }
    
    func refresh(items: [SheetItem]) {
        self.items = items
        
    }
}
