//
//  CDHomeImportHeader.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit

class CDHomeImportHeader: UICollectionReusableView,UITextFieldDelegate {

    private var searchFiled: UITextField!
    public var enable = false
    var actionHandler: ((String?)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(234, 234, 234)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        searchFiled = UITextField(frame: CGRect(x: 16, y: 16, width: frame.width - 32, height: 40))
        searchFiled.leftView = leftView
        searchFiled.leftViewMode = .always
        searchFiled.delegate = self
        searchFiled.returnKeyType = .search
        searchFiled.placeholder = "Search".localize()
        searchFiled.layer.backgroundColor = UIColor(red: 0.918, green: 0.929, blue: 0.957, alpha: 1).cgColor
        searchFiled.layer.cornerRadius = 20
        searchFiled.layer.borderWidth = 1
        searchFiled.layer.borderColor = UIColor(red: 0.754, green: 0.787, blue: 0.864, alpha: 1).cgColor
        
        self.addSubview(searchFiled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let actionHandler = actionHandler else {
            return enable
        }
        actionHandler(nil)
        return enable
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let actionHandler = actionHandler else {
            return true
        }
        actionHandler(textField.text)
        return true
    }
   
}
