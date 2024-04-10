//
//  CDPrivateViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/27.
//

import UIKit
import WebKit
class CDPrivateViewController: CDBaseAllViewController {

    var url: String!
    var titleName: String?
    private var backBtn = UIButton(type: .custom)

    private lazy var progress: UIProgressView = {
        let progress = UIProgressView.init(frame: CGRect(x:0, y: 0, width: CDSCREEN_WIDTH, height:1))
        progress.transform = CGAffineTransform.init(scaleX: 1, y: 0.5)
        progress.progressViewStyle = .bar
        view.addSubview(progress)
        progress.progressTintColor = UIColor.blue
        progress.trackTintColor = UIColor.white
        progress.progress = 0
        return progress
    }()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: self.progress.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - self.progress.maxY), configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let urll = URL(string: url) else {
            return
            
        }
        var reque = URLRequest(url: urll)
        reque.timeoutInterval = 15
        self.webView.load(reque)
        
        self.webView.addObserver(self, forKeyPath: "estimatedProgress1", options: .new, context: nil)

        backBtn.setImage("back".image, for: .normal)
        backBtn.setTitle(titleName, for: .normal)
        backBtn.setTitleColor(.customBlack, for: .normal)
        backBtn.titleLabel?.font = .medium(18)
        backBtn.contentHorizontalAlignment = .left
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
//        CDHUDManager.shared.showWait()
    }

    @objc func backBtnClick() {

        self.dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress1"{
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CDPrivateViewController: UIWebViewDelegate, WKNavigationDelegate  {
    /**
     *  根据webView、navigationAction相关信息决定这次跳转是否可以继续进行,这些信息包含HTTP发送请求，如头部包含User-Agent,Accept,refer
     *  在发送请求之前，决定是否跳转的代理
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow);
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        DispatchQueue.main.async {
//            CDHUDManager.shared.hideWait()
//        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        DispatchQueue.main.async {
//            CDHUDManager.shared.hideWait()
//            self.alertWarn()
//        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
//            CDHUDManager.shared.hideWait()
            self.alertWarn()
            
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
    
    func alertWarn() {
        
        let alert = UIAlertController(title: "Warn", message: "Something went be wrong, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I Know", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

