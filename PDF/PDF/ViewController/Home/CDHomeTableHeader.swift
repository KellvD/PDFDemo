//
//  CDHomeHeaderView.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit
class CDHomeTableHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var actionHandler: ((Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(234, 234, 234)

        self.titleLabel.textColor = .black
        self.titleLabel.font = .medium(20)
    }
    
    @IBAction func sortAction(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(0)
    }
    
    @IBAction func addFolderActio(_ sender: Any) {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler(1)
    }
}
