//
//  CDToolsViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit
import ZLPhotoBrowser

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
        case .pdfToDocx,.pdfToTab,.pdfToImage:
            
            super.presentDocumentPicker(documentTypes: ["com.adobe.pdf"]) { fileUrl in
                let currentTime = GetTimestamp()
                var resultPath = ""
                if mode == .pdfToDocx {
                    resultPath = String.RootPath().appendingPathComponent(str: "Tmp_\(currentTime).doc")
                    CDCovertTools.tableToPdf(fileUrl.absoluteString, pdfPath: &resultPath)

                } else if mode == .pdfToTab {
                    resultPath = String.RootPath().appendingPathComponent(str: "Tmp_\(currentTime).pdf")
                    CDCovertTools.pdfToTable(fileUrl.absoluteString, tablePath: &resultPath)
                }else if mode == .pdfToImage {
                    resultPath = String.RootPath().appendingPathComponent(str: "Tmp_\(currentTime).png")
                    CDCovertTools.pdfToImage(pdfPath: fileUrl.absoluteString, imagePath: &resultPath)
                }
                
                CDSignalTon.shared.saveFileWithUrl(fileUrl: resultPath.pathUrl, folderInfo: nil)
            }
        case .docxToPdf:
            super.presentDocumentPicker(documentTypes: ["com.microsoft.word.doc"]) { fileUrl in
//                let currentTime = GetTimestamp()
//                var pdfPath = String.RootPath().appendingPathComponent(str: "\Tmp_\(currentTime).pdf")
//                CDCovertTools.imageToPdf(images: images, pdfPath: &pdfPath)
//
//                CDSignalTon.shared.saveFileWithUrl(fileUrl: pdfPath.pathUrl, folderInfo: nil)
            }
        case .tabToPdf:
            super.presentDocumentPicker(documentTypes: ["com.microsoft.excel.xls"]) { fileUrl in
                let currentTime = GetTimestamp()
                var pdfPath = String.RootPath().appendingPathComponent(str: "Tmp_\(currentTime).pdf")
                CDCovertTools.tableToPdf(fileUrl.absoluteString, pdfPath: &pdfPath)
                
            }
        case .imageToPdf:
            addFromPhoto()
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
    
    func addFromPhoto() {
        CDAuthorizationTools.checkPermission(type: .library, presentVC: self) {[weak self] flag, message in
            guard let self = self else {
                return
            }
            if flag {
                DispatchQueue.main.async {
                    
                    let config = ZLPhotoConfiguration.default()
                    config.allowEditVideo = false
                    config.allowEditImage = false
                    config.maxSelectVideoDuration = 60 * 60
                    config.allowSelectImage = true
                    config.allowSelectVideo = false
                    config.allowTakePhotoInLibrary = false
                    config.allowPreviewPhotos = false
                    config.maxSelectCount = 10000
                    
                    
                    let uiconfig = ZLPhotoUIConfiguration.default()
                    uiconfig.showAddPhotoButton = false
                    let ps = ZLPhotoPreviewSheet()
                    
                    ps.selectImageBlock = {  results, isOriginal in
                        DispatchQueue.global().async {
                            var images:[UIImage] = []
                            for model in results {
                                images.append(model.image)
                            }
                            let currentTime = GetTimestamp()
                            var pdfPath = String.RootPath().appendingPathComponent(str: "\(currentTime).pdf")
                            CDCovertTools.imageToPdf(images: images, pdfPath: &pdfPath)
                            
                            CDSignalTon.shared.saveFileWithUrl(fileUrl: pdfPath.pathUrl, folderInfo: nil)
                            
                        }
                    }
                        
                    ps.showPhotoLibrary(sender: self)
                }
            }
        }
    }

   
}
extension CDToolsViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
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
