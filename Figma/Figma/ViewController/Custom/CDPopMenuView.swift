//
//  CDPopMenuView.swift
//  MyRule
//
//  Created by changdong on 2019/4/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import SnapKit
@objc protocol CDPopMenuViewDelegate {
    @objc func onSelectedPopMenu(title: String)
}
private let tableBgViewWidth: CGFloat = 169
private var tableBgViewY: CGFloat = 0

class CDPopMenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    let cellHeight = 34

    weak var popDelegate: CDPopMenuViewDelegate!
    var tableView: UITableView!
    var tableBgView: UIImageView!

    var tableBgViewHeight: CGFloat = 0
    var _cellTitleArr: [String] = []
    var _cellImageArr: [String] = []
    init(frame: CGRect, imageArr: [String], titleArr: [String]) {
        super.init(frame: frame)
        let backGroundView = UIView(frame: frame)
        backGroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backGroundView.addGestureRecognizer(tap)
        backGroundView.alpha = 0.3
        addSubview(backGroundView)

        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)

        _cellTitleArr = titleArr
        _cellImageArr = imageArr
        var tableViewHeight: CGFloat = CGFloat(cellHeight * imageArr.count)
        tableViewHeight = tableViewHeight > frame.height/2 ? frame.height/2 : tableViewHeight
//
        tableBgViewY = self.height - 81 - tableViewHeight
        let bgImage = "pop_bg".image!
        tableBgView = UIImageView(frame: CGRect(x: 8, y: tableBgViewY, width: tableBgViewWidth, height: tableViewHeight))
        tableBgView.isUserInteractionEnabled = true
        tableBgView.image = bgImage.stretchableImage(withLeftCapWidth: Int(bgImage.size.width/2), topCapHeight: Int(bgImage.size.height/2))
        self.addSubview(tableBgView)

        tableView = UITableView(frame: tableBgView.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableBgView.addSubview(tableView)
        tableView.rowHeight = CGFloat(cellHeight)
        tableView.isScrollEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _cellTitleArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CDPopMenuViewIdentify")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CDPopMenuViewIdentify")
            cell.selectionStyle = .default
            
            cell.backgroundColor = .clear
            let imageV = UIImageView(frame: .zero)
            imageV.tag = 101
            cell.addSubview(imageV)
            imageV.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-9)
                make.centerY.equalToSuperview()
                make.height.width.equalTo(16)
            }
            
            let titleL = UILabel(frame: .zero)
            titleL.textColor = .customBlack
            titleL.font = .regular(12)
            titleL.tag = 102
            cell.addSubview(titleL)
            titleL.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(12)
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.right.equalTo(imageV.snp.left).offset(-12)
            }
            let sperateLine = UIView(frame: .zero)
            sperateLine.tag = 103
            sperateLine.backgroundColor = UIColor(245, 245, 245)
            cell.addSubview(sperateLine)
            sperateLine.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-1)
                make.height.equalTo(1)
            }
        }
        guard let titleV = cell.viewWithTag(102) as? UILabel,
              let imageV = cell.viewWithTag(101) as? UIImageView,
              let lineView = cell.viewWithTag(103) else {
            return cell
        }
        
        let title = _cellTitleArr[indexPath.row]
        let imageName = _cellImageArr[indexPath.row]
        titleV.text = title
        titleV.textColor = indexPath.row == 0 ? UIColor.customBlack : UIColor(255, 59, 48)
        imageV.image = imageName.image
        lineView.isHidden = indexPath.row == _cellImageArr.count-1

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = _cellTitleArr[indexPath.row]
        self.popDelegate.onSelectedPopMenu(title: title)
        dismiss()
    }

    func showPopView() {
        self.isHidden = false

        UIView.animate(withDuration: 0.25, animations: {
            self.minY = 0
        }) { (_) in}
    }
    
    @objc func dismiss() {

        UIView.animate(withDuration: 0.25, animations: {
            self.minY = self.height

        }) { (_) in
            self.isHidden = true
        }
    }
}
