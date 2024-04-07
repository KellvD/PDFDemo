//
//  CDCameraViewController.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit
import AVFoundation

class CDCameraViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var autoScanBtn: UIButton!
    @IBOutlet weak var lightBtn: UIButton!
    @IBOutlet weak var typeScroller: UIScrollView!
    @IBOutlet weak var previewView: UIButton!
    @IBOutlet weak var toolsBtn: UIButton!
    
    var cameraManger: CDCameraManger!
    var isAuto = false
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.hidesBottomBarWhenPushed = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lightBtn.setImage("light_normal".image, for: .normal)
        lightBtn.setImage("light_select".image, for: .selected)

        autoScanBtn.setTitle("Auto Scan".localize(), for: .normal)
        autoScanBtn.setTitleColor(.white, for: .normal)
        autoScanBtn.titleLabel?.font = .helvBold(12)
        
        toolsBtn.setTitle("Tools".localize(), for: .normal)
        toolsBtn.setTitleColor(.white, for: .normal)
        toolsBtn.setTitleColor(.white, for: .highlighted)
        toolsBtn.titleLabel?.font = .regular(12)
        
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .bottom
        config.imagePadding = 4
        toolsBtn.configuration = config
        
        cameraManger = CDCameraManger(baseView: self.baseView, isVideo: false)
//        cameraManger.delegate = self

    }
    

    @IBAction func takePhotoAction(_ sender: Any) {
        cameraManger.takePhoto()
    }
    
    @IBAction func toolsAction(_ sender: Any) {
        let tools = CDToolsViewController()
        tools.modalPresentationStyle = .fullScreen
        self.present(tools, animated: true)
    }
    
    @IBAction func autoScanAction(_ sender: Any) {
        var config = UIButton.Configuration.plain()
        if  isAuto{
            config.imagePlacement = .trailing
        }else {
            config.imagePlacement = .leading
        }
        self.autoScanBtn.configuration = config
    }
    
    @IBAction func lightAction(_ sender: Any) {
//        if AVCaptureDevice.FlashMode == .on {
//            cameraManger.trunFlash(model: .off)
//            lightBtn.isSelected = false
//        } else {
//            cameraManger.trunFlash(model: .on)
//            lightBtn.isSelected = true
//        }
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
