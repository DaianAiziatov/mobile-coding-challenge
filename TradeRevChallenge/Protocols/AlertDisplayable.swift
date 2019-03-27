//
//  AlertDisplayable.swift
//  SmartNotes
//
//  Created by Daian Aiziatov on 26/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

protocol AlertDisplayable {
    func displayAlert(with title: String?, message: String?, actions: [UIAlertAction]?, style: UIAlertController.Style?)
}

extension AlertDisplayable where Self: UIViewController {

    func displayAlert(with title: String?, message: String?, actions: [UIAlertAction]? = nil, style: UIAlertController.Style? = .alert) {
        guard presentedViewController == nil else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style!)

        if let actions = actions {
            actions.forEach { action in
                alertController.addAction(action)
            }
        } else {
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okButton)
        }
        present(alertController, animated: true)
    }
}
