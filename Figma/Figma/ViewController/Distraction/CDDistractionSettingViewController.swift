//
//  CDDistractionSettingViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/15.
//

import UIKit

class CDDistractionSettingViewController: CDBaseAllViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var optional3Label: UILabel!
    @IBOutlet weak var optional2Label: UILabel!
    @IBOutlet weak var optional4Label: UILabel!
    
    @IBOutlet weak var videoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.titleLabel.textColor = .customBlack
        self.titleLabel.font = UIFont.medium(16)
        
        self.option1Label.textColor = UIColor(119, 126, 135)
        self.option1Label.font = UIFont.regular(12)
        
        self.optional3Label.textColor = UIColor(119, 126, 135)
        self.optional3Label.font = UIFont.regular(12)
        
        self.optional2Label.textColor = UIColor(119, 126, 135)
        self.optional2Label.font = UIFont.regular(12)
        
        
        self.optional4Label.textColor = UIColor(119, 126, 135)
        self.optional4Label.font = UIFont.regular(12)
        
        videoBtn.setTitleColor(.customBlack, for: .normal)
        videoBtn.titleLabel?.font = UIFont(name: "AlibabaPuHuiTi-Bold", size: 20)
        videoBtn.backgroundColor = UIColor(191, 197, 206)
        videoBtn.layer.cornerRadius = 12

        let backBtn = UIButton(type: .custom)
        backBtn.setImage("back".image, for: .normal)
        backBtn.setTitle("App Restrictions", for: .normal)
        backBtn.setTitleColor(.customBlack, for: .normal)
        backBtn.titleLabel?.font = .medium(18)
        backBtn.contentHorizontalAlignment = .left
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
    }

    @IBAction func settingClick(_ sender: Any) {
        print("TODO://setting")
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
