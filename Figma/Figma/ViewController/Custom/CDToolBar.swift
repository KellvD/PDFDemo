//
//  CDToolBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDToolBar: UIView{
    enum CDToolsType: Int {
        case delete = 100
        case like
        case move
        case putBack
        case share
        case edit_img
        
        case edit
        case done
        case close
        case manager
        case lastStep
        case nextStep
        case search
        case addBg
        case add
    }

    let textarr = ["Delete","Like","Move","Put Back","Share","Edit",
                   "Edit","Done","Close Table","",
                   "Last_tool","Next_tool","search_tool","addbg_tool","add_tool"]
    var managerItem:UILabel!
    var closeTabItem:UIButton!
    var editItem:UIButton!
    var deleteItem:UIButton!
    
    var normalArr: [UIButton] = []
    var screenHeight = CDSCREEN_HEIGTH
    var actionHandler: ((CDToolsType)->Void)?
    init(frame: CGRect, barType: [CDToolsType], actionHandler: @escaping ((CDToolsType)->Void)) {
        super.init(frame: frame)
        backgroundColor = .white
        normalArr = []
        self.actionHandler = actionHandler

        barType.forEach { type in
            switch type {
                
            //image+text
            case .delete,.like,.move,.putBack,.share,.edit_img:
                let text = textarr[type.rawValue-100]
                let item = createButton(title:text, imageName: "\(text)_tool")
                item.tag = type.rawValue
                normalArr.append(item)
            //text
            case .edit,.done,.close:
                let text = textarr[type.rawValue-100]
                let item = createButton(title: text, imageName: nil)
                item.tag = type.rawValue
                normalArr.append(item)
                if type == .close {
                    closeTabItem = item
                    closeTabItem.titleLabel?.font = UIFont.medium(18)

                } else if type == .edit {
                    editItem = item
                    editItem.contentHorizontalAlignment = .left
                } else if type == .done {
                    item.contentHorizontalAlignment = .right

                }
            case .manager:
                let item = createButton(title: nil, imageName: nil)
                item.tag = type.rawValue
                normalArr.append(item)
            //image
            case .lastStep,.nextStep,.search,.add,.addBg:
                let text = textarr[type.rawValue-100]
                let item = createButton(title: nil, imageName: text)
                item.tag = type.rawValue
                normalArr.append(item)
            }
        }

        let maxX = CDSCREEN_WIDTH / CGFloat(normalArr.count)
        for i in 0..<barType.count {
            let btn = normalArr[i]
            btn.frame = CGRect(x: maxX * CGFloat(i + 1) - maxX / 2.0 - 50, y: 9, width: 100, height: 44)
            let type = CDToolsType(rawValue: btn.tag)
            switch type {
            case .edit:
                btn.minX = 16
            case .done:
                btn.maxX = self.width - 16
            case .manager:
                managerLabe()
                btn.addSubview(managerItem)
                managerItem.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.greaterThanOrEqualTo(20)
                }
            case .addBg:
                
                btn.width = 44
                btn.midX = CDSCREEN_WIDTH/2.0
                btn.backgroundColor = .customBlack
                btn.layer.cornerRadius = 22
            default:
                break
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func managerLabe() {
        managerItem = UILabel()
        managerItem.text = "0"
        managerItem.font = UIFont.regular(12)
        managerItem.textColor = .customBlack
        managerItem.textAlignment = .center
        managerItem.layer.cornerRadius = 5
        managerItem.layer.borderColor = UIColor.customBlack.cgColor
        managerItem.layer.borderWidth = 1.5
    }
    func createButton(title:String?, imageName: String?) -> UIButton {
   
        
        let button = UIButton(type: .custom)
        if title != nil {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.customBlack, for: .normal)
            button.setTitleColor(.customBlack, for: .highlighted)
            button.setTitleColor(UIColor(191, 197, 206), for: .disabled)
            button.titleLabel?.font = UIFont.regular(14)
        }
        
        if imageName != nil {
            var configuration = UIButton.Configuration.plain()
            configuration.imagePlacement = .top
            configuration.imagePadding = 4
            button.setImage(UIImage(named: imageName!), for: .normal)
            button.configuration = configuration
        }
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(button)
        return button
    }

    
    @objc func buttonAction(_ sender: UIButton) {
        guard let actionHandler = actionHandler else {
            assertionFailure("actionHandler is nil")
            return
        }
        actionHandler(CDToolsType(rawValue: sender.tag)!)
    }
    
    
    func pop() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            var rect = self.frame
            rect.origin.y = self.screenHeight - BottomBarHeight
            self.frame = rect
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else {
                return
            }
            var rect = self.frame
            rect.origin.y = self.screenHeight
            self.frame = rect
        }

    }
}
