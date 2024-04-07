//
//  CDRateAlert.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit

class CDRateAlert: UIView {
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
        
        let nib = UINib(nibName: "CDRateAlertNib", bundle: nil)
        let newView = nib.instantiate(withOwner: self, options: nil).first as! CDRateAlertNib

        newView.frame = CGRect(x: 16, y: (CDSCREEN_HEIGTH - 158)/2.0, width: frame.width - 32, height: 158)
        newView.layer.cornerRadius = 24
    
        self.addSubview(newView)
        newView.actionHandler = { [weak self] flag in
            guard let self = self else {
                return
            }
            
            if flag == 0 {
                self.dismiss()
            } else {
                guard let actionHandler = self.actionHandler else {
                    return
                }
                self.dismiss()
                actionHandler()
            }
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


class CDRateAlertNib: UIView {


    @IBOutlet weak var titlleLabel: UILabel!
    
    @IBOutlet weak var badBtn: UIButton!
    
    @IBOutlet weak var goodBtn: UIButton!
    var actionHandler: ((Int)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titlleLabel.textColor = .black
        titlleLabel.font = .regular(16)
        
        badBtn.layer.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1).cgColor
        badBtn.layer.cornerRadius = 28
        badBtn.setTitleColor(.black, for: .normal)
        badBtn.titleLabel?.font = .helvBold(16)
        
        
        goodBtn.layer.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1).cgColor
        goodBtn.layer.cornerRadius = 28
        goodBtn.setTitleColor(.black, for: .normal)
        goodBtn.titleLabel?.font = .helvBold(16)
    }
    
    @IBAction func onBadAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(0)
    }
    
    @IBAction func onGoodAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(1)
    }
    
}
