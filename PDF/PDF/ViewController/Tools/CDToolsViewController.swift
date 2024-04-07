//
//  CDToolsViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit

class CDToolsViewController: CDBaseAllViewController, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    private var dataArr:[[CDToolOption]] = [
        [.document,.idScanner,.ocr,.qrCode],
        [.pdfToDocx,.pdfToTab,.pdfToImage,.docxToPdf,.tabToPdf,.imageToPdf],
        [.signature,.textEditor,.watermark,.pdfEnc]]
    private var collectionView: UICollectionView!

    
    lazy var navigation: CDCustomNavigationBar = {
        let nib = UINib(nibName: "CDCustomNavigationBar", bundle: nil)
        let navi = nib.instantiate(withOwner: self, options: nil).first as! CDCustomNavigationBar
        navi.frame = CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 80)
        navi.backgroundColor = .baseBgColor

        navi.loadData(title: "Tools", subTitle: "", image: "set") { [weak self] in
            guard let self = self else {
                return
            }
        }
        return navi
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.navigation)
        view.backgroundColor = .baseBgColor
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: (CDSCREEN_WIDTH - 32 - 8)/2.0, height: 56)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: self.navigation.maxY, width: CDSCREEN_WIDTH, height: CDViewHeight - self.navigation.maxY), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "CDToolCell", bundle: nil), forCellWithReuseIdentifier: "CDToolCell")
        collectionView.register(CDToolsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CDToolsHeaderView")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .baseBgColor
        view.addSubview(collectionView)
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
         CGSize(width: CDSCREEN_WIDTH - 32, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDToolCell", for: indexPath) as! CDToolCell
        let model = dataArr[indexPath.section][indexPath.item]
        cell.loadData(tool: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CDToolsHeaderView", for: indexPath) as! CDToolsHeaderView
            if indexPath.section == 0 {
                headerView.titleLabel.text = "Scanner"
            }else if indexPath.section == 1 {
                headerView.titleLabel.text = "Converter"
            }else if indexPath.section == 2 {
                headerView.titleLabel.text = "PDF Editor"
            }
            return headerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mode = dataArr[indexPath.section][indexPath.item]
        switch mode {
        case .document: break
        case .idScanner:
            break
        case .ocr:
            break
        case .qrCode:
            break
        case .pdfToDocx:
            break
        case .pdfToTab:
            break
        case .pdfToImage:
            break
        case .docxToPdf:
            break
        case .tabToPdf:
            break
        case .imageToPdf:
            break
        case .signature:
            break
        case .textEditor:
            break
        case .watermark:
            break
        case .pdfEnc:
            break
        }
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

class CDToolsHeaderView: UICollectionReusableView {
    var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: frame.height))
        titleLabel.textColor = .black
        titleLabel.font = .helvMedium(20)
        self.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
