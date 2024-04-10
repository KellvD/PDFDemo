//
//  CDCoveryView.swift
//  Figma
//
//  Created by dong chang on 2024/1/20.
//

import UIKit

class CDCoveryView: UIView {


    var dismissHandler: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let backGroundView = UIView(frame: self.bounds)
        backGroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSpaceView))
        backGroundView.addGestureRecognizer(tap)
        backGroundView.alpha = 0.2
        insertSubview(backGroundView, at: 0)

        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pop() {
        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden = false
        })
    }
    
    @objc func tapSpaceView() {
        guard let dismissHandler = dismissHandler else {
            return
        }
        dismissHandler()
    }
    
    func dismiss() {

        UIView.animate(withDuration: 0.25, animations: {
            self.isHidden = true

        })
    }
}
