//
//  CDTabBarViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/29.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import Photos
//import GoogleMobileAds
//import Lottie
class CDTabBarViewController: UITabBarController {
    
//    lazy var guaideView: CDGuidedPaymentView = {
//        let guaideView = CDGuidedPaymentView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
//        UIDevice.keyWindow().addSubview(guaideView)
//        UIDevice.keyWindow().bringSubviewToFront(guaideView)
//        return guaideView
//    }()

    private var stackview: UIStackView!
    private var myBar :UIView!
    private var lastSelectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        self.tabBar.frame = .zero
        let height = UIDevice.safeAreaBottom() == 0 ? 64 : BottomBarHeight
        myBar = UIView(frame: CGRect(x: 0, y: self.view.height - height, width: CDSCREEN_WIDTH, height: height))
        myBar.backgroundColor = .white
        view.addSubview(myBar)
        view.bringSubviewToFront(myBar)
        stackview = UIStackView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: myBar.height))
        stackview.distribution = .fillEqually
        stackview.alignment = .fill
        myBar.addSubview(stackview)
        
        addChildViewControll(vc: CDHomeViewController(), imageName: "tabbar_files", selectImageName: "tabbar_files_selected", title: "Files")
        
        addChildViewControll(vc: CDCameraViewController(), imageName: "Tab4-Normal", selectImageName: "Tab4-Select", title: nil)

        addChildViewControll(vc: CDToolsViewController(), imageName: "tabbar_tools", selectImageName: "tabbar_tools_selected", title: "Tools")

        if let button = stackview.arrangedSubviews.first as? UIButton {
            button.isSelected = true
        }
    }
    
    
    private func addChildViewControll(vc: UIViewController, imageName: String, selectImageName: String, title: String?){
        let button = UIButton(type: .custom)
        button.size = CGSize(width: 48, height: 48)
        button.setImage(imageName.image, for: .normal)
        button.setImage(selectImageName.image, for: .selected)
        button.setImage(imageName.image, for: .normal)
        button.setImage(selectImageName.image, for: .selected)
        if title != nil {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.black, for: .highlighted)
            button.setTitleColor(.gray, for: .selected)
            button.setTitleColor(.gray, for: .highlighted)

            button.titleLabel?.font = .medium(12)
            var configuration = UIButton.Configuration.plain()
            configuration.imagePlacement = .top
            configuration.imagePadding = 4
            
            button.configuration = configuration
        }

        button.tag = stackview.arrangedSubviews.count
        button.addTarget(target, action: #selector(buttonAction), for: .touchUpInside)
        let naVC = CDNavigationController(rootViewController: vc)
        stackview.addArrangedSubview(button)
        addChild(naVC)
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        set {
            myBar.isHidden = newValue
            if !newValue {
                self.tabBar.isHidden = true
                self.tabBar.frame = .zero
            }
        }
        get {
            return myBar.isHidden
        }
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        for i in 0..<stackview.arrangedSubviews.count {
            let button = stackview.arrangedSubviews[i] as! UIButton
            button.isSelected = false
        }
        
        sender.isSelected = true
        lastSelectIndex = sender.tag
        self.selectedIndex = sender.tag
    }

}
