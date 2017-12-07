//
//  AlertDialogUtils.swift
//  HypePubSub.iOS
//

import Foundation
import UIKit

class AlertDialogUtils
{
    static func showSingleInputDialog(viewController: UIViewController,title: String, msg: String, hint: String, onSingleInputDialog: SingleInputDialog) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0]
            {
                onSingleInputDialog.onOk(str: field.text!)
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            onSingleInputDialog.onCancel()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = hint
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

protocol SingleInputDialog
{
    func onOk(str:String)
    func onCancel()
}
