//
//  PasscodeEnterState.swift
//  Figma
//
//  Created by dong chang on 2024/1/23.
//

import Foundation
import UIKit
struct PasscodeEnterState: PasscodeLockStateType {
    let title: String
    let description: String
    var passcodeLength: Int

    init() {
        
        title = "Enter a Passcode"
        description = "Enter your passcode to unlock"
        passcodeLength = 4
    }

    func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {
    }

}
