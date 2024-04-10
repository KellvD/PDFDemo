//
//  CDVipViewController.swift
//  Figma
//
//  Created by dong chang on 2024/2/4.
//

import UIKit
class CDVipViewController: CDBaseAllViewController {
    private var scroller: UIScrollView!
    var cancelHandler:(()->Void)?
    var isShowInterAds = true
    private var type: CDVipType = .year
    lazy var dataArr: [CDAppBuyInfo] = {
        var arr:[CDAppBuyInfo] = []
        var id_arr = [IAP_Week,IAP_Year,IAP_Mouth]
        var title_arr = ["Weekly","Yearly","Mouthly"]
        var price_arr = ["$4.99","$69.99","$16.99"]
        for i in 0..<3{
            let info = CDAppBuyInfo()
            info.productName = title_arr[i]
            info.productIdentifier = id_arr[i]
            info.price = price_arr[i]
            arr.append(info)
        }
        return arr
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CDSignalTon.shared.vipType == .not {
            CDSignalTon.shared.makeInterstitialAd { _ in}
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        refreshVip()
        NKIAPManager.viewController = self
        NKIAPManager.getPurchaseProductList {[weak self] productArr in
            guard let self = self else {
                return
            }
            if productArr != nil {
                self.dataArr = productArr!

            }
            self.refreshVip()
        }
    }
    
    override func refreshVip() {
        for i in 0..<self.dataArr.count {
            let info = self.dataArr[i]
            let view = scroller.viewWithTag(i + 1) as? VipInfoView
            view?.loadData(info: info, type: CDVipType(rawValue: i + 1)!)
        }
    }
    
    @objc private func onSubscribeNow() {
        
        let info = self.dataArr[type.rawValue - 1]
        CDHUDManager.shared.showWait()
        NKIAPManager.purchaseProduct(productIDs: info.productIdentifier) {[weak self] flag in
            CDHUDManager.shared.hideWait()

            guard let self = self else {
                return
            }
            if flag {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func serviceClick(sender: UIButton) {
        if sender.tag == 3 {
            if CDSignalTon.shared.vipType == .vip {
                CDHUDManager.shared.showText("Your all features has been unlock!")
                return
            }
            NKIAPManager.restoreProduct {[weak self] flag in
                guard let self = self else {
                    return
                }
                if flag {
                    self.dismiss(animated: true)
                }
            }
        } else {
            let vc = CDPrivateViewController()
            vc.url = sender.tag == 1 ?
            "https://sites.google.com/view/hide-photos-terms-of-us/home":
            "https://sites.google.com/view/hide-photos-privacy-policy/home"
            vc.titleName = sender.tag == 1 ? "Terms of Use" : "Privacy Policy"
            let nav = CDNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    private func vipInfoClick(tag: Int) {
        for i in 1..<4 {
            let view = scroller.viewWithTag(i) as? VipInfoView
            view?.isSelected = i == tag
            
        }
        type = CDVipType(rawValue: tag)!
    }
    
    @objc private func onCancelClick() {
        self.dismiss(animated: true) {
            if self.isShowInterAds,
               let cancelHandler = self.cancelHandler {
                cancelHandler()
            }
        }
    }
    
    @objc func cancelVipClick() {
//        let pay = SK
    }
    
    private func initUI() {
        self.view.backgroundColor = .white
        scroller = UIScrollView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - UIDevice.safeAreaBottom()))
        view.addSubview(scroller)
        
        let bgView = UIImageView(image: "订阅页图".image)
        bgView.contentMode = .scaleAspectFill
        bgView.isUserInteractionEnabled = true
        scroller.addSubview(bgView)
        bgView.frame = CGRect(x: 0, y: -50, width: scroller.width, height: 281)
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage("关闭".image, for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
        self.view.addSubview(cancelBtn)
        cancelBtn.frame = CGRect(x: 23, y: StatusHeight, width: 33, height: 33)
        
        let titleL1 = UILabel()
        titleL1.text = "What’s included"
        titleL1.textColor = .customBlack
        titleL1.font = .medium(20)
        titleL1.textAlignment = .center
        scroller.addSubview(titleL1)
        titleL1.frame = CGRect(x: 0, y: bgView.maxY + 15, width: scroller.width, height: 25)
        
        let titleL2 = UILabel()
        titleL2.text = "Unlock all features, break all limits"
        titleL2.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
        titleL2.font = .regular(16)
        titleL2.alpha = 0.6
        titleL2.textAlignment = .center
        scroller.addSubview(titleL2)
        titleL2.frame = CGRect(x: 0, y: titleL1.maxY + 8, width: scroller.width, height: 24)
        
        
        let optionView = OptionView()
        scroller.addSubview(optionView)
        optionView.frame = CGRect(x: 0, y: titleL2.maxY + 15, width: scroller.width, height: 180)
        
        let width = (CDSCREEN_WIDTH - 14 * 4)/3.0
        let yearView = VipInfoView(frame: .zero)
        yearView.tag = 2
        yearView.frame = CGRect(x: scroller.width/2.0 - width/2.0, y: optionView.maxY + 25, width: width, height: 144)
        
        yearView.onClickHandler = {[weak self] tag in
            guard let self = self else {
                return
            }
            self.vipInfoClick(tag: tag)
            
        }
        scroller.addSubview(yearView)
        
        let tip = UIButton(type: .custom)
        tip.setBackgroundImage("Rectangle 5555".image, for: .normal)
        tip.setTitle("Hot", for: .normal)
        tip.setTitleColor(.white, for: .normal)
        tip.titleLabel?.font = .medium(11)
        scroller.addSubview(tip)
        tip.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(22)
            make.centerY.equalTo(yearView.snp.top)
            make.left.equalTo(yearView)
        }
        
        let weekView = VipInfoView(frame: .zero)
        weekView.tag = 1
        weekView.frame = CGRect(x: 14, y: yearView.midY - 128/2.0, width: width, height: 128)
        weekView.onClickHandler = {[weak self] tag in
            guard let self = self else {
                return
            }
            self.vipInfoClick(tag: tag)
            
        }
        scroller.addSubview(weekView)
        
        let mouthView = VipInfoView(frame: .zero)
        mouthView.tag = 3
        mouthView.frame = CGRect(x: yearView.maxX + 14, y: yearView.midY - 128/2.0, width: width, height: 128)
        
        mouthView.onClickHandler = {[weak self] tag in
            guard let self = self else {
                return
            }
            self.vipInfoClick(tag: tag)
            
        }
        scroller.addSubview(mouthView)
        
        yearView.isSelected = true
        mouthView.isSelected = false
        weekView.isSelected = false
        
        let button = UIButton(type: .custom)
        button.setTitle("Subscribe Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.regular(12)
        button.addTarget(self, action: #selector(onSubscribeNow), for: .touchUpInside)
        button.titleLabel?.font = .medium(16)
        scroller.addSubview(button)
        button.frame = CGRect(x: 16, y: yearView.maxY + 16, width: scroller.width - 32, height: 48)
        button.layer.cornerRadius = 24
        button.backgroundColor = .customBlack
        
        let cancle = UILabel()
        cancle.text = "Cancel anytime"
        cancle.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
        cancle.font = .regular(12)
        cancle.alpha = 0.3
        cancle.textAlignment = .center
        scroller.addSubview(cancle)
        cancle.frame = CGRect(x: 0, y: button.maxY + 10, width: scroller.width, height: 18)
        
        
        let terms = UIButton(type: .custom)
        terms.tag = 1
        terms.setTitle("| Terms of Use |", for: .normal)
        terms.setTitleColor(UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 0.6), for: .normal)
        terms.titleLabel?.font = UIFont.regular(12)
        terms.addTarget(self, action: #selector(serviceClick), for: .touchUpInside)
        scroller.addSubview(terms)
        terms.snp.makeConstraints { make in
            make.top.equalTo(cancle.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        let privacy = UIButton(type: .custom)
        privacy.tag = 2
        privacy.setTitle("Privacy Policy", for: .normal)
        privacy.setTitleColor(UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 0.6), for: .normal)
        privacy.titleLabel?.font = UIFont.regular(12)
        privacy.addTarget(self, action: #selector(serviceClick), for: .touchUpInside)
        scroller.addSubview(privacy)
        privacy.snp.makeConstraints { make in
            make.top.equalTo(cancle.snp.bottom).offset(12)
            make.height.equalTo(18)
            make.right.equalTo(terms.snp.left).offset(-4)
        }
        
        
        let restore = UIButton(type: .custom)
        restore.tag = 3
        restore.setTitle("Restore Purchase", for: .normal)
        restore.setTitleColor(UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 0.6), for: .normal)
        restore.titleLabel?.font = UIFont.medium(12)
        restore.addTarget(self, action: #selector(serviceClick), for: .touchUpInside)
        scroller.addSubview(restore)
        restore.snp.makeConstraints { make in
            make.top.equalTo(cancle.snp.bottom).offset(12)
            make.height.equalTo(18)
            make.left.equalTo(terms.snp.right).offset(4)
            
        }
        
        let contentHeeight = cancle.maxY + 30 + 20
        if contentHeeight > scroller.height {
            
            scroller.contentSize = CGSize(width: CDSCREEN_WIDTH, height: contentHeeight)
            
            scroller.contentOffset = CGPointMake(0, contentHeeight - scroller.height)
            
        }
    }
}


class OptionView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        let arr = ["Hide Your Photos & Videos",
                   "Recover from Trash",
                   "Private Website Visit",
                   "Unlimited Import & Export",
                   "No Ads"]
        for i in 0..<arr.count {
            let imagV = UIImageView(image: "select".image)
            self.addSubview(imagV)
            imagV.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(88)
                make.width.height.equalTo(18)
                make.top.equalTo((29 + 10) * CGFloat(i))
            }
            
            let titleL2 = UILabel(frame: .zero)
            titleL2.text = arr[i]
            titleL2.textColor = .customBlack
            titleL2.font = .medium(14)
            self.addSubview(titleL2)
            titleL2.snp.makeConstraints { make in
                make.left.equalTo(imagV.snp.right).offset(10)
                make.centerY.equalTo(imagV)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class VipInfoView: UIImageView {
    
    let countLabel = UILabel(frame: .zero)
    let typeLabel = UILabel(frame: .zero)
    let priceLabel = UILabel(frame: .zero)
    let otherLabel = UILabel(frame: .zero)

    var type: CDVipType = .year
    var onClickHandler:((Int) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        countLabel.textColor = .white
        self.addSubview(countLabel)
        
        typeLabel.textColor = .white
        typeLabel.font = .medium(12)
        self.addSubview(typeLabel)
        
        priceLabel.textColor = .white
        priceLabel.font = .medium(14)
        self.addSubview(priceLabel)
        
        otherLabel.textColor = .white
        otherLabel.font = .semiBold(12)
        otherLabel.text = "SAVE 60%"
        otherLabel.textAlignment = .center
        self.addSubview(otherLabel)
        otherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(78)
            make.height.equalTo(23)
            make.bottom.equalToSuperview().offset(-13)
        }
        otherLabel.backgroundColor = .customBlack
        otherLabel.addRadius(corners: .allCorners, size: CGSize(width: 11.5, height: 11.5))
        otherLabel.isHidden = true
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapClick))
        self.addGestureRecognizer(tap)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTapClick() {
        guard let onClickHandler = onClickHandler else {
            return
        }
        onClickHandler(self.tag)
    }
    
    func loadData(info: CDAppBuyInfo, type: CDVipType) {
        priceLabel.text = info.price
        typeLabel.text = info.productName

        if type == .mouth || type == .week {
            otherLabel.isHidden = true
            countLabel.text = "1"
            countLabel.font = .semiBold(22)

            countLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(14)
                make.height.equalTo(27)
            }
            priceLabel.font = .semiBold(18)
            priceLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-18)
                make.height.equalTo(22)
            }
            
            typeLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(countLabel.snp.bottom).offset(9)
                make.bottom.equalTo(priceLabel.snp.top).offset(-18)
            }
        }else {
            otherLabel.isHidden = false
            countLabel.font = .semiBold(28)
            countLabel.text = "1"
            countLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(10)
                make.height.equalTo(34)
            }
            
            priceLabel.font = .semiBold(20)
            priceLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(otherLabel.snp.top).offset(-13)
                make.height.equalTo(24)
            }
            
            typeLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(countLabel.snp.bottom).offset(6)
                make.bottom.equalTo(priceLabel.snp.top).offset(-6)
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            
            if type == .year {
                self.image = isSelected ? "year_select".image :"year_normal".image
            } else {
                self.image = isSelected ? "week_select".image :"week_normal".image

            }
        }
    }
    
}
