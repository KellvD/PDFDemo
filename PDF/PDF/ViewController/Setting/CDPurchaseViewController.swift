//
//  CDPurchaseViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/21.
//

import UIKit

class CDPurchaseViewController: UIViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    private let vipInfoArr:[String] = ["Unlimited Scanning","OCR","Smart Effect","PDF convert And Share","PDF Label","Add Watermark","PDF Electronic Signatures","Multi-Picture Stitching","PDF Encryption","No Ads"]

    @IBOutlet weak var tittleLabel: UILabel!
    
    @IBOutlet weak var scrollerView: UIScrollView!
    @IBOutlet weak var scannerL: UILabel!
    @IBOutlet weak var premiumL: UILabel!
    
    @IBOutlet weak var standardBtn: UIButton!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var prremiumBtn: UIButton!
    
    @IBOutlet weak var termsLabel: UIButton!
    
    @IBOutlet weak var privateLabel: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var subscribeBtn: UIButton!
    
    @IBOutlet weak var scrollerViewTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollerView.addBackgroundGradient(colors: [
            UIColor(red: 1, green: 0.932, blue: 0.759, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        ], locations: [0, 0.4], startPoint: CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint(x: 0.5, y: 0.55))
//        scrollerView.translatesAutoresizingMaskIntoConstraints = false
//        scrollerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        scrollerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true


        _ = UIButton(frame: CGRect(x: CDSCREEN_WIDTH - 16 - 32, y: UIDevice.navigationFullHeight() - 16 - 32, width: 32, height: 32), imageNormal: "purchase_close",target: self, function: #selector(purchaseCloseClick), supView: self.view)
        
        let restore = UIButton(frame: CGRect(x: 16, y: UIDevice.navigationFullHeight() - 16 - 32, width: 64, height: 32), text: "Restore", textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), target: self, function: #selector(restoreBtnClick), supView: self.view)
        restore.titleLabel?.textAlignment = .left
        restore.titleLabel?.font = .robotoBold(14)
        
        premiumL.textColor = .white
        premiumL.font = .helvBold(14)
        premiumL.text = "Preminum".localize()
        premiumL.layer.cornerRadius = 8
        premiumL.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        
        scannerL.textColor = .black
        scannerL.font = .helvBold(24)
        scannerL.text = "Scanner".localize()
        
        tittleLabel.textColor = .black
        tittleLabel.font = .helvBold(16)
        tittleLabel.text = "Why do you need".localize()
        
        standardBtn.addRadius(corners: [.topLeft,.bottomLeft], size: CGSize(width: 28, height: 28))
        standardBtn.backgroundColor = UIColor(red: 0.724, green: 0.265, blue: 0, alpha: 0.05)
        standardBtn.setTitleColor(UIColor(0, 0, 0, 1), for: .normal)
        standardBtn.setTitle("Standard".localize(), for: .normal)
        standardBtn.titleLabel?.font = .helvBold(16)
        
        
        prremiumBtn.addRadius(corners: [.topRight,.bottomRight], size: CGSize(width: 28, height: 28))
        prremiumBtn.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        prremiumBtn.setTitleColor(.white, for: .normal)
        prremiumBtn.setTitle("Premium".localize(), for: .normal)
        prremiumBtn.titleLabel?.font = .helvBold(16)
        
        termsLabel.setTitleColor(UIColor(0, 0, 0, 0.3), for: .normal)
        termsLabel.setTitle("Terms of use".localize(), for: .normal)
        termsLabel.titleLabel?.font = .robotoBold(14)
        
        privateLabel.setTitleColor(UIColor(0, 0, 0, 0.3), for: .normal)
        privateLabel.setTitle("Privacy Policy".localize(), for: .normal)
        privateLabel.titleLabel?.font = .robotoBold(14)
        
        continueBtn.addBackgroundGradient(colors: [
            UIColor(red: 0.953, green: 0.255, blue: 0.255, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.612, blue: 0.184, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.683, blue: 0.067, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.819, blue: 0.121, alpha: 1).cgColor
            ], locations: [0.01, 0.45, 0.75, 1], startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        continueBtn.layer.cornerRadius = 28
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.setTitle("Continue to try for free".localize(), for: .normal)
        continueBtn.titleLabel?.font = .helvBold(16)
        
        subscribeBtn.backgroundColor = UIColor(red: 0.724, green: 0.265, blue: 0, alpha: 0.05)
        subscribeBtn.layer.cornerRadius = 28
        subscribeBtn.setTitleColor(UIColor(0, 0, 0, 0.6), for: .normal)
        subscribeBtn.setTitle("Subscribe for 3 months".localize(), for: .normal)
        subscribeBtn.titleLabel?.font = .helvBold(16)
        
        tableview.register(UINib(nibName: "CDVipCell", bundle: nil), forCellReuseIdentifier: "CDVipCell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor(0, 0, 0, 0)
        tableview.separatorStyle = .none
        tableview.reloadData()
        
        scrollerView.contentSize = CGSize(width: CDSCREEN_WIDTH, height: subscribeBtn.maxY + 48)
        
        let string = "Free for 7 days, then $16.88 every 7 days. Cancel at any time"
        let stringAttr = NSMutableAttributedString(string: string, attributes: [.font: UIFont.medium(14)])
        stringAttr.addAttributes([.font: UIFont.helvBold(16)], range: string.AsNSString().range(of: "Free"))
        stringAttr.addAttributes([.font: UIFont.helvBold(16)], range: string.AsNSString().range(of: "$16.88"))
        stringAttr.addAttributes([.font: UIFont.helvBold(16)], range: string.AsNSString().range(of: "7 days"))

        stringAttr.addAttributes([.font: UIFont.helvBold(16)], range: string.AsNSString().range(of: "7 days", options: .backwards))
        tipLabel.attributedText = stringAttr
    }

    
    
    
    @objc func restoreBtnClick() {
        NKIAPManager.viewController = self
        NKIAPManager.restoreProduct { _ in}
    }
    
    @objc func purchaseCloseClick() {
        self.dismiss(animated: true)

    }

    
    @IBAction func termsAction(_ sender: Any) {
        let vc = CDPrivateViewController()
        vc.url = terms_url
        vc.titleName = title
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func privateAction(_ sender: Any) {
        let vc = CDPrivateViewController()
        vc.url = private_url
        vc.titleName = title
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func continueFreeAction(_ sender: Any) {
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
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


extension CDPurchaseViewController: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vipInfoArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CDVipCell! = tableView.dequeueReusableCell(withIdentifier: "CDVipCell", for: indexPath) as? CDVipCell
        cell.bgViewIsHidden(isHidden: indexPath.row % 2 == 0)
        cell.titleLabel.text = vipInfoArr[indexPath.row]
        return cell
    }
    
}
