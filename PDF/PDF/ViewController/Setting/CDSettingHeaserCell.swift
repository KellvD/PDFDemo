//
//  CDSettingHeaserCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit

class CDSettingHeaserCell: UITableViewCell {

    @IBOutlet weak var iconBgview: UIView!
        
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var tipLLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tryBtn: UIButton!
    
    @IBOutlet var optionalIconBgView: [UIButton]!
    @IBOutlet var optionalLabels: [UILabel]!
    @IBOutlet weak var bgview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .baseBgColor
        self.selectionStyle = .none
        
        bgview.addBackgroundGradient(colors: [
            UIColor(red: 1, green: 0.927, blue: 0.742, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor], locations: [0, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        bgview.layer.cornerRadius = 24
        
        lineView.backgroundColor = UIColor(0, 0, 0, 0.1)
        iconBgview.layer.cornerRadius = 16
        iconBgview.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        
        titleLabel.textColor = .black
        titleLabel.font = .helvBold(24)
        titleLabel.text = "Scanner".localize()
        
        subtitleLabel.textColor = UIColor(0, 0, 0, 0.6)
        subtitleLabel.font = .helvBold(16)
        subtitleLabel.text = "Upgrade to premium".localize()

        tipLLabel.textColor = .white
        tipLLabel.font = .helvBold(14)
        
        tipLLabel.layer.cornerRadius = 8
        tipLLabel.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        tipLLabel.text = "Preminum".localize()

        tryBtn.setTitle("Try For Free".localize(), for: .normal)
        tryBtn.setTitleColor(.white, for: .normal)
        tryBtn.titleLabel?.font = .helvBold(16)
        tryBtn.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        
        tryBtn.layer.cornerRadius = 28
        
        optionalLabels.forEach({ label in
            label.textColor = UIColor(0, 0, 0, 0.6)
            label.font = .helvMedium(10)
        })
        
        optionalIconBgView.forEach({ view in
            view.layer.cornerRadius = 12

        })
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onTryAction(_ sender: Any) {
    }
    
}
