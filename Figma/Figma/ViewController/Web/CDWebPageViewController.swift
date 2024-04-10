//
//  CDWebPageViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//

import UIKit
import WebKit
class CDWebPageViewController: CDBaseAllViewController {

    var isAdd = false
    var file: CDWebPageInfo?
    private var lastBtn: UIButton!
    private var nextBtn: UIButton!
    private var managerL: UILabel!
    private var backBtn: UIButton!
    private var shortcutHref: String?
    private var lastLoadImage: UIImage?
    private var requestUrrl: String?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private lazy var toolbar: CDToolBar = {
        let toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: [.lastStep, .nextStep, .search, .add,.manager], actionHandler: {[weak self] type in
            guard let self = self else {
                return
            }
            switch type {
            case .lastStep:
                self.lastAction()
            case .nextStep:
                self.nextAction()
            case .add:
                self.addAction()
            case .search:
                self.searchAction()
            case .manager:
                self.managerAction()
            default:
                break
            }
        })
        
        view.addSubview(toolbar)
        guard let lastBtn = toolbar.viewWithTag(CDToolBar.CDToolsType.lastStep.rawValue) as? UIButton,
              let nextBtn = toolbar.viewWithTag(CDToolBar.CDToolsType.nextStep.rawValue) as? UIButton else {
           return toolbar
        }
        self.lastBtn = lastBtn
        self.nextBtn = nextBtn
        self.lastBtn.setImage("back".image, for: .normal)
        self.lastBtn.setImage("Last_tool".image, for: .disabled)
        self.nextBtn.setImage("Next_tool".image, for: .disabled)
        self.nextBtn.setImage("Next_tool_enable".image, for: .normal)
        self.lastBtn.isEnabled = false
        self.nextBtn.isEnabled = false
        self.managerL = toolbar.managerItem
        return toolbar
    }()
    
    lazy var searchBar: CDCustomSearchBar = {
        let searchBar = CDCustomSearchBar(frame: CGRect(x: 0, y: StatusHeight + 8, width: CDSCREEN_WIDTH, height: 32))
        view.addSubview(searchBar)
        searchBar.actionBlock = {[weak self] text in
            guard let self = self else {
                return
            }
            self.searchRefreshData(text)
        }
        searchBar.didBeginEditBlock = { [weak self] in
            guard let self = self else {
                return
            }
            self.searchBarDidBeginEdit()
        }
        return searchBar
    }()
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let height = self.toolbar.minY - self.progress.maxY
        let webView = WKWebView(frame: CGRect(x: 0, y: self.progress.maxY, width: CDSCREEN_WIDTH, height: height), configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
        return webView
    }()
    
    lazy var progress: UIProgressView = {
        let progress = UIProgressView.init(frame: CGRect(x:0, y: self.searchBar.maxY + 8, width: CDSCREEN_WIDTH, height:1))
        progress.transform = CGAffineTransform.init(scaleX: 1, y: 0.5)
        progress.progressViewStyle = .bar
        view.addSubview(progress)
        progress.progressTintColor = UIColor.blue
        progress.trackTintColor = UIColor.white
        progress.progress = 0
        return progress
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 16, y: self.searchBar.midY - 12, width: 24, height: 24)
        backBtn.setImage("back".image, for: .normal)
        backBtn.contentHorizontalAlignment = .left
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        view.addSubview(backBtn)
        self.backBtn.isHidden = isAdd

        if isAdd {
            self.searchBar.searchFiles.becomeFirstResponder()
        } else {
            self.searchBar.minX = 40
            self.searchBar.width = CDSCREEN_WIDTH - 40
            self.searchBar.refreshUI(true)
            self.searchBar.loadText(file!.webUrl)
            self.toolbar.pop()
            loadRequest(string: file!.webUrl)
        }
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        updateMannagerCount()

    }
    
    func updateMannagerCount() {
        let count = CDSqlManager.shared.queryWebPageCount()
        self.managerL.text = "\(count)"
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progress.progress = Float(webView.estimatedProgress)
        }
        //加载完成隐藏进度条
        if progress.progress == 1{
            let afterTime:DispatchTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: afterTime) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.progress.isHidden = true
                    
                }, completion: { (result) in
                    self.progress.progress = 0
                })
            }
        }
    }
       
    func loadRequest(string: String) {
        requestUrrl = string
        var search = URL(string: string)

        if containsChineseCharacter(string: string) {
            guard let urlwithPercentEscapes = string.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: urlwithPercentEscapes) else{
                alertWarn()
                return
            }
            search = url
        }
        var req = URLRequest(url: search!)
        req.timeoutInterval = 60
        self.webView.load(req)

    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    //
    func lastAction() {
        self.webView.goBack()
    }
    
    func nextAction() {
        self.webView.goForward()
    }
    
    func searchAction() {
        self.backBtn.isHidden = true
        self.searchBar.minX = 0
        self.searchBar.width = CDSCREEN_WIDTH
        self.searchBar.refreshUI(false)
        self.searchBar.searchFiles.text = ""
        self.searchBar.searchFiles.becomeFirstResponder()
    }
    
    func addAction() {
        func addNewPage() {
            let vc = CDWebPageViewController()
            vc.isAdd = true
            if var arr = self.navigationController?.viewControllers {
                arr.removeLast()
                arr.append(vc)
                navigationController?.setViewControllers(arr, animated: true)
            }
        }
        
        if CDSignalTon.shared.vipType == .not{
            self.guidedPayment {
                addNewPage()
            }
            return
        }else {
            addNewPage()
        }
        
    }
    
    func managerAction() {
        let vc = CDSegmentWebViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func searchRefreshData(_ text: String?) {
        guard let text = text?.removeSpaceAndNewline(),
                 !text.isEmpty else {
            updateNavigationUI()
            return
        }
        var searchUrl: String!
        
        if !text.contains(".") {
#if DEBUG
            searchUrl = "https://www.baidu.com/s?word=\(text)"
#else
            searchUrl = "https://www.google.com/search?q=\(text)"
#endif
            loadRequest(string: searchUrl)

        } else {
            if let tmp = isValidUrl(text) {
                searchUrl = tmp
            } else if let tmp = isValidUrl("https://\(text)") {
                searchUrl = tmp
            } else if let tmp = isValidUrl("https://www.\(text)") {
                searchUrl = tmp
            } else {
                clearWebView()
                return
            }
            
            loadRequest(string: searchUrl)

        }
        
    }
    
    func clearWebView() {
        self.webView.loadHTMLString("", baseURL: nil)

    }
    
    func updateNavigationUI() {
        if self.searchBar.minX == 46 {
            return
        }
        self.searchBar.minX = 46
        self.searchBar.width = CDSCREEN_WIDTH - 46
        self.searchBar.refreshUI(true)
        self.backBtn.isHidden = false
        self.toolbar.pop()
        self.webView.height = self.toolbar.minY - self.webView.minY

    }
    
    func searchBarDidBeginEdit() {
        self.backBtn.isHidden = true
        self.searchBar.minX = 0
        self.searchBar.width = CDSCREEN_WIDTH
        self.searchBar.refreshUI(false)
    }
    
    func isValidUrl(_ urlString: String) -> String? {
        var string = urlString
        if containsChineseCharacter(string: urlString) {
            string = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        if let url = URL(string: string),
            UIApplication.shared.canOpenURL(url) {
            return string
        } else {
            return nil
        }
    }
    
    func alertWarn() {
        clearWebView()
        CDHUDManager.shared.showText("Something went be wrong,\n Please try again")
    }
    
    func savePageInfo(webUrl: String) {
        if let temp  = file {
            temp.webUrl = webUrl
            CDSqlManager.shared.updateOneWebage(fileInfo: temp)
        } else {
            let createTime = GetTimestamp()
            let web = CDWebPageInfo()
            web.webUrl = webUrl
            web.createTime = createTime
            web.webType = .normal
            let webId = CDSqlManager.shared.addWebPageInfo(fileInfo: web)
            file = web
            file?.webId = webId
            updateMannagerCount()
        }
    }
    
    func containsChineseCharacter(string: String) -> Bool {
        for scalar in string.unicodeScalars {
            if (0x4E00...0x9FFF).contains(scalar.value) || (0x3400...0x4DB5).contains(scalar.value) {
                return true
            }
        }
        
        return false
    }
}


extension CDWebPageViewController: UIWebViewDelegate, WKNavigationDelegate  {
    /**
     *  根据webView、navigationAction相关信息决定这次跳转是否可以继续进行,这些信息包含HTTP发送请求，如头部包含User-Agent,Accept,refer
     *  在发送请求之前，决定是否跳转的代理
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url?.absoluteString,
              !url.contains("about:blank") else {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
        self.searchBar.searchFiles.text = url
        self.lastBtn.isEnabled = webView.canGoBack
        self.nextBtn.isEnabled = webView.canGoForward
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    /**
     *  页面加载完成。 等同于UIWebViewDelegate: - webViewDidFinishLoad:
     一般在这个方法中，我们会获取加载的一些内容，比如title，另外WKWebView内部的方法canGoBack，canGoForward，都很容易让使用者控制当前页面的前进和回退交互
     */
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else {
            return
        }
        
        if url.contains("about:blank") {
           return
        }
        
        self.searchBar.searchFiles.text = url.removePercentEncoding
        self.lastBtn.isEnabled = webView.canGoBack
        self.nextBtn.isEnabled = webView.canGoForward
        webView.resignFirstResponder()
        updateNavigationUI()
        

        if let temp = self.file,
           temp.webType != .lock {
            savePageInfo(webUrl: url)

            webView.evaluateJavaScript("document.querySelector('link[rel=\"shortcut icon\"]')?.href") { result, error in
                guard let href = result as? String else {
                    return
                }
                CDSqlManager.shared.updateWebPageIcon(iconUrl: href, webId: temp.webId)

            }
            
            // 网页加载完成后，开始截图
            webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                if complete != nil && complete as? String == "complete" {
                    webView.takeSnapshot(with: nil, completionHandler: { (image, error) in
                        guard let image = image else {
                            return
                        }
                        
                        let createTime = temp.createTime
                        var thumbPath = String.WebThumpFile().appendingPathComponent(str: "\(createTime).png")
                        
                        if !temp.thumbImagePath.isEmpty && FileManager.default.fileExists(atPath: temp.thumbImagePath.absolutePath) {
                            thumbPath = temp.thumbImagePath.absolutePath
                        }
                        if let data = image.pngData() {
                            do {
                                try data.write(to: thumbPath.pathUrl)
                            } catch {
                                print("Failed to save screenshot with error: \(error)")
                            }
                        }
                        temp.thumbImagePath = thumbPath.relativePath
                        CDSqlManager.shared.updateWebPageThumb(thumbPath: thumbPath.relativePath, webId: temp.webId)
                        NotificationCenter.default.post(name: NSNotification.Name("updateWebPage"), object: nil)
                        
                    })
                }
            })
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
        let url = navigationAction.request.url?.absoluteString
        if url == "" {
            let newWebV = WKWebView.init(frame: self.view.bounds, configuration: configuration)
            return newWebV
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard let url = requestUrrl else {
            return
        }
//       / loadRequest(string: url)
        if webView.url != nil {
            DispatchQueue.main.async {
                self.alertWarn()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.alertWarn()
        }
    }
}

