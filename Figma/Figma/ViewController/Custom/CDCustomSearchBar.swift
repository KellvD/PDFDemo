//
//  CDCustomSearchBar.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//

import UIKit
import SnapKit
class CDCustomSearchBar: UIView,UITextFieldDelegate {

    var searchFiles: UITextField!
    private var cancelSearchBtn: UIButton!
    var didBeginEditBlock: (() -> Void)?
    var actionBlock: ((String?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        cancelSearchBtn = UIButton(type: .custom)
        cancelSearchBtn.frame = CGRect(x: self.width - 16 - 62, y: 2, width: 62, height: 28)
        cancelSearchBtn.setTitle("Cancel", for: .normal)
        cancelSearchBtn.setTitleColor(UIColor(61, 138, 247), for: .normal)
        cancelSearchBtn.titleLabel?.font = UIFont.medium(18)
        cancelSearchBtn.addTarget(self, action: #selector(cancleClick), for: .touchUpInside)
        addSubview(cancelSearchBtn)

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 32))
        let leftv = UIImageView(frame: CGRect(x: 10, y: 10, width: 16, height: 16))
        leftv.image = "search".image
        leftView.addSubview(leftv)
        
        self.searchFiles = UITextField(frame: CGRect(x: 16, y: 0, width: self.width - 32, height: 32))
        self.searchFiles.placeholder = "Search"
        self.searchFiles.leftView = leftView
        searchFiles.delegate = self
        searchFiles.returnKeyType = .search
        searchFiles.backgroundColor = UIColor(242, 245, 248)
        searchFiles.layer.cornerRadius = 18
        searchFiles.leftViewMode = .always
        searchFiles.textColor = .customBlack
        searchFiles.clearButtonMode = .whileEditing
        addSubview(searchFiles)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadText(_ text: String) {
        self.searchFiles.text = text
    }
    
    func refreshUI(_ isHiddenCancel: Bool = true) {
        self.cancelSearchBtn.frame = CGRect(x: self.width - 16 - 62, y: 2, width: 62, height: 28)
        self.searchFiles.width = isHiddenCancel ? (self.width - 32) : (self.cancelSearchBtn.minX - 16 - self.searchFiles.minX)
    }
    
    func finishSearch() {
        searchFiles.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {[weak self] in
            guard let self = self else {
                return
            }
            var rect = self.searchFiles.frame
            rect.size.width = self.width - 32
            self.searchFiles.frame = rect
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {[weak self] in
            guard let self = self else {
                return
            }
            self.searchFiles.width = self.cancelSearchBtn.minX - 16 - self.searchFiles.minX

            guard let didBeginEditBlock = self.didBeginEditBlock else {
                return
            }
            didBeginEditBlock()
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let actionBlock = actionBlock else {
            return true
        }
        textField.resignFirstResponder()
        actionBlock(textField.text!)
        return true
    }
    
    @objc func cancleClick() {
        self.searchFiles.text = nil
        finishSearch()
        guard let actionBlock = actionBlock else {
            return
        }
        actionBlock(nil)
    }
} 
