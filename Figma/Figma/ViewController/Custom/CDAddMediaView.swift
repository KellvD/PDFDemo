//
//  CDAddMediaView.swift
//  Figma
//
//  Created by dong chang on 2024/1/17.
//

import UIKit

class CDAddMediaView: UIView {
    
    enum CDSelfType: Int {
        case media = 0
        case file = 1
        case tab = 2
    }
    
    private var actionHandler: ((Int) -> Void)?
    private var titleArr = ["Add media from", "Add a Note",""]
    private var actionTitleArr =  [["Take\nCamera","Take\nPhotos","From\nFile"],
                                   ["Add\n New Note","From\nClipboard","From \nFile"],
                                   ["Hide \nPhoto","Multi \nWebsites"]]
    private var actionImageArr = [["camera","Photos","Files"],["document-text","clip","Files"],["Hide Photo","Multi Websites"]]
    init(selfType: CDSelfType, actionHandler:@escaping ((Int) -> Void)) {
        super.init(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        self.actionHandler = actionHandler
        let backGroundView = UIView(frame: frame)
        backGroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backGroundView.addGestureRecognizer(tap)
        backGroundView.alpha = 0.3
        addSubview(backGroundView)
        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)
        
        
        let bgView = UIView()
        bgView.backgroundColor = selfType == .tab ? UIColor(17, 17, 18): .baseBgColor
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(selfType == .tab ? 166 : 184)
        }
        
        let tipView = UIView()
        tipView.backgroundColor = .lightGray
        bgView.addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(3)
            make.top.equalTo(5)
            make.centerX.equalToSuperview()
        }
        if selfType != .tab {
            let titleLabel = UILabel()
            titleLabel.textColor = .customBlack
            titleLabel.font = UIFont.medium(18)
            titleLabel.text = titleArr[selfType.rawValue]
            bgView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.top.equalTo(tipView.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
            }
        }
    
        let titleTmps = actionTitleArr[selfType.rawValue]
        let imageTmps = actionImageArr[selfType.rawValue]
        let space = selfType == .tab ? (CDSCREEN_WIDTH - 100 * 2)/3.0 : 20
        let width = selfType == .tab ? 100: (CDSCREEN_WIDTH - 20 * 4)/3.0
        let minY = selfType == .tab ? 27.0 : 56.0
        let height = selfType == .tab ? 100.0 : 84.0
        for i in 0..<titleTmps.count {
            let itemBg = UIButton(type: .custom)
            itemBg.tag = i
            let minx = (width + space) * CGFloat(i) + space
            itemBg.frame = CGRect(x: minx, y: minY, width: width, height: height)
            itemBg.backgroundColor = selfType == .tab ? UIColor(17, 17, 18) : .white
            itemBg.addRadius(corners: .allCorners, size: CGSize(width: 12, height: 12))
            bgView.addSubview(itemBg)
            itemBg.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

            
            let imgV = UIImageView(frame: CGRect(x: 10, y: 10, width: itemBg.width - 20, height: itemBg.height - 54))
            imgV.image = imageTmps[i].image
            imgV.contentMode = .scaleAspectFit

            let titleLabel = UILabel(frame: CGRect(x: 10, y: itemBg.height - 40, width: itemBg.width-20, height: 40))
            titleLabel.font = UIFont.medium(12)
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center
            titleLabel.text = titleTmps[i]
            if selfType == .tab {
                titleLabel.textColor = .white
            }else {
                titleLabel.textColor = .customBlack
            }
            itemBg.addSubview(imgV)
            itemBg.addSubview(titleLabel)

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pop() {
        var rect = self.frame
        rect.origin.y = 0
        self.frame = rect
    }
    
    @objc func dismiss() {
        var rect = self.frame
        rect.origin.y = CDSCREEN_HEIGTH
        self.frame = rect
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        dismiss()
        guard let actionBlock = actionHandler else {
            return
        }
        
        actionBlock(sender.tag)
    }
    
}
