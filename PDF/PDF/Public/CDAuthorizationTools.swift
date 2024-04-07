//
//  CDAuthorizationTools.swift
//  Figma
//
//  Created by dong chang on 2024/2/3.
//

import Foundation
import AVFoundation
import Photos
import LocalAuthentication
import UIKit
class CDAuthorizationTools {
    /**
     判断权限
     */
    class func checkPermission(type: CDDevicePermissionType, presentVC: UIViewController, Handler: @escaping (Bool, String?) -> Void) {
        switch type {
            
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined,.restricted:
                PHPhotoLibrary.requestAuthorization { (status) in
                    Handler(status == .authorized, nil)
                }
            case .denied:
                warnPermission(type: .library, viewController: presentVC)
            case .authorized,.limited:
                Handler(true, nil)

            @unknown default:
                break
            }
            
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (status) in
                    Handler(status, nil)
                }
            case .authorized,.restricted:
                Handler(true, nil)
            case .denied:
                warnPermission(type: .camera, viewController: presentVC)
            default:
                break
            }
        case .micorphone:
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .audio) { (status) in
                    Handler(status, nil)
                }
            case .authorized,.restricted:
                Handler(true, nil)
            case .denied:
                warnPermission(type: .camera, viewController: presentVC)
            default:
                break
            }
        case .location:
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                CLLocationManager().requestWhenInUseAuthorization()
                Handler(true, nil)
            case .authorizedAlways,.authorizedWhenInUse:
                Handler(true, nil)
            case .denied:
                warnPermission(type: .location, viewController: presentVC)
            default:
                break
            }
        case .faceId:
//            let strTips = "Try Face ID Again"
            let authContent = LAContext()
            var error: NSError?
            if authContent.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                authContent.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "FaceID") { (success,error) in
                    if success {
                        Handler(true, nil)
                    } else {
                        guard let laError = error as? LAError else{
                            Handler(true, "Wrong Face ID")
                            return
                        }
                        switch laError.code {
                        case.authenticationFailed,.biometryLockout:
                            Handler(true, "Wrong Face ID")
                        case .userFallback:
                            Handler(false, "Please Input Passcode")
                        default:
                            break
                        }
                    }
                }
            }
            guard let laError = error as? LAError else{
                return
            }
            if laError.code == .biometryNotAvailable {
                warnPermission(type: .faceId, viewController: presentVC)
            } else if laError.code == .biometryNotEnrolled {
                CDHUDManager.shared.showText("This device is not support FaceID")
            }
        }
    }

    /**
     *配置相机、相册、地图、麦克风权限
     */
    class func warnPermission(type: CDDevicePermissionType, viewController: UIViewController) {

        DispatchQueue.main.async {
            var title: String!
            var message: String!
            switch type {
                
            case .library:
                title = "Unable to access photos in album"
                message =
                    String(format: "%@ cannot access photos. Allowpermission for %@ to access \"All Photos\"", GetAppName(),GetAppName())
            case .camera:
                title = "Camera Access Not Enabled"
                message = String(format: "Unable to record video. Go to “Setting”>”%@”” and enable camera access", GetAppName())
            case .micorphone:
                title = "Microphoto Access Not Enabled"
                message = String(format: "Unable to record micorphone. Go to “Setting”>”%@”” and enable micorphone access", GetAppName())
            case .faceId:
                title = "Face ID Access Not Enabled"
                message = String(format: "Unable to access Face ID. Go to “Setting”>”Face ID & Passcoode” and enable Face ID access")
            default:
                break
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { (_) in
                var url = URL(string: "App-Prefs:root=Privacy")
                if #available(iOS 10.3, *) {
                    url = URL(string: UIApplication.openSettingsURLString)
                }
                if UIApplication.shared.canOpenURL(url!) {

                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
}
