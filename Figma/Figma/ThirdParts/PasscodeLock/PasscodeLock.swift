//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication
open class PasscodeLock: PasscodeLockType {
    
    open weak var delegate: PasscodeLockTypeDelegate?
    open var state: PasscodeLockStateType {
        return lockState
    }
    
    private var lockState: PasscodeLockStateType
    private lazy var passcode = String()
    public init(state: PasscodeLockStateType) {
        lockState = state
    }
    
    open func addsign(_ sign: String) {
        passcode.append(sign)
        delegate?.passcodeLock(self, addedsignAt: passcode.count - 1)
        if passcode.count >= state.passcodeLength {
            delegate?.passcodeDidReceive(passcode)
            passcode.removeAll(keepingCapacity: true)
        }
        
    }
    
    open func removeSign() {
        guard passcode.count > 0 else {
            return
        }
        passcode.remove(at: passcode.index(before: passcode.endIndex))        
        delegate?.passcodeLock(self, removedsignAt: passcode.utf8.count)
    }
    
    open func changeState(_ state: PasscodeLockStateType) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.lockState = state
            strongSelf.delegate?.passcodeLockDidChangeState(strongSelf)
        }
    }
    
    open func authenticateWithTouchID() {
        let context = LAContext()
        let reason = ""
        context.localizedFallbackTitle = reason
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self]
            success, error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.handleTouchIDResult(success)
            
        }
    }
    private func handleTouchIDResult(_ success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard success, let strongSelf = self else { return }
            strongSelf.delegate?.touchIDDidSuccess(strongSelf)
            
        }
        
    }
    
    private func isTouchIDEnabled() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics, error:  nil)
    }
}
