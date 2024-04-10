//
//  CDMineHeaderCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDMineHeaderCell: UITableViewCell {
    enum MineHeadActionType {
        case upgrade
        case passcode
        case faceid
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passcodeItem: UIView!
    @IBOutlet weak var faceIdItem: UIView!
    
    @IBOutlet weak var primiumBgView: UIImageView!
    @IBOutlet weak var faceIdLabel: UILabel!
    @IBOutlet weak var passcodeLabel: UILabel!
    
    @IBOutlet weak var passBgView: UIView!
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var faceBgView: UIView!
    @IBOutlet weak var passcodeSwi: UISwitch!
    
    @IBOutlet weak var faceSwi: UISwitch!
    var actionHandler:( (MineHeadActionType) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .baseBgColor
        self.titleLabel.textColor = .customBlack
        self.titleLabel.font = UIFont.medium(16)

        self.passcodeLabel.textColor = .customBlack
        self.passcodeLabel.font = UIFont.medium(16)
        
        self.faceIdLabel.textColor = .customBlack
        self.faceIdLabel.font = UIFont.medium(16)
        
        self.passcodeItem.layer.cornerRadius = 12
        self.faceIdItem.layer.cornerRadius = 12
        self.iconView.layer.cornerRadius = 18
        
        passBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passcodeClick)))
        faceBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(faceClick)))
        
        primiumBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeAction)))
        
        passcodeSwi.onTintColor = UIColor(61, 138, 247)
        faceSwi.onTintColor = UIColor(61, 138, 247)
    }

    func updateSwitch() {
        passcodeSwi.isOn = CDConfigFile.getBoolValueFromConfigWith(key: .passcodeSwitch)
        faceSwi.isOn = CDConfigFile.getBoolValueFromConfigWith(key: .faceSwitch)
    }
    
    @IBAction func upgradeAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(.upgrade)
    }
    
    @objc func passcodeClick() {
        if !passcodeSwi.isOn {
            return
        }
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(.passcode)
    }
    
    
    @objc func faceClick() {
       
    }
    
    @IBAction func passcodeSwitchAction(_ sender: Any) {
        if !passcodeSwi.isOn {
            CDSqlManager.shared.updateUserPwdWith(pwd: String())
            CDSignalTon.shared.basePwd = nil
            CDConfigFile.setBoolValueToConfigWith(key: .passcodeSwitch, boolValue: false)

            return
        }
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(.passcode)
//        CDConfigFile.setBoolValueToConfigWith(key: .passcodeSwitch, boolValue: passcodeSwi.isOn)
    }
    
    @IBAction func faceSwitchAction(_ sender: Any) {
        if !passcodeSwi.isOn && faceSwi.isOn {
            faceSwi.isOn = false
            CDHUDManager.shared.showText("Please set a passcode first")
            return
        }
        if !faceSwi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: .faceSwitch, boolValue: false)
            return
        }
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(.faceid)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
