//
//  CDNewFileViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/12.
//

import UIKit
import SnapKit
class CDNewFileViewController: CDBaseAllViewController,UITextViewDelegate, UITextFieldDelegate {

    
    private let lineView = UIView()
    private let textView = GrowingTextView()
    private let titleFiled = UITextField()
    private let timeLabel = UILabel()
    private var toolbar: CDToolBar!
    private var saveBtn: UIButton!
    private var unNamed  = "Untitled"
    private var isEdit: Bool = false
    private var isSave: Bool = true

    var isAddNew = false
    var fileInfo:CDSafeFileInfo!
    var folder:CDSafeFolder!
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .baseBgColor
        
        toolbar = CDToolBar(frame: .zero, barType: [.delete, .share, .edit_img], actionHandler: {[weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .share:
                self.shareBarItemClick()
            case .delete:
                self.deleteBarItemClick()
            case .edit_img:
                self.editBarItemClick()
            default:
                break
            }
        })
        toolbar.screenHeight = CDViewHeight
        view.addSubview(toolbar)
        view.bringSubviewToFront(toolbar)
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(BottomBarHeight)
        }
        
        
        lineView.backgroundColor = UIColor(250, 250, 250)
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(88)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)

        }
        view.addSubview(titleFiled)
        titleFiled.textColor = .customBlack
        titleFiled.delegate = self
        titleFiled.borderStyle = .roundedRect
        titleFiled.backgroundColor = .white
        titleFiled.font = UIFont.semiBold(12)
        titleFiled.layer.cornerRadius = 12
        titleFiled.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalTo(lineView.snp.top).offset(-6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)

        }

        timeLabel.textColor = .customBlack
        timeLabel.textColor = UIColor(215, 220, 226)
        timeLabel.font = UIFont.regular(12)
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.bottom.equalTo(titleFiled.snp.top).offset(-8)
            make.right.equalToSuperview().offset(-16)
        }

        textView.font = UIFont.regular(14)
        textView.textColor = UIColor(119, 126, 135)
        textView.backgroundColor = .white
        textView.delegate = self
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 12
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.layer.borderColor = UIColor(250, 250, 250).cgColor
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(6)
            make.left.equalTo(lineView)
            make.right.equalTo(lineView)
            make.bottom.equalTo(toolbar.snp.top)
            make.height.greaterThanOrEqualTo(150)
        }
    
        saveBtn = UIButton(type: .custom)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(UIColor(61, 138, 247), for: .normal)
        saveBtn.setTitleColor(.baseBgColor, for: .disabled)
        saveBtn.titleLabel?.font = UIFont.medium(18)
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)

        let backBth = UIButton(type: .custom)
        backBth.setImage("back".image, for: .normal)
        backBth.addTarget(self, action: #selector(backBthClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBth)

        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                           NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            keyboardHeight = keyboardHeight > 0 ? keyboardHeight - view.safeAreaInsets.bottom : keyboardHeight
            textView.snp.remakeConstraints { make in
                make.top.equalTo(lineView.snp.bottom).offset(6)
                make.left.equalTo(lineView)
                make.right.equalTo(lineView)
                make.bottom.equalToSuperview().offset(-keyboardHeight - 60)
                make.height.greaterThanOrEqualTo(150)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isEdit && isSave
    }
    
    func endEdit() {
        isEdit = false
        titleFiled.resignFirstResponder()
        textView.resignFirstResponder()
        toolbar.pop()
        updateUI()
    }
    
    func loadData() {
        if isAddNew {
            isEdit = true
            titleFiled.placeholder = unNamed
            textView.text = ""
            timeLabel.text = GetTodayFormat()
            updateUI()
            titleFiled.becomeFirstResponder()
            isSave = false
        } else {
            toolbar.pop()
            updateUI()
            titleFiled.text = fileInfo.fileName
            textView.text = try? String(contentsOfFile: fileInfo.filePath.absolutePath)

        }
       
    }
    
    @objc func backBthClick() {
        if !isSave {
            let alert = UIAlertController(title: "Do you want to keep this new document \(titleFiled.text ?? unNamed)?", message: "You can choose to save changes, or delete this document immediately. This operation cannot be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak self] action in
                guard let self = self else {
                    return
                }
                self.saveBtnClick()
                self.navigationController?.popViewController(animated: true)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] action in
                guard let self = self else {
                    return
                }
                self.deleteBarItemClick()
            }))
            self.present(alert, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)

        }
    }
    
    
    @objc func saveBtnClick() {
        endEdit()
        let fileTitle = titleFiled.text ?? titleFiled.placeholder
        let fileContent = textView.text
        if fileInfo != nil || !isAddNew {
            fileInfo.fileName = fileTitle!
            let filePath = fileInfo.filePath.absolutePath
            let data = fileContent?.data(using: .utf8)
            do {
                try data?.write(to: filePath.pathUrl)
            } catch {
                assertionFailure("New note save txt failed:\(error.localizedDescription)")
            }
            
            fileInfo.filePath = filePath.relativePath
            fileInfo.createTime = GetTimestamp()
            CDSqlManager.shared.updateOneSafeFileInfo(fileInfo: fileInfo)
        } else {
            fileInfo = CDSignalTon.shared.savePlainText(fileName: fileTitle, content: fileContent, folder: folder!)
        }
        CDHUDManager.shared.showComplete("Done!")
        isSave = true

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

extension CDNewFileViewController {
    
    func shareBarItemClick() {
        guard let url = fileInfo?.filePath.absolutePath.pathUrl else {
            return
        }
        presentShareActivityWith(dataArr: [url as NSObject]) { error in
            guard let _ = error else {
                CDHUDManager.shared.showComplete("Done")
                return
            }
            CDHUDManager.shared.showFail("Share Failed")

        }
    }
    
    func deleteBarItemClick() {
        guard let temp = self.fileInfo else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        func delete() {
            let defaultPath = temp.filePath.absolutePath
            defaultPath.delete()
            CDSqlManager.shared.deleteOneSafeFile(fileId: temp.fileId)
            CDHUDManager.shared.showComplete("Done")
            CDHUDManager.shared.hideWait()
        }

        let sheet = UIAlertController(title: nil, message: "Are you sure you want to do this?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            if self.folder.folderStatus == .Delete {
                if CDSignalTon.shared.vipType == .not {
                    self.guidedPayment {
                        delete()
                        self.navigationController?.popViewController(animated: true)

                    }
                }else {
                    
                    DispatchQueue.main.async {
                        delete()
                        CDHUDManager.shared.showComplete("Done!")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else {
                CDSqlManager.shared.updateOneSafeFileLifeCircle(with: .delete, fileId: temp.fileId)
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete("Done!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func editBarItemClick() {
        isEdit = true
        toolbar.dismiss()
        updateUI()
        if let text = titleFiled.text,
            !text.isEmpty {
            textView.becomeFirstResponder()
        } else {
            titleFiled.becomeFirstResponder()
        }
        isSave = false

    }
    
    func updateUI() {
        saveBtn.isHidden = !isEdit


        titleFiled.isEnabled = isEdit
        textView.isEditable = isEdit
        textView.isSelectable = isEdit
        textView.maxY = isEdit ? view.maxY : toolbar.minY

        if isEdit {
            textView.snp.remakeConstraints { make in
                make.top.equalTo(lineView.snp.bottom).offset(6)
                make.left.equalTo(lineView)
                make.right.equalTo(lineView)
                make.bottom.equalToSuperview()
                make.height.greaterThanOrEqualTo(150)

            }
            
            self.title = ""
        }else {
            textView.snp.remakeConstraints { make in
                make.top.equalTo(lineView.snp.bottom).offset(6)
                make.left.equalTo(lineView)
                make.right.equalTo(lineView)
                make.bottom.lessThanOrEqualTo(toolbar.snp.top)
                make.height.greaterThanOrEqualTo(150)
            }
            
            self.title = folder.folderName
        }
        
        self.view.layoutIfNeeded()
    }
    
}


extension CDNewFileViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear]) {
            self.view.layoutIfNeeded()
        }
    }
    
    
}
