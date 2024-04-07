//
//  CDNavigationController.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

class CDNavigationController: UINavigationController {

    var index:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()


        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .white
        navigationBar.backgroundColor = .white
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        textAttributes[.foregroundColor] = UIColor.customBlack
        textAttributes[.attachment] = UIFont.medium(17)
        navigationBar.titleTextAttributes = textAttributes
        let st = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: StatusHeight))
        st.backgroundColor = .white
        view.insertSubview(st, at: 0)


    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: animated)
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
