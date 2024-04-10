//
//  CDLockViewController.swift
//  Figma
//
//  Created by dong chang on 2024/1/23.
//

import UIKit
import GoogleMobileAds
class CDLockViewController: UIViewController {
    enum ViewType:Int {
        case login
        case set
        case lockScreen
    }
    enum LockState {
        case enter
        func getState()->PasscodeLockStateType {
            switch self {
            case .enter:
                return PasscodeEnterState()
//
            }
        }
    }
    @IBOutlet weak var faceBtn: UIButton!
    @IBOutlet var placeholder: [PasscodeSignPlaceholderView]!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var titlleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var placeholderX: NSLayoutConstraint!
    
    @IBOutlet weak var lockView: UIStackView!
    private var passcodeLock: PasscodeLockType?
    private var animateOnDismiss: Bool = false
    public var viewType: ViewType = .login
    private var delegate: PasscodeLockViewControllerDelegate?
    
    private var isplaceholderAnimationCompleted = true
    private var shouldTryToAuthenticateWithBiometrics = true
var setAction:(() ->Void)!
    private var state: PasscodeLockStateType! {
        didSet {
            updatePasscodeview()
        }
    }
    
    private var textView = UITextView()
    private var tmpPasscode: String?


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        popKeyboard()
        self.tabBarController?.hidesBottomBarWhenPushed = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updatePasscodeview()
        animateplaceholder(placeholder: placeholder, toState: .inactive)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        state = LockState.enter.getState()

        self.titlleLabel.textColor = UIColor(36, 43, 56)
        self.subTitle.textColor = UIColor(94, 103, 117)
        self.titlleLabel.font = UIFont.medium(18)
        self.subTitle.font = UIFont.medium(14)
        
        self.faceBtn.setTitleColor(UIColor(61, 138, 247, 1), for: .normal)
        self.faceBtn.titleLabel?.font = .regular(16)
        self.faceBtn.isHidden = viewType == .set
        if CDSignalTon.shared.basePwd == nil || viewType == .set{
            self.titlleLabel.text = "Enter New Passcode"
            self.subTitle.text = "This passcode will be used to unlock restricted apps and “App Blocker”"
            let backBtn = UIButton(type: .custom)
            backBtn.setImage("back".image, for: .normal)
            backBtn.setTitle("Passcode", for: .normal)
            backBtn.setTitleColor(.customBlack, for: .normal)
            backBtn.titleLabel?.font = .medium(18)
            backBtn.contentHorizontalAlignment = .left
            backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        } else {
            self.titlleLabel.text = "Enter a Passcode"
            self.subTitle.text = "Enter your passcode to unlock"
            
        }
        self.iconView.layer.cornerRadius = 18
        
        textView.delegate = self
        textView.keyboardType = .numberPad
        view.addSubview(textView)
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popKeyboard), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        faceBtn.isHidden = !CDConfigFile.getBoolValueFromConfigWith(key: .faceSwitch)
    }
    
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                           NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            keyboardHeight = keyboardHeight > 0 ? keyboardHeight - view.safeAreaInsets.bottom : keyboardHeight
            faceBtn.maxY = CDSCREEN_HEIGTH - (keyboardHeight + 60)
        }
    }
    
    @objc func popKeyboard() {
        textView.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }else {
            textView.resignFirstResponder()
        }
    }
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func faceIDClick() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        
        CDAuthorizationTools.checkPermission(type: .faceId, presentVC: self) {[weak self] flag, message in
            guard let self = self else{
                return
            }
            if flag {
                self.loginSuccess()
            }
        }
    }
   
    
    func loginSuccess() {
        DispatchQueue.main.async {
            if self.viewType == .login {
                CDSignalTon.shared.tab = CDTabBarViewController()
                self.setWindowRoot()
            } else if self.viewType == .lockScreen{
                if CDSignalTon.shared.tab == nil {
                    CDSignalTon.shared.tab = CDTabBarViewController()
                } else {
                    self.view.removeFromSuperview()
                }

            }else {
                CDConfigFile.setBoolValueToConfigWith(key: .passcodeSwitch, boolValue: true)
                CDHUDManager.shared.showComplete("Done!")
                self.setAction()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setWindowRoot(){
        if CDSignalTon.shared.vipType == .not {
            let root = CDPageViewController()
            root.isOnlyWeekSub = true
            let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
            myDelegate.window?.rootViewController = root

        }else {
            let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
            myDelegate.window?.rootViewController = CDSignalTon.shared.tab
        }
    }
 
    func dismissPasscodeLock(_  success: Bool, _ lock:  PasscodeLockType? = nil , completionHandler: (() -> Void)? = nil) {
        
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss) {
                self.delegate?.passcodeLockDidDismiss(success: success)
            }
        } else {
            navigationController?.popViewController(animated: animateOnDismiss)
            delegate?.passcodeLockDidDismiss(success: success)
        }
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        isplaceholderAnimationCompleted = false
        animateplaceholder(placeholder: placeholder, toState: .error)
        shakeView()
        view.layoutIfNeeded()
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
            guard let self = self else {
                return
            }
            self.isplaceholderAnimationCompleted = true
            self.animateplaceholder(placeholder: self.placeholder, toState: .inactive)
        }
    }
    
    func animateplaceholder(placeholder: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        for placeholder in placeholder {
            placeholder.animateState(state: state)
        }
    }
    
    private func animatePlacehodlerAtIndex(index: Int, toState state: PasscodeSignPlaceholderView.State) {
        guard index < placeholder.count && index >= 0 else { return }
        placeholder[index].animateState(state: state)
    }
}


extension CDLockViewController: UITextViewDelegate {
    
    func updatePasscodeview() {
        placeholder = placeholder.enumerated( ).map {
            $1.isHidden = $0 < state.passcodeLength ? false : true
            return $1
        }
        passcodeLock = PasscodeLock(state: state)
        passcodeLock?.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text.isEmpty {
            passcodeLock?.removeSign()
        } else {
            passcodeLock?.addsign(text)
        }
        textView.text = ""
        
        
        return true
    }
}

extension CDLockViewController: PasscodeLockTypeDelegate {
    func touchIDDidSuccess(_ lock: PasscodeLockType) {
        animateplaceholder(placeholder: placeholder, toState: .inactive)
        dismissPasscodeLock(true, lock) {
            self.delegate?.passcodeLockDidDismiss(success: true)
        }
    }
    
    func touchIDDidFail(_ lock: PasscodeLockType) {
        animateWrongPassword()
    }
    
    func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        updatePasscodeview()
        animateplaceholder(placeholder: placeholder, toState: .inactive)
        
    }
    
    func passcodeLock(_ lock: PasscodeLockType, addedsignAt index: Int) {
        animatePlacehodlerAtIndex(index: index, toState: .active)
    }
    
    func passcodeLock(_ lock: PasscodeLockType, removedsignAt index: Int) {
        animatePlacehodlerAtIndex(index: index, toState: .inactive)

    }
    
    func passcodeDidReceive(_ passcode: String) {
        let passcode_db = CDSignalTon.shared.basePwd

        if passcode_db == nil || viewType == .set{
            if tmpPasscode == nil {
                tmpPasscode = passcode
                self.titlleLabel.text = "Re-enter Passcode"
                updatePasscodeview()
                animateplaceholder(placeholder: placeholder, toState: .inactive)
            } else {
                if tmpPasscode == passcode{
                    CDSqlManager.shared.updateUserPwdWith(pwd: passcode)
                    CDSignalTon.shared.basePwd = passcode
                    loginSuccess()
                } else {
                    self.titlleLabel.text = "Passcode Not Mismatch"
                    self.subTitle.text = "Please try again"
                    heavy()
                    animateWrongPassword()
                }
            }
            
        } else {
            if passcode == passcode_db {
                self.textView.resignFirstResponder()
                loginSuccess()
            } else {
                self.titlleLabel.text = "Wrong Passcode"
                self.subTitle.text = "Please try again"
                heavy()
                animateWrongPassword()
            }
        }
    }
    
    func heavy() {
        let gereate = UIImpactFeedbackGenerator(style: .heavy)
        gereate.prepare()
        gereate.impactOccurred()
    }
    
    
    private func shakeView() {
        let ani = CABasicAnimation(keyPath: "position")
        ani.duration = 0.05
        ani.repeatCount = 5
        ani.autoreverses = true
        ani.fromValue = NSValue(cgPoint: CGPoint(x: lockView.center.x - 10, y: lockView.center.y))
        ani.toValue = NSValue(cgPoint: CGPoint(x: lockView.center.x + 10, y: lockView.center.y))
        lockView.layer.add(ani, forKey: "position")
    }
}
