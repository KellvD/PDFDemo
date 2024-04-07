//
//  CDCameraManger.swift
//  MyBox
//
//  Created by changdong on 2020/5/28.
//  Copyright © 2019 changdong. 2012-2019. All rights reserved.
//

import UIKit
import AVFoundation

let FlashKey = "flashKey"
let HdrKey = "hdrKey"
let DelayKey = "delayKey"

protocol CDCameraMangerDelegate {
    func cameraTakePhotoDidComplete(image: UIImage?)
    func cameraTakeVideoDidComplete(videoUrl: URL?)
    func cameraScanQRDidComplete(content: String?, recoverHandle:@escaping() -> Void)
    func cameraUpdateDelayDidComplete(delay: Int, isEnd: Bool)
}

class CDCameraManger: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate {

    private var captureSession: AVCaptureSession!
    private var device: AVCaptureDevice!
    private var imageInput: AVCaptureDeviceInput!
    private var imageOutput: AVCapturePhotoOutput!
    private var metadataOutput: AVCaptureMetadataOutput!

    private var videoInput: AVCaptureDeviceInput!
    private var audioInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureMovieFileOutput!

    var delegate: CDCameraMangerDelegate!

    var isVideoRecording = false
//    var topBar: CDCameraTopBar!
    var focusCursor: UIImageView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var currentZoomFactor: CGFloat = 0
    var cameraView: UIView!
    var qrView: UIImageView!
    var shapeLayer: CAShapeLayer!
    private var _timer: Timer!
    private var _timeCount = 0
    private var delayNum: Int!
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    init(baseView: UIView, isVideo: Bool) {
        super.init()
        cameraView = baseView
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        device = createDevice(position: .back)
        if isVideo {
            addVideoCapturePut()
        } else {
            addImageCapturePut()
        }
        captureSession.commitConfiguration()
        captureSession.startRunning()

        // 设定预览界面
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        baseView.layer.addSublayer(previewLayer)

        // 放大缩小手势
        let pitch = UIPinchGestureRecognizer(target: self, action: #selector(onZoomViewAction(pitch:)))
        pitch.delegate = self
        baseView.addGestureRecognizer(pitch)

        // 对焦手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSetFocusPoint(tap:)))
        baseView.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(autoFocusModel), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: device)

    }

    func createDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice {
        var devices: [AVCaptureDevice]!
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: position)
            devices = discoverySession.devices
        } else {
            devices = AVCaptureDevice.devices(for: .video)
        }

        var tmpdevice: AVCaptureDevice!

        for device in devices {
            if device.position == position {
                tmpdevice = device
                break
            }
        }
        return tmpdevice
    }

    func addImageCapturePut() {
        // 翻转摄像头需要创建新的input
        imageInput = try! AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(imageInput) {
            captureSession.addInput(imageInput)
        }

        imageOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }

        let con = imageOutput.connection(with: .video)!
        // 前置摄像头镜像切换
        if device.position == .front {
            con.isVideoMirrored = true
        } else {
            con.isVideoMirrored = false
        }

        // 创建媒体数据流
        metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        }
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        metadataOutput.rectOfInterest = cameraView.bounds

        shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
    }
    func addVideoCapturePut() {
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        videoInput = try! AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let audioCaptureDevice = AVCaptureDevice.default(for: .video)
        audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice!)
        if audioInput != nil {
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        }
        let con = videoOutput.connection(with: .video)
        con?.isVideoMirrored = device.position == .front
    }

    func takePhoto() {
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        imageOutput.capturePhoto(with: setting, delegate: self)
    }

    func reloadLayer() {
        self.captureSession.startRunning()
    }

    func stopTakeVideo() {
        isVideoRecording = false
        videoOutput.stopRecording()

    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
             let metaobject = metadataObjects.first
            if metaobject is AVMetadataFaceObject {

            } else if metaobject is AVMetadataMachineReadableCodeObject {
                let codeObject = previewLayer.transformedMetadataObject(for: metaobject!) as! AVMetadataMachineReadableCodeObject
                let string = codeObject.stringValue
                qrView.frame = codeObject.bounds
                if !string!.isEmpty && string != nil {

                    // 扫描到二维码后取消输出，避免扫描不停的回调
                    captureSession.removeOutput(metadataOutput)
//                    scanRQComplete(string,{
//                        //处理完成后重新添加
//                        self.captureSession.addOutput(self.metadataOutput)
//                    })
                    delegate.cameraScanQRDidComplete(content: string) { [weak self] in
                        // 处理完成后重新添加
                        self!.captureSession.addOutput(self!.metadataOutput)
                    }

                }
            }

        } else {
            print("二维吗扫不到了")
        }
    }

    @available(iOS, introduced: 10.0, deprecated: 11.0)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil {
//            takePhotoComplete(nil)
            delegate.cameraTakePhotoDidComplete(image: nil)
        } else {

            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: data!)
//            takePhotoComplete(image!)
            delegate.cameraTakePhotoDidComplete(image: image)
        }
    }

    @available(iOS 11, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
//            takePhotoComplete(nil)
            delegate.cameraTakePhotoDidComplete(image: nil)
        } else {

            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            let data = photo.fileDataRepresentation()
            let image = UIImage(data: data!)
//            takePhotoComplete(image!)
            delegate.cameraTakePhotoDidComplete(image: image)
        }
    }
  
   

    // 预览缩放
    @objc func onZoomViewAction(pitch: UIPinchGestureRecognizer) {
        if pitch.state == .began ||
            pitch.state == .changed {
            let tmpCurrentZoomFactor = currentZoomFactor * pitch.scale
            let zoom = getZoomFactor()
            if tmpCurrentZoomFactor < zoom.max
                && tmpCurrentZoomFactor > zoom.min {
                do {
                    try device.lockForConfiguration()
                } catch {

                }
                device.videoZoomFactor = tmpCurrentZoomFactor
                device.unlockForConfiguration()

            } else {
                print("缩放限制了")
            }
        }
    }

    func getZoomFactor() ->(min: CGFloat, max: CGFloat) {
        var minZoom: CGFloat = 1.0
        var maxZoom: CGFloat = device.activeFormat.videoMaxZoomFactor

        if #available(iOS 11.0, *) {
            minZoom = device.minAvailableVideoZoomFactor
            maxZoom = device.maxAvailableVideoZoomFactor
        }
        if maxZoom > 6.0 {
            maxZoom = 6.0
        }
        return (minZoom, maxZoom)
    }

    // 焦点
    @objc func onSetFocusPoint(tap: UITapGestureRecognizer) {
        focusCursor.isHidden = false
        let point =  tap.location(in: tap.view)
        focusAtPoint(point: point)
    }

    func focusAtPoint(point: CGPoint) {

        let viewSize = CGSize(width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        let focusPoint = CGPoint(x: point.y / viewSize.height, y: point.y / viewSize.width)
        do {
            try device.lockForConfiguration()
        } catch {

        }
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = focusPoint
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus

        }
        device.unlockForConfiguration()
        focusCursor.center = point
        self.focusCursor.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)

        perform(#selector(hiddelFocusCursor), with: nil, afterDelay: 0.25)
    }

    @objc func autoFocusModel() {
        if device.isFocusPointOfInterestSupported
        && device.isFocusModeSupported(.autoFocus) {
            do {
                try device.lockForConfiguration()
            } catch {

            }
            device.focusMode = .autoFocus
            focusAtPoint(point: CGPoint(x: previewLayer.frame.width/2, y: previewLayer.frame.height/2))
            device.unlockForConfiguration()
        }

    }

    @objc func hiddelFocusCursor() {
        self.focusCursor.isHidden = true
    }

    func trunFlash(model: AVCaptureDevice.FlashMode) {
//        do {
//            try device.lockForConfiguration()
//        } catch {
//
//        }
//        device.setl.flashMode = .on
//        captureSession.beginConfiguration()
//        if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
//            device.whiteBalanceMode = .autoWhiteBalance
//        }
//        device.unlockForConfiguration()
//        captureSession.commitConfiguration()
    }

    // UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        currentZoomFactor = device.videoZoomFactor
        return true
    }

}
