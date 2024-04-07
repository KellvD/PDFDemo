//
//  CDNewFolderView.swift
//  PDF
//
//  Created by dong chang on 2024/3/19.
//

import UIKit

class CDNewFolderAlert: UIView {
    var actionHandler: ((String)->Void)?

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
        
        
        let nib = UINib(nibName: "CDNewFolderNib", bundle: nil)
        let newView = nib.instantiate(withOwner: self, options: nil).first as! CDNewFolderNib

        newView.frame = CGRect(x: 16, y: (CDSCREEN_HEIGTH - 224)/2.0, width: frame.width - 32, height: 224)
        newView.layer.cornerRadius = 24
    
        self.addSubview(newView)
        newView.actionHandler = { [weak self] text in
            guard let self = self else {
                return
            }
            
            guard let text = text else {
                self.dismiss()
                return
            }
            guard let actionHandler = self.actionHandler else {
                return
            }
            self.dismiss()
            actionHandler(text)
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
            }) { (_) in}
        }
    }
    
    @objc func dismiss() {
        self.isHidden = true
        self.minY = self.height
    }
     
    
}

class CDNewFolderNib: UIView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputFiled: UITextField!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    var actionHandler: ((String?)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
        titleLabel.font = .helvBold(24)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        inputFiled.leftView = leftView
        inputFiled.leftViewMode = .always
        inputFiled.layer.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1).cgColor
        inputFiled.layer.cornerRadius = 24
        inputFiled.layer.borderWidth = 1
        inputFiled.layer.borderColor = UIColor(red: 0.754, green: 0.787, blue: 0.864, alpha: 1).cgColor
        
        cancelBtn.layer.backgroundColor = UIColor(red: 0.918, green: 0.918, blue: 0.945, alpha: 1).cgColor
        cancelBtn.layer.cornerRadius = 28
        cancelBtn.setTitleColor(UIColor(red: 0.498, green: 0.537, blue: 0.631, alpha: 1), for: .normal)
        cancelBtn.titleLabel?.font = .helvBold(16)
        
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = .helvBold(16)
        confirmBtn.layer.backgroundColor = UIColor(red: 0.255, green: 0.443, blue: 1, alpha: 1).cgColor
        confirmBtn.layer.cornerRadius = 28
        bgView.layer.cornerRadius = 24

    }
    
    @IBAction func onCancelAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(nil)
    }
    
    @IBAction func onConfirmAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(inputFiled.text)
    }
    
}

