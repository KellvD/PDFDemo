//
//  CDThankAlert.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit

class CDThankAlert: UIView {

    var actionHandler: (()->Void)?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        
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
        
        
        let nib = UINib(nibName: "CDThankAlertNib", bundle: nil)
        let newView = nib.instantiate(withOwner: self, options: nil).first as! CDThankAlertNib

        newView.frame = CGRect(x: 16, y: (CDSCREEN_HEIGTH - 259)/2.0, width: frame.width - 32, height: 259)
        newView.layer.cornerRadius = 24
    
        self.addSubview(newView)
        newView.actionHandler = { [weak self] in
            guard let self = self,
            let actionHandler = self.actionHandler else {
                return
            }
            self.dismiss()
            actionHandler()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        DispatchQueue.main.async {
            self.isHidden = false

            UIView.animate(withDuration: 0.25, animations: {
                self.minY = 0
            })
        }
    }
    
    @objc func dismiss() {
        self.isHidden = true
        self.minY = self.height
    }

}

class CDThankAlertNib: UIView {

   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var okBtn: UIButton!
    
    var actionHandler: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
        titleLabel.font = .helvBold(16)
        
        okBtn.layer.backgroundColor = UIColor(red: 0.255, green: 0.443, blue: 1, alpha: 1).cgColor
        okBtn.layer.cornerRadius = 28
        okBtn.setTitleColor(.white, for: .normal)
        okBtn.titleLabel?.font = .helvBold(16)
    }
    
    @IBAction func onOkAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler()
    }
    
    
}
